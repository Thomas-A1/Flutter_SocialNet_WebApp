import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'constants/images.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String email = '';
  String name = '';
  String bestfood = '';
  String studentId = '';
  String bestmovie = '';
  String imageUrl = '';
  String residence = '';
  String major = '';
  String dob = '';
  String yeargroup = '';
  String placeholder = '';

  File? _image;

  @override
  void initState() {
    super.initState();

    // Get the saved name from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        email = prefs.getString('email') ?? '';
        placeholder = email.split('@').first;
        studentId = prefs.getString('studentId') ?? '';
        fetchUserProfile();
      });
    });
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await Dio().patch(
          'http://localhost:5000/user_profiles/edit?StudentID=$studentId');
      if (response.statusCode == 200) {
        final profileData = response.data['updated_profile'];
        setState(() {
          imageUrl = profileData['profile_image'] ?? '';
          name = profileData['name'] ?? '';
          bestfood = profileData['best_food'] ?? '';
          bestmovie = profileData['best_movie'] ?? '';
          residence = profileData['residence'] ?? '';
          major = profileData['major'] ?? '';
          dob = profileData['dob'] ?? '';
          yeargroup = profileData['year_group'] ?? '';
          print(imageUrl);
        });
      } else {
        print('Failed to load user profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('studentId');

    final response = await Dio().patch(
      'https://us-central1-social-network-383614.cloudfunctions.net/social-network/user_profiles?StudentID=$studentId',
      data: {
        'best_food': bestfood,
        'best_movie': bestmovie,
        'residence': residence,
        'major': major,
        'dob': dob,
      },
    );

    if (response.statusCode == 200) {
      // Update the user profile data in the state
      setState(() {
        // Update the state with the new values
        // This will update the UI with the new profile data
        final profileData = response.data['updated_profile'];
        name = profileData['name'];
        bestfood = profileData['best_food'];
        bestmovie = profileData['best_movie'];
        residence = profileData['residence'];
        major = profileData['major'];
        dob = profileData['dob'];
        yeargroup = profileData['year_group'];
      });

      // Show a snackbar to indicate that the profile has been updated
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully.'),
        ),
      );
    } else {
      // Show an error message if the profile update failed
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile.'),
        ),
      );
    }
  }

  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery, // change to ImageSource.camera for camera
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Upload the image
      await uploadImage(_image!);
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      // Upload the image to Firebase Storage
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child("photo.jpg")
          .putFile(imageFile);

      // Get the download URL of the uploaded image
      var downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the profile image URL
      setState(() {
        imageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 140.0, vertical: 24.0),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // background image and bottom contents
              Column(
                children: <Widget>[
                  Container(
                    height: 250.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(background),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 86.0),
                        color: Color.fromARGB(255, 227, 227, 227),
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Personal Information',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Card(
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.email),
                                    title: Text('Email'),
                                    subtitle: Text(email),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {},
                                    ),
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 177, 174, 174),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text('Name'),
                                    subtitle: Text(name),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {},
                                    ),
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 177, 174, 174),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.school),
                                    title: Text('Major'),
                                    subtitle: Text(major),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String editedmajor =
                                                major; // Initialize the edited email with the current email value

                                            return Container(
                                              height: 420,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16.0),
                                              constraints: BoxConstraints(
                                                  maxWidth: 400.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 40.0),
                                                    child: Text('Edit Major'),
                                                  ),
                                                  SizedBox(height: 16.0),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 400.0),
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Major',
                                                        hintText: major,
                                                      ),
                                                      maxLines:
                                                          1, // Allow only one line of text
                                                      onChanged: (value) {
                                                        editedmajor =
                                                            value; // Update the edited email value as the user types
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child: Text('Save'),
                                                    onPressed: () {
                                                      setState(() {
                                                        major =
                                                            editedmajor; // Update the email value in the parent widget's state
                                                      });
                                                      Navigator.pop(
                                                          context); // Close the modal
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 177, 174, 174),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.cake),
                                    title: Text('Date of Birth'),
                                    subtitle: Text(dob),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String editeddob =
                                                dob; // Initialize the edited email with the current email value

                                            return Container(
                                              height: 420,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16.0),
                                              constraints: BoxConstraints(
                                                  maxWidth: 400.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 40.0),
                                                    child: Text('Edit Major'),
                                                  ),
                                                  SizedBox(height: 16.0),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 400.0),
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Date of birth',
                                                        hintText: dob,
                                                      ),
                                                      maxLines:
                                                          1, // Allow only one line of text
                                                      onChanged: (value) {
                                                        editeddob =
                                                            value; // Update the edited email value as the user types
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child: Text('Save'),
                                                    onPressed: () {
                                                      setState(() {
                                                        dob =
                                                            editeddob; // Update the email value in the parent widget's state
                                                      });
                                                      Navigator.pop(
                                                          context); // Close the modal
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 177, 174, 174),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.home),
                                    title: Text('Residence'),
                                    subtitle: Text(residence),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String editedresidence =
                                                residence; // Initialize the edited email with the current email value

                                            return Container(
                                              height: 420,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16.0),
                                              constraints: BoxConstraints(
                                                  maxWidth: 400.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 40.0),
                                                    child:
                                                        Text('Edit Residence'),
                                                  ),
                                                  SizedBox(height: 16.0),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 400.0),
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Residence',
                                                        hintText: residence,
                                                      ),
                                                      maxLines:
                                                          1, // Allow only one line of text
                                                      onChanged: (value) {
                                                        editedresidence =
                                                            value; // Update the edited email value as the user types
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child: Text('Save'),
                                                    onPressed: () {
                                                      setState(() {
                                                        residence =
                                                            editedresidence; // Update the email value in the parent widget's state
                                                      });
                                                      Navigator.pop(
                                                          context); // Close the modal
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 177, 174, 174),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.star),
                                    title: Text('Favorite Food'),
                                    subtitle: Text(bestfood),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String editedfood =
                                                bestfood; // Initialize the edited email with the current email value

                                            return Container(
                                              height: 420,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16.0),
                                              constraints: BoxConstraints(
                                                  maxWidth: 400.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 40.0),
                                                    child: Text(
                                                        'Edit Favorite Food'),
                                                  ),
                                                  SizedBox(height: 16.0),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 400.0),
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Favorite Food',
                                                        hintText: bestfood,
                                                      ),
                                                      maxLines:
                                                          1, // Allow only one line of text
                                                      onChanged: (value) {
                                                        editedfood =
                                                            value; // Update the edited email value as the user types
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child: Text('Save'),
                                                    onPressed: () {
                                                      setState(() {
                                                        bestfood =
                                                            editedfood; // Update the email value in the parent widget's state
                                                      });
                                                      Navigator.pop(
                                                          context); // Close the modal
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 177, 174, 174),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.movie),
                                    title: Text('Favorite Movie'),
                                    subtitle: Text(bestmovie),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            String editedmovie =
                                                bestmovie; // Initialize the edited email with the current email value

                                            return Container(
                                              height: 420,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 16.0),
                                              constraints: BoxConstraints(
                                                  maxWidth: 400.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 40.0),
                                                    child:
                                                        Text('Edit Best Movie'),
                                                  ),
                                                  SizedBox(height: 16.0),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 400.0),
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Favorite Movie',
                                                        hintText: bestmovie,
                                                      ),
                                                      maxLines:
                                                          1, // Allow only one line of text
                                                      onChanged: (value) {
                                                        editedmovie =
                                                            value; // Update the edited email value as the user types
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  ElevatedButton(
                                                    child: Text('Save'),
                                                    onPressed: () {
                                                      setState(() {
                                                        bestmovie =
                                                            editedmovie; // Update the email value in the parent widget's state
                                                      });
                                                      Navigator.pop(
                                                          context); // Close the modal
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 177, 174, 174),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.school),
                                    title: Text('Year Group'),
                                    subtitle: Text(yeargroup),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32.0),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Profile Picture',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.camera_alt),
                                    title: Text('Change Profile Picture'),
                                    onTap: () {
                                      getImage();
                                    },
                                  ),
                                  if (_image != null) ...[
                                    kIsWeb
                                        ? Image.network(
                                            _image!.path,
                                            height: 250.0,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_image!.path),
                                            height: 250.0,
                                            fit: BoxFit.cover,
                                          ),
                                    Divider(),
                                    ListTile(
                                      leading: Icon(Icons.cloud_upload),
                                      title: Text('Upload Profile Picture'),
                                      onTap: () {
                                        uploadImage(File(_image!.path));
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: MaterialButton(
                                onPressed: updateProfile,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 111, 47, 249),
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.all(20),
                                  child: const Center(
                                      child: Text(
                                    "Update Profile",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
// profile image and camera icon

              Container(
                child: Positioned(
                  top: 160.0,
                  left: 50,
                  child: CircleAvatar(
                    radius: 70.0,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 200.0,
                right: 32.0,
                child: Visibility(
                  visible: _image != null,
                  child: ElevatedButton(
                    onPressed: () {
                      uploadImage(File(_image!.path));
                    },
                    child: Text('Upload'),
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




// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Profile extends StatefulWidget {
//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   String email = '';
//   String name = '';
//   String studentId = '';
//   String imageUrl = '';
//   File? _image;

//   @override
//   void initState() {
//     super.initState();
//     // Get the saved email and student ID from shared preferences
//     SharedPreferences.getInstance().then((prefs) {
//       setState(() {
//         email = prefs.getString('email') ?? '';
//         name = email.split('@').first;
//         studentId = prefs.getString('studentId') ?? '';
//         fetchUserProfile();
//       });
//     });
//   }

//   Future<void> fetchUserProfile() async {
//     final response =
//         await http.patch(Uri.parse('/user_profiles/edit?StudentID=$studentId'));
//     if (response.statusCode == 200) {
//       final profileData = json.decode(response.body)['updated_profile'];
//       setState(() {
//         imageUrl = profileData['profile_image'] ?? '';
//       });
//     } else {
//       print('Failed to load user profile.');
//     }
//   }

//   Future getImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//         uploadImage();
//       } else {
//         print('No image selected.');
//       }
//     });
//   }

//   Future<void> uploadImage() async {
//     final url = Uri.parse('/upload_profile_image');
//     final request = http.MultipartRequest('POST', url);
//     request.files
//         .add(await http.MultipartFile.fromPath('profile_image', _image!.path));
//     final response = await request.send();
//     if (response.statusCode == 200) {
//       final imageUrl = await response.stream.bytesToString();
//       setState(() {
//         this.imageUrl = imageUrl;
//       });
//     } else {
//       print('Failed to upload image.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//       ),
//       body: Container(
//         padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               // Profile image
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 70.0,
//                     backgroundImage: _image != null
//                         ? FileImage(_image!) as ImageProvider<Object>?
//                         : AssetImage('images/camera.png'),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.black54,
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.edit,
//                         size: 30.0,
//                         color: Color.fromARGB(255, 162, 158, 158),
//                       ),
//                       onPressed: () {
//                         getImage();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16.0),
//               // Name
//               Text(
//                 'Name:',
//                 style: TextStyle(
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8.0),
//               Text(
//                 name,
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               SizedBox(height: 16.0),
// // Email
//               Text(
//                 'Email:',
//                 style: TextStyle(
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8.0),
//               Text(
//                 email,
//                 style: TextStyle(fontSize: 16.0),
//               ),
//               SizedBox(height: 16.0),
// // Student ID
//               Text(
//                 'Student ID:',
//                 style: TextStyle(
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8.0),
//               Text(
//                 studentId,
//                 style: TextStyle(fontSize: 16.0),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
