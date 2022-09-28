// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, unnecessary_null_comparison, prefer_const_constructors, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'model/posts.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');

class NewsFeed extends StatefulWidget {
  final User currentUser;
  NewsFeed({required this.currentUser});

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();

    getNewsFeed();
  }

  // getFollowers() async {
  //   List followerss = [];
  //   QuerySnapshot snapshot = await followingRef
  //       .doc(widget.currentUser.uid)
  //       .collection('userFollowing')
  //       .get();
  //   snapshot.docs.forEach((element) {
  //     followerss.add(element.id);
  //   });
  //   return followerss;
  // }

  getNewsFeed() async {
    List<Post> getPosts = [];

    QuerySnapshot snapshot = await postsRef
        .orderBy('timestamp', descending: true)
        .get();

    getPosts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      posts = getPosts;
    });
  }

  buildNewsFeed() {
    if (posts == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (posts.isEmpty) {
      return Center(
        child: Text("No Posts"),
      );
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "News Feed",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: RefreshIndicator(
          onRefresh: () => getNewsFeed(),
          child: buildNewsFeed(),
        ),
      ),
    );
  }
}
