import 'package:streaming_app/custome/forms/postform.dart';
import 'package:streaming_app/models/post.dart';
import 'package:streaming_app/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = false;
  bool admin = false;
  final DatabaseService db = DatabaseService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    setAdmin();
  }

  void setAdmin() async {
    var user = await db.getUser(auth.currentUser!.uid);
    setState(() {
      admin = (user.type == "ADMIN");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: () {
            setState(() {
              loading = true;
              logout();
            });
          },
          icon: const Icon(Icons.logout),
        ),
      ]),
      body: StreamBuilder<List<Post>>(
        stream: db.posts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("An error has occured!"),
            );
          } else {
            var posts = snapshot.data ?? [];

            return posts.isNotEmpty
                ? ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          elevation: 5.0,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(posts[index].message),
                          ));
                    })
                : const Center(
                    child: Text("No post have been made yet."),
                  );
          }
        },
      ),
      floatingActionButton: admin
          ? FloatingActionButton(
              onPressed: messagePopUp,
              tooltip: 'Post Message',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void logout() async {
    await auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const SignUpPage()),
      ModalRoute.withName('/'),
    );
  }

  void messagePopUp() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return const Padding(
              padding: EdgeInsets.all(30.0), child: PostForm());
        });
  }
}
