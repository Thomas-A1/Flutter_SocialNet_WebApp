import 'dart:convert';
import 'dart:html';
import 'package:final_project/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class StudentForm extends StatefulWidget {
  const StudentForm({Key? key}) : super(key: key);

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  String? _studentId;
  String? _name;
  String? _email;
  String? _major;
  String? _yearGroup;
  DateTime? _dateOfBirth;
  String? _residence;
  String? _favoriteMovie;
  String? _favoriteFood;

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    String? _newdate;
    if (_dateOfBirth != null) {
      _newdate = _dateOfBirth.toString().substring(0, 10);
    }
    // Sending the form data to the database
    final apiUrl =
        'https://us-central1-social-network-383614.cloudfunctions.net/social-network/create_profile';
    final response = await http
        .post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'StudentID': _studentId,
        'name': _name,
        'email': _email,
        'major': _major,
        'year_group': _yearGroup.toString(),
        'dob': _newdate.toString(),
        'residence': _residence,
        'best_movie': _favoriteMovie,
        'best_food': _favoriteFood,
      }),
    )
        .catchError((error) {
      print('Error: $error');
    });

    print(response.body);
    if (response.statusCode == 201) {
      _formKey.currentState!.reset();

      // Showing a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully')),
      );
    } else {
      _formKey.currentState!.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit form')),
      );
    }

    // do something with the form data

    print('Student_ID: $_studentId');
    print('Name: $_name');
    print('Email: $_email');
    print('Major: $_major');
    print('Year Group: $_yearGroup');
    print('Date of Birth: $_newdate');
    print('Residence: $_residence');
    print('Favorite Meal: $_favoriteMovie');
    print('Favorite Food: $_favoriteFood');

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
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid name.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _name = value!;
                            },
                          ),
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
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Major'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Major.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _major = value!;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          DropdownButtonFormField(
                            decoration:
                                const InputDecoration(labelText: 'Year Group'),
                            value: _yearGroup,
                            items: [
                              const DropdownMenuItem(
                                  value: '2023', child: Text('2023')),
                              const DropdownMenuItem(
                                  value: '2024', child: Text('2024')),
                              const DropdownMenuItem(
                                  value: '2025', child: Text('2025')),
                              const DropdownMenuItem(
                                  value: '2026', child: Text('2026')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a year group';
                              }
                              if (_studentId == null ||
                                  !_studentId!.endsWith(value)) {
                                // compare the stored student id with the selected year group
                                return 'The year group selected does not match the last four digits of the student ID provided.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _yearGroup = value as String?;
                              });
                            },
                          ),
                          const SizedBox(height: 40.0),
                          InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dateOfBirth = pickedDate;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _dateOfBirth == null
                                      ? const Text('Select Date')
                                      : Text(DateFormat('yyyy-MM-dd')
                                          .format(_dateOfBirth!)),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          DropdownButtonFormField(
                            decoration:
                                const InputDecoration(labelText: 'Residence'),
                            value: _residence,
                            items: [
                              const DropdownMenuItem(
                                  value: 'On-Campus', child: Text('On-Campus')),
                              const DropdownMenuItem(
                                  value: 'Off-Campus',
                                  child: Text('Off-Campus')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a valid residence.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _residence = value as String?;
                              });
                            },
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Favorite Movie'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your favorite movie.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _favoriteMovie = value!;
                            },
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Favorite Food'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid favorite food.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _favoriteFood = value!;
                            },
                          ),
                          const SizedBox(height: 60.0),
                          SizedBox(
                            width: 120,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text(
                                'Submit',
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
