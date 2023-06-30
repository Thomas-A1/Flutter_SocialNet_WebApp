import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:final_project/feeds.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostForm extends StatefulWidget {
  const PostForm({Key? key}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  String email = '';
  String message = '';
  String imageUrl = '';
  final _formKey = GlobalKey<FormState>();
  String? _selectedFilePath;

  // @override
  // void initState() {
  //   super.initState();
  //   // Get the saved name from shared preferences
  //   SharedPreferences.getInstance().then((prefs) {
  //     setState(() {
  //       email = prefs.getString('email') ?? '';
  //     });
  //   });
  // }

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    final apiUrl = 'https://us-central1-social-network-383614.cloudfunctions.net/social-network/post';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      _formKey.currentState!.reset();

      // Showing a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Feed()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit post')),
      );
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    final file = File(result.files.single.path!);
    setState(() {
      _selectedFilePath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(50),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid name.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your message';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    message = value!;
                  },
                ),
                const SizedBox(height: 26),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Attach File'),
                ),
                if (_selectedFilePath != null) ...[
                  const SizedBox(height: 16),
                  Text('Selected file: $_selectedFilePath'),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
