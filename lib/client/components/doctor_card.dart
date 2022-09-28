// ignore_for_file: prefer_const_constructors, must_be_immutable, prefer_typing_uninitialized_variables, prefer_final_fields, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:veterinaryapp/client/screens/detail_screen.dart';
import '../constant.dart';

final followingsRef = FirebaseFirestore.instance.collection('following');

class DoctorCard extends StatefulWidget {
  // var _id;
  var _name;
  var _description;
  var _imageUrl;
  var _bgColor;
  var user;
  DoctorCard(
      this.user, this._name, this._description, this._imageUrl, this._bgColor);

  @override
  State<DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  bool isFollowing = false;
  bool follow = false;

  checkIfFollowing() async {
    DocumentSnapshot doc = await followingsRef
        .doc(cUserId)
        .collection('userFollowing')
        .doc(widget.user.id)
        .get()
        .whenComplete(() {
      setState(() {
        follow = true;
      });
    });

    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  void initState() {
    super.initState();

    // widget.user['photo'] = widget._imageUrl;
    checkIfFollowing();
  }

  Container buildButton(
      {required IconData icon, required Function() function}) {
    return Container(
      child: !follow
          ? CircularProgressIndicator()
          : IconButton(
              icon: Icon(
                icon,
                color: Colors.red,
              ),
              onPressed: function,
            ),
    );
  }

  buildIconButton() {
    if (isFollowing) {
      return buildButton(
        icon: Icons.favorite,
        function: handleUnfollow,
      );
    } else if (!isFollowing) {
      return buildButton(
        icon: Icons.favorite_border,
        function: handleFollow,
      );
    }
  }

  handleFollow() async {
    setState(() {
      isFollowing = true;
    });
    followingsRef
        .doc(cUserId)
        .collection('userFollowing')
        .doc(widget.user.id)
        .set({});
    setState(() {});
  }

  handleUnfollow() {
    setState(() {
      isFollowing = false;
    });

    followingsRef
        .doc(cUserId)
        .collection('userFollowing')
        .doc(widget.user.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(widget.user),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget._bgColor.withOpacity(0.1),
          // borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[200],
              backgroundImage: NetworkImage(widget._imageUrl),
            ),
            title: Text(
              widget._name,
              style: TextStyle(
                color: kTitleTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              "Tap to Open!",
              style: TextStyle(
                color: kTitleTextColor.withOpacity(0.7),
              ),
            ),
            trailing: buildIconButton(),
          ),
        ),
      ),
    );
  }
}
