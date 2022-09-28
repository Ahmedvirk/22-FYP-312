// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veterinaryapp/client/screens/home_screen.dart';
import 'package:veterinaryapp/posts/model/posts.dart';

import '../profile/page/edit_profile_page.dart';

User user = FirebaseAuth.instance.currentUser!;
// var storageRef = FirebaseStorage.instance.ref().child("user/profile/");
final postsRef = FirebaseFirestore.instance.collection('posts');
final usersRef = FirebaseFirestore.instance.collection('users');

class User_Posts extends StatefulWidget {
  @override
  State<User_Posts> createState() => _User_PostsState();
}

class _User_PostsState extends State<User_Posts> {
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    getProfilePosts();
    super.initState();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    var snapshot = await postsRef.get().whenComplete(() {
      isLoading = false;
    });
    if (isLoading == true) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    setState(() {
      // isLoading = false;

      posts = snapshot.docs.map((e) => Post.fromDocument(e)).toList();
      var p = posts.map((e) {
        if (e.ownerId == user.uid) {
          return e;
        }
      }).toList();
      posts = [];
      for (var element in p) {
        if (element != null) {
          posts.add(element);
        }
      }
      postCount = posts.length;
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(4),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Container buildButton({required String text, required var users}) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EditProfilePage(users)),
          );
        },
        child: Container(
          width: 150,
          height: 35,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  buildProfileButton(userData) {
    // viewing your own profile - should be able to edit profile
    bool isProfileOwner = user.uid == FirebaseAuth.instance.currentUser!.uid;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        users: userData,
      );
    }
  }

  buildProfileHeader() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: usersRef.doc(user.uid).snapshots(),
      builder: (BuildContext cxt,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var userData = snap.data!.data();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(),
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(user.photoURL ?? noimage),
                    radius: 40.0,
                  ),
                  buildCountColumn("Posts", postCount),
                  buildProfileButton(userData),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  user.displayName!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  userData!['designation'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  userData['about'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: posts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: ListView(
          children: [
            buildProfileHeader(),
            const Divider(
              height: 0,
            ),
            buildProfilePosts(),
          ],
        ),
      ),
    );
  }
}
