// lib/register_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/register'), // Replace with your server URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.of(context).pop(); // Go back to previous page (login page)
    } else {
      // Handle error
      print('Failed to register: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9cecfb),
        title: const Text(
          'Register',
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
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
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
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
