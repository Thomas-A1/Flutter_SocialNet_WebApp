import 'package:final_project/app_routes.dart';
import 'package:final_project/constants/images.dart';
import 'package:final_project/posts.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FeedItem extends StatelessWidget {
  final String username;
  final String email;
  final String message;
  final String timestamp;

  const FeedItem({
    Key? key,
    required this.username,
    required this.email,
    required this.message,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: NetworkImage(logo),
        ),
        title: Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.email,
                  color: Colors.grey[700],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 25),
                Icon(
                  Icons.access_time,
                  color: Colors.grey[700],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  // 'Date posted: $timestamp',
                  timestamp,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt),
                  onPressed: () {
                    // TODO: Implement like functionality
                  },
                ),
                Column(
                  children: [
                    const Text('Like'),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.23,
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    // TODO: Implement comment functionality
                  },
                ),
                Column(
                  children: [
                    const Text('Comments'),
                  ],
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.more_vert),
        isThreeLine: true,
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          // TODO: Implement onTap for feed item
        },
        onLongPress: () {
          // TODO: Implement onLongPress for feed item
        },
        dense: true,
        visualDensity: VisualDensity.compact,
        tileColor: Colors.grey[200],
        hoverColor: const Color.fromARGB(255, 223, 222, 222),
        focusColor: Colors.grey[300],
        selectedTileColor: Colors.grey[100],
        selected: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color.fromARGB(255, 203, 202, 202)),
        ),
      ),
    );
  }
}

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String? _searchQuery;

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  Future<List<dynamic>> fetchPosts() async {
    var url = 'https://us-central1-social-network-383614.cloudfunctions.net/social-network/feed';
    if (_searchQuery != null) {
      if (_searchQuery!.contains('@gmail.com')) {
        url += '?email=$_searchQuery';
      } else {
        url += '?message=$_searchQuery';
      }
    }
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        // Add this line
        if (_searchQuery!.contains('@gmail.com')) {
          return decodedResponse
              .where((post) => post['email'] == _searchQuery)
              .toList();
        } else {
          return decodedResponse
              .where((post) => post['message'].contains(_searchQuery))
              .toList();
        }
      } else {
        return decodedResponse;
      }
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 164, 162, 162),
        toolbarHeight: 80.0,
        title: Row(
          children: [
            Image.asset(
              logo,
              height: 80.0,
              width: 80.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Container(
                width: 10,
                margin: const EdgeInsets.only(left: 18.0, right: 18.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 224, 221, 221),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search for a post...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                  onChanged: _updateSearchQuery,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              // TODO: Implement onPressed for Home button
            },
          ),
          IconButton(
            icon: const Icon(Icons.post_add),
            tooltip: 'Add Post',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.feed);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 70.0),
        child: Stack(
          children: [
            FutureBuilder<List<dynamic>>(
              future: fetchPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 100.0,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              0.5, // Set the width to 80% of the device width
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final feed = snapshot.data![index];
                              return Column(
                                children: [
                                  FeedItem(
                                    username: feed['username'],
                                    email: feed['email'],
                                    message: feed['message'],
                                    timestamp: feed['Date_posted'],
                                    // userAvatarUrl: feed['userAvatarUrl'],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('No feeds found.'),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Positioned(
              top: 0.0,
              right: 16.0,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                      content: PostForm(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 8.0),
                    const Text('Add Post'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButtonWithHoverEffect extends StatefulWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _IconButtonWithHoverEffect({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  @override
  __IconButtonWithHoverEffectState createState() =>
      __IconButtonWithHoverEffectState();
}

class __IconButtonWithHoverEffectState
    extends State<_IconButtonWithHoverEffect> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEvent details) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (PointerEvent details) {
        setState(() {
          _isHovering = false;
        });
      },
      child: IconButton(
        icon: widget.icon,
        tooltip: widget.tooltip,
        onPressed: widget.onPressed,
        color: _isHovering
            ? const Color.fromARGB(255, 47, 127, 198)
            : Colors.black,
      ),
    );
  }
}
