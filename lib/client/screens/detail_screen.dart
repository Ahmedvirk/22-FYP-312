// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_typing_uninitialized_variables, must_be_immutable, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinaryapp/client/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../chat/chat_screen.dart';
import '../../components/functions.dart';
import '../../map/mappage.dart';


var cUserId = FirebaseAuth.instance.currentUser!.uid;
final followingsRef = FirebaseFirestore.instance.collection('following');

class DetailScreen extends StatefulWidget {
  var user;
  DetailScreen(this.user);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
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

  Container buildButton(
      {required IconData icon, required Function() function}) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
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

  buildProfileButton() {
    if (isFollowing) {
      return buildButton(
        icon: Icons.favorite,
        // text: "Unfollow",
        function: handleUnfollow,
      );
    } else if (!isFollowing) {
      return buildButton(
        icon: Icons.favorite_border,
        // text: "Follow",
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
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back_ios_outlined),
            ),
          ),
          title: Text(
            widget.user['fname'] + " " + widget.user['lname'],
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                _launchWhatsapp(context, widget.user['phone']);
              },
              child: Icon(
                Icons.whatsapp,
                color: Colors.green,
              ),
            ),
            buildProfileButton(),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                widget.user['photo'] == "" ? noimage : widget.user['photo'],
                height: 300,
                fit: BoxFit.cover,
              ),
              // Container(
              //   color: Colors.amber[100],
              //   height: 34,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         'Rating 4/5',
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w500,
              //           backgroundColor: Colors.amber[100],
              //         ),
              //       ),
              //       SizedBox(
              //         width: 15,
              //       ),
              //       Icon(
              //         Icons.star,
              //         color: Colors.amber[400],
              //       ),
              //       Icon(
              //         Icons.star,
              //         color: Colors.amber[400],
              //       ),
              //       Icon(
              //         Icons.star,
              //         color: Colors.amber[400],
              //       ),
              //       Icon(
              //         Icons.star,
              //         color: Colors.amber[400],
              //       ),
              //       Icon(
              //         Icons.star_border,
              //         color: Colors.amber[400],
              //       ),
              //     ],
              //   ),
              // ),
              widget.user.data()['location'] != null
                  ? Container(
                      height: 250,
                      decoration: BoxDecoration(color: Colors.amberAccent),
                      child: MapPage(
                          "https://www.openstreetmap.org/#map=15/${widget.user['location']}"))
                  : Container(
                      height: 250,
                      decoration: BoxDecoration(color: Colors.amberAccent),
                      child: Center(
                        child: Text(
                          'Location Not Given',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              ExpansionTile(
                title: Text(
                  "Doctor Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.user['about'],
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          'Designation',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.user['designation'],
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 70,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.amber[800]),
                  ),
                  onPressed: () async {
                    var status = await sendMessage(widget.user.id);
                    if (status['status']) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                            chatWith: widget.user['fname'] +
                                ' ' +
                                widget.user['lname'],
                            chatRoomId: status['room_id'],
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          'Chat with Doctor',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.chat,
                          color: Colors.black,
                        ),
                      ],
                    ),
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

_launchWhatsapp(context, whatsapp) async {
  var url = "whatsapp://send?phone=$whatsapp&text=hello";
  // var url = "https://wa.me/$whatsapp?text=Your Message here";
  var whatsappAndroid = Uri.parse(url);
  if (await canLaunchUrl(whatsappAndroid)) {
    await launchUrl(whatsappAndroid);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("WhatsApp is not installed on the device"),
      ),
    );
  }
}
