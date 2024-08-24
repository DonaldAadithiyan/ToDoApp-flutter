// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/login'), // Replace with your server URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token']; // This is your actual JWT token

      // Store the token in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', token);
      print('Token saved: $token');

      // Navigate to the home page or any other screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Handle error
      print('Failed to login: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9cecfb),
        title: const Text(
          'Login',
          style: TextStyle(
              fontFamily: 'SFProDisplay',
              fontSize: 24.0, // Increase the font size
              fontWeight: FontWeight.w700, // Make the text bold
              color: Color.fromARGB(255, 12, 88, 195)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0052d4), Color(0xff65c7f7), Color(0xff9cecfb)],
            stops: [0, 0.5, 1],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontFamily: 'SFProDisplay', // Specify your font family here
                    fontSize: 16.0, // Optional: you can also set the font size
                    fontWeight:
                        FontWeight.w500, // Optional: set font weight if needed
                    color: Color.fromARGB(
                        255, 11, 70, 152), // Optional: set the color if needed
                  ),
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontFamily: 'SFProDisplay', // Specify your font family here
                    fontSize: 16.0, // Optional: you can also set the font size
                    fontWeight:
                        FontWeight.w500, // Optional: set font weight if needed
                    color: Color.fromARGB(
                        255, 11, 70, 152), // Optional: set the color if needed
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: const Text(
                  'Don\'t have an account? Register',
                  style: const TextStyle(
                    fontFamily: 'SFProDisplay',
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 12, 88, 195),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
