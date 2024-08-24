const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Database connection
const db = mysql.createConnection({
    host: '127.0.0.1',
    user: 'root',
    password: '',
    database: 'to_do_app'
});

db.connect(err => {
    if (err) throw err;
    console.log('MySQL Connected...');
});

// Register route
app.post('/register', async (req, res) => {
    const { username, email, password } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    let sql = 'INSERT INTO users (username, email, password) VALUES (?, ?, ?)';
    db.query(sql, [username, email, hashedPassword], (err, result) => {
        if (err) throw err;
        res.status(201).send('User registered');
    });
});

// Login route
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    let sql = 'SELECT * FROM users WHERE email = ?';
    db.query(sql, [email], async (err, results) => {
        if (err) throw err;

        if (results.length === 0) {
            return res.status(400).send('User not found');
        }

        const user = results[0];
        const match = await bcrypt.compare(password, user.password);

        if (!match) {
            return res.status(400).send('Invalid credentials');
        }

        const token = jwt.sign({ id: user.id, username: user.username }, 'your_jwt_secret', { expiresIn: '1h' });
        res.json({ token });
    });
});

// Middleware to verify token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token == null) return res.sendStatus(401);

    jwt.verify(token, 'your_jwt_secret', (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
};

// Protected route example
app.get('/todos', authenticateToken, (req, res) => {
    let sql = 'SELECT * FROM todos WHERE userId = ?';
    db.query(sql, [req.user.id], (err, results) => {
        if (err) throw err;
        res.json(results);
    });
});

// Add a todo (protected route)
app.post('/todos', authenticateToken, (req, res) => {
    let todo = req.body;
    req.body.title="";
    todo.userId = req.user.id;  // Assign the logged-in user’s ID to the todo
    let sql = 'INSERT INTO todos SET ?';
    db.query(sql, todo, (err, result) => {
        if (err) throw err;
        
        res.json({
            id: result.insertId,
            description: todo.description
        });
        
    });
});

app.delete('/todos/:id', authenticateToken, (req, res) => {
    const todoId = req.params.id;
    const userId = req.user.id;

    console.log(`Received DELETE request for todo ID: ${todoId} by user ID: ${userId}`);

    const sql = 'DELETE FROM todos WHERE id = ? AND userId = ?';
    
    db.query(sql, [todoId, userId], (err, result) => {
        if (err) {
            console.error('Error deleting todo:', err);
            return res.status(500).json({ error: 'Failed to delete todo' });
        }
        
        if (result.affectedRows === 0) {
            console.log(`Todo ID: ${todoId} not found or not authorized for deletion by user ID: ${userId}`);
            return res.status(404).json({ error: 'Todo not found or not authorized' });
        }
        
        console.log(`Todo ID: ${todoId} deleted successfully by user ID: ${userId}`);
        res.status(200).json({ message: 'Todo deleted successfully' });
    });
});

app.patch('/todos/:id', authenticateToken, (req, res) => {
    const todoId = req.params.id;
    const isDone = req.body.is_done;
    const userId = req.user.id;
    
    const sql = 'UPDATE todos SET is_done = ? WHERE id = ? AND userId = ?';
    
    db.query(sql, [isDone, todoId, userId], (err, result) => {
        if (err) {
            console.error('Error updating todo:', err);
            return res.status(500).json({ error: 'Failed to update todo' });
        }
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Todo not found or not authorized' });
        }
        
        res.status(200).json({ message: 'Todo updated successfully' });
    });
});

app.get('/user/profile', authenticateToken, (req, res) => {
    const userId = req.user.id; // Extract user ID from token

    // SQL query to get user profile based on userId
    const sql = 'SELECT username FROM users WHERE id = ?';
    
    db.query(sql, [userId], (err, results) => {
        if (err) {
            console.error('Error fetching user profile:', err);
            return res.status(500).json({ error: 'Failed to fetch user profile' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Assuming `results` is an array and we need the first result
        const user = results[0];

        res.json({
            username: user.username,
            // other profile fields if needed
        });
    });
});


app.listen(3000, () => {
    console.log('Server started on port 3000');
});
