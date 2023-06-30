// import 'package:final_project/constants/images.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class FeedItem extends StatelessWidget {
//   final String username;
//   final String email;
//   final String message;
//   final String timestamp;

//   const FeedItem({
//     Key? key,
//     required this.username,
//     required this.email,
//     required this.message,
//     required this.timestamp,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: NetworkImage(logo),
//         ),
//         title: Text(
//           username,
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(
//                   Icons.email,
//                   color: Colors.grey[700],
//                   size: 16,
//                 ),
//                 SizedBox(width: 4),
//                 Text(
//                   email,
//                   style: TextStyle(
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 SizedBox(width: 150),
//                 Icon(
//                   Icons.access_time,
//                   color: Colors.grey[700],
//                   size: 16,
//                 ),
//                 SizedBox(width: 4),
//                 Text(
//                   timestamp,
//                   style: TextStyle(
//                     color: Colors.grey[700],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 18),
//             Text(
//               message,
//               style: TextStyle(
//                 color: Colors.grey[700],
//               ),
//             ),
//           ],
//         ),
//         trailing: Icon(Icons.more_vert),
//         isThreeLine: true,
//         contentPadding: EdgeInsets.all(16),
//         onTap: () {
//           // TODO: Implement onTap for feed item
//         },
//         onLongPress: () {
//           // TODO: Implement onLongPress for feed item
//         },
//         dense: true,
//         visualDensity: VisualDensity.compact,
//         tileColor: Colors.white,
//         hoverColor: Colors.grey[200],
//         focusColor: Colors.grey[300],
//         selectedTileColor: Colors.grey[100],
//         selected: false,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: BorderSide(color: Colors.grey[200]!),
//         ),
//       ),
//     );
//   }
// }

// class Feed extends StatelessWidget {
//   const Feed({Key? key}) : super(key: key);

//   Future<List<dynamic>> getFeeds() async {
//     final response = await http.get(Uri.parse('http://localhost:5000/feed'));

//     if (response.statusCode == 200) {
//       final decodedResponse = jsonDecode(response.body);
//       //return the decoded response as a dynamic List
//       return decodedResponse as List<dynamic>;
//     } else {
//       throw Exception('Failed to load feeds');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 164, 162, 162),
//         title: Row(
//           children: [
//             Image.asset(
//               logo,
//               height: 80.0,
//               width: 80.0,
//             ),
//             SizedBox(width: 8.0),
//             Expanded(
//               child: Container(
//                 width: 10,
//                 margin: EdgeInsets.only(left: 18.0, right: 18.0),
//                 decoration: BoxDecoration(
//                   color: Color.fromARGB(255, 224, 221, 221),
//                   borderRadius: BorderRadius.circular(50.0),
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Search for a post...',
//                     prefixIcon: Icon(Icons.search),
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           _IconButtonWithHoverEffect(
//             icon: Icon(Icons.home),
//             tooltip: 'Home',
//             onPressed: () {
//               // TODO: Implement onPressed for Home button
//             },
//           ),
//           _IconButtonWithHoverEffect(
//             icon: Icon(Icons.post_add),
//             tooltip: 'Posts',
//             onPressed: () {
//               // TODO: Implement onPressed for Posts button
//             },
//           ),
//           _IconButtonWithHoverEffect(
//             icon: Icon(Icons.account_circle),
//             tooltip: 'Profile',
//             onPressed: () {
//               // TODO: Implement onPressed for Profile button
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<dynamic>>(
//         future: getFeeds(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasData && snapshot.data!.isNotEmpty) {
//               return Center(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width *
//                       0.8, // Set the width to 80% of the device width
//                   child: ListView.builder(
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       final feed = snapshot.data![index];
//                       return FeedItem(
//                         username: feed['username'],
//                         email: feed['email'],
//                         message: feed['message'],
//                         timestamp: feed['Date_posted'],
//                         // userAvatarUrl: feed['userAvatarUrl'],
//                       );
//                     },
//                   ),
//                 ),
//               );
//             } else {
//               return Center(
//                 child: Text('No feeds found.'),
//               );
//             }
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class _IconButtonWithHoverEffect extends StatefulWidget {
//   final Widget icon;
//   final String tooltip;
//   final VoidCallback onPressed;

//   const _IconButtonWithHoverEffect({
//     Key? key,
//     required this.icon,
//     required this.tooltip,
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   __IconButtonWithHoverEffectState createState() =>
//       __IconButtonWithHoverEffectState();
// }

// class __IconButtonWithHoverEffectState
//     extends State<_IconButtonWithHoverEffect> {
//   bool _isHovering = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (PointerEvent details) {
//         setState(() {
//           _isHovering = true;
//         });
//       },
//       onExit: (PointerEvent details) {
//         setState(() {
//           _isHovering = false;
//         });
//       },
//       child: IconButton(
//         icon: widget.icon,
//         tooltip: widget.tooltip,
//         onPressed: widget.onPressed,
//         color: _isHovering ? Color.fromARGB(255, 47, 127, 198) : Colors.black,
//       ),
//     );
//   }
// }

// // Replace the empty List with actual data
// // final List<dynamic> feeds = [
// //   {
// //     'username': 'johndoe',
// //     'userAvatar': 'https://picsum.photos/200',
// //     'post': 'This is my first post!',
// //     'image': 'https://picsum.photos/400',
// //   },
// //   {
// //     'username': 'janedoe',
// //     'userAvatar': 'https://picsum.photos/201',
// //     'post': 'Check out this beautiful view!',
// //     'image': 'https://picsum.photos/401',
// //   },
// //   {
// //     'username': 'jimmyjohn',
// //     'userAvatar': 'https://picsum.photos/202',
// //     'post': 'I love coding!',
// //     'image': 'https://picsum.photos/402',
// //   },
// // ];



// Replace the empty List with actual data
// final List<dynamic> feeds = [
//   {
//     'username': 'johndoe',
//     'userAvatar': 'https://picsum.photos/200',
//     'post': 'This is my first post!',
//     'image': 'https://picsum.photos/400',
//   },
//   {
//     'username': 'janedoe',
//     'userAvatar': 'https://picsum.photos/201',
//     'post': 'Check out this beautiful view!',
//     'image': 'https://picsum.photos/401',
//   },
//   {
//     'username': 'jimmyjohn',
//     'userAvatar': 'https://picsum.photos/202',
//     'post': 'I love coding!',
//     'image': 'https://picsum.photos/402',
//   },
// ];





// DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp);
// String formattedDateTime = DateFormat('dd MMMM yyyy HH:mm:ss').format(dateTime);