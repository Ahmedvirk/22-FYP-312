// ignore_for_file: unnecessary_this, no_logic_in_create_state, prefer_const_constructors, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


final usersRef = FirebaseFirestore.instance.collection('users');

var user = FirebaseAuth.instance.currentUser!;

var storageRef = FirebaseStorage.instance.ref().child("posts/${user.uid}/");
final postsRef = FirebaseFirestore.instance.collection('posts');

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;

  const Post({
    Key? key,
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
  }) : super(key: key);

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
    );
  }

  @override
  State<Post> createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        description: this.description,
        location: this.location,
        mediaUrl: this.mediaUrl,
        username: this.username,
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;

  _PostState({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
  });

  buildPostHeader() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: usersRef.doc(ownerId).snapshots(),
      builder: (BuildContext cxt,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var userID = snap.data!.id;
        var userData = snap.data!.data();
        // bool isPostOwner = true;
        bool isPostOwner = userID == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userData!['photo']),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
            child: Text(
              username,
              // userData.name!,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: const Icon(Icons.more_vert),
                )
              : Text(''),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Remove this Post?"),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                await deletePost();
                Navigator.pop(context);
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  deletePost() async {
    await postsRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    await storageRef
        .child("${postId}_${Timestamp.now().millisecondsSinceEpoch}.jpg")
        .delete();

    setState(() {});
  }

  buildPostImage() {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(mediaUrl),
        ],
      ),
    );
  }

  buildPostCaption() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10, bottom: 8),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostCaption(),
        buildPostImage(),
      ],
    );
  }
}
