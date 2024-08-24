import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'register_page.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Made by Aadi
void main() => runApp(const ToDoApp());

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        // Add your home route or other routes here
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final String _apiUrl =
      'http://localhost:3000/todos'; // Replace with your server URL
  String _username = ''; // Field to store the username
  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch tasks and username when the home page is initialized
  }

  Future<void> _fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final response = await http.get(Uri.parse(_apiUrl), headers: {
        'Authorization': 'Bearer $token', // Replace with actual JWT token
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> tasks = json.decode(response.body);
        setState(() {
          _tasks.clear();
          _tasks.addAll(tasks.cast<Map<String, dynamic>>());
        });
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Exception occurred while fetching tasks: $e');
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> _addTask() async {
    if (_controller.text.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');

      print('Retrieved Token: $token');

      if (token == null) {
        print('Token not found');
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request
          'Content-Type': 'application/json'
        },
        body: json.encode({'description': _controller.text}),
      );
      print('Response body: ${_controller.text}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final newTask = {
          'description': _controller.text,
          'id': responseBody['id'] // Adjust based on actual server response
        };

        setState(() {
          _tasks.add(newTask);
          _controller.clear();
        });
      } else {
        print('Failed to add task. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to add task');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to add task');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _removeTask(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final taskId = _tasks[index]['id']; // Assuming each task has an 'id'

      if (token == null || taskId == null) {
        throw Exception('Token or Task ID is null');
      }

      print('Attempting to delete task with ID: $taskId');

      final response = await http.delete(
        Uri.parse('$_apiUrl/$taskId'),
        headers: {
          'Authorization': 'Bearer $token', // Include JWT token in the request
          'Content-Type': 'application/json', // Add this if your API expects it
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _tasks.removeAt(index);
        });
        print('Task deleted successfully');
      } else {
        print('Failed to delete task. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      print('Exception occurred while deleting task: $e');
      throw Exception('Failed to delete task');
    }
  }

  Future<void> _updateTaskStatus(int index, bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');
    final taskId = _tasks[index]['id']; // Assuming each task has an 'id'

    if (token == null || taskId == null) {
      throw Exception('Token or Task ID is null');
    }

    final response = await http.patch(
      Uri.parse('$_apiUrl/$taskId'),
      headers: {
        'Authorization': 'Bearer $token', // Include JWT token in the request
        'Content-Type': 'application/json', // Add this if your API expects it
      },
      body: json.encode({'is_done': isDone ? 1 : 0}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _tasks[index]['is_done'] = isDone ? 1 : 0;
      });
    } else {
      print(
          'Failed to update task status. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update task status');
    }
  }

  Future<void> _fetchUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwtToken');
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/user/profile'), // Replace with your endpoint
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _username = data['username']; // Adjust based on your API response
        });
      } else {
        throw Exception('Failed to load username');
      }
    } catch (e) {
      print('Exception occurred while fetching username: $e');
    }
  }

  Future<void> _fetchData() async {
    await _fetchTasks();
    await _fetchUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9cecfb),
        title: const Text(
          'Your To-Dos',
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: 24.0, // Increase the font size
            fontWeight: FontWeight.w700, // Make the text bold
            color: Color.fromARGB(255, 12, 88, 195),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(CupertinoIcons.settings, size: 30),
            padding: const EdgeInsets.only(right: 10.0),
            iconSize: 40.0, // Size of the profile icon
            color: Color.fromARGB(255, 11, 70, 152),
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xff0052d4), Color(0xff65c7f7), Color(0xff9cecfb)],
          stops: [0, 0.5, 1],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        )),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, top: 18.0), // Add padding as needed
                child: Text(
                  'Hello, $_username 👋',
                  style: const TextStyle(
                    fontFamily: 'SFProDisplay',
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 12, 88, 195),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                left: 40.0,
                right: 40.0,
                bottom: 20.0,
              ), // Add padding as needed
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Add a task',
                        labelStyle: TextStyle(
                          fontFamily:
                              'SFProDisplay', // Specify your font family here
                          fontSize:
                              16.0, // Optional: you can also set the font size
                          fontWeight: FontWeight
                              .w500, // Optional: set font weight if needed
                          color: Color.fromARGB(255, 11, 70,
                              152), // Optional: set the color if needed
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.add, size: 23),
                    iconSize: 40.0, // Size of the profile icon
                    color: const Color.fromARGB(255, 11, 70, 152),
                    onPressed: _addTask,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 0), // Adjust padding as needed
                      child: ListTile(
                        leading: Checkbox(
                          value: _tasks[index]['is_done'] ==
                              1, // Convert int to bool
                          onChanged: (bool? newValue) {
                            _updateTaskStatus(index, newValue ?? false);
                          },
                          activeColor: const Color.fromARGB(255, 17, 107, 233),
                        ),
                        title: Text(
                          _tasks[index]['description'],
                          style: TextStyle(
                            fontFamily: 'SFProDisplay',
                            fontSize: 19.0,
                            fontWeight: FontWeight.w400,
                            color: const Color.fromARGB(255, 12, 88, 195),
                            decoration: _tasks[index]['is_done'] == 1
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(CupertinoIcons.delete, size: 23),
                          iconSize: 40.0, // Size of the profile icon
                          color: const Color.fromARGB(255, 11, 70, 152),
                          onPressed: () => _removeTask(index),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
