import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_learn/pages/tab_menu.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    // Use Username and Password below for testing
    // username: karn.yong@melivecode.com
    // password: melivecode
    final url = Uri.parse('https://www.melivecode.com/api/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': _usernameController.text,
      'password': _passwordController.text,
    });

    final response = await http.post(url, headers: headers, body: body);
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _showSnackbar(jsonResponse['message']);
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => TabMenuPage(
            username: jsonResponse['user']['username'],
            avatarUrl: jsonResponse['user']['avatar'],
          ),
        ),
      );
    } else if (response.statusCode == 400) {
      _showSnackbar(jsonResponse['message']);
    } else if (response.statusCode == 401) {
      _showSnackbar(jsonResponse['message']);
    } else {
      _showSnackbar('Something went wrong!');
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // return const Scaffold(body: Center(child: Text('Hello Title!')));
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (setting) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
                        width: 300,
                        height: 150,
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Don\'t you see you didn\'t enter username?';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Don\'t you see you didn\'t enter PASSWORD??';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        child: const Text('Go! Login!!'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
