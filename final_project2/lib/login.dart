import 'dart:convert';
import 'dart:html';
import 'package:final_project/constants/images.dart';
import 'package:final_project/feeds.dart';
import 'package:final_project/profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String? _studentId;
  String? _email;

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    // Sending the form data to the database
    final apiUrl = 'https://us-central1-social-network-383614.cloudfunctions.net/social-network/login';
    final response = await http
        .post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'StudentID': _studentId,
        'email': _email,
      }),
    )
        .catchError((error) {
      print('Error: $error');
    });

    print(response.body);
    if (response.statusCode == 200) {
      _formKey.currentState!.reset();

      // store the data in session variables
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('studentId', _studentId!);
      await prefs.setString('email', _email!);

      // Showing a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );
      // Showing a loader
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      // Redirect to the feedpage
      // Redirecting to the navbar.dart page after 5 seconds
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Feed()),
        );
      });
    } else {
      // _formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Failed!')),
      );
    }

    // do something with the form data

    print('Student_ID: $_studentId');
    print('Email: $_email');
    // clear the form fields
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          // top: 140,
          // right: 180,
          child: Container(
            // width: MediaQuery.of(context).size.width * 0.3,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
                // border: Border.all(
                // color: Colors.black,
                // width: 2.0,
                // ),
                ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    // child: SingleChildScrollView(
                    child: SizedBox(
                      width: 430,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage(logo),
                            width: 220,
                            height: 220,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Student ID'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid student ID.';
                              }
                              _studentId = value;
                              return null;
                            },
                            onSaved: (value) {
                              _studentId = value!;
                            },
                          ),
                          const SizedBox(height: 40.0),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid email address.';
                              }
                              if (!(value.contains('@ashesi.edu.gh') ||
                                  value.contains('@gmail.com'))) {
                                return 'Please enter a valid ashesi email address.';
                              }
                              _email = value;
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                            },
                          ),
                          const SizedBox(height: 100.0),
                          SizedBox(
                            width: 120,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
