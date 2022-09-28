import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:veterinaryapp/Firebase/firebase.dart';
import 'package:veterinaryapp/chat/chat_screen.dart';
import 'package:veterinaryapp/client/screens/home_screen.dart';
import 'package:veterinaryapp/components/functions.dart';

import 'theme.dart';
import 'package:flutter/material.dart';

class InboxPageChatty extends StatelessWidget {
  const InboxPageChatty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: blueColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: greenColor,
        onPressed: () {},
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
      body: SafeArea(child: Center(child: inboxComponents())),
    );
  }
}

inboxComponents() {
  var build = StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chatRoom')
          // .where('chats', isNull: false)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData) {
          return const Center(child: Text("No Chats"));
        } else {
          return ListView.builder(
            itemBuilder: (context, index) {
              var doc = snap.data!.docs[index];
              var chatRoomId = snap.data!.docs[index].id;

              var ids = doc.id.split('_'); // other user id for user details
              if (ids.contains(uid())) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('chatRoom/${doc.id}/chats')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      var lastM = snapshot.data!.docs[0].data();
                      // print(ids);

                      return FutureBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        future: getUserInfo(ids[0] == uid() ? ids[1] : ids[0]),
                        builder: (context, snapshotF) {
                          if (snapshotF.connectionState ==
                              ConnectionState.waiting) {
                            return const LinearProgressIndicator();
                          }
                          if (snapshotF.connectionState ==
                              ConnectionState.done) {
                            try {
                              var userData = snapshotF.data!.data()
                                  as Map<String, dynamic>;

                              return getChatTile(
                                  context: context,
                                  userData: userData,
                                  chatRoomId: chatRoomId,
                                  lastM: lastM);
                            } catch (ex) {
                              return Text(ex.toString());
                            }
                          }
                          return const LinearProgressIndicator();
                        },
                      );
                    } else {
                      return Container();
                    }
                    // return Text(lastM['message']);
                  },
                );
              } else {
                return Container();
              }
            },
            itemCount: snap.data!.docs.length,
          );
        }
      });
  return Column(
    children: [
      userDetails(),
      Expanded(
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                )),
            child: build),
      ),
    ],
  );
}

userDetails() {
  var user = FirebaseAuth.instance.currentUser;
  return Column(
    children: [
      const SizedBox(
        height: 40,
      ),
      Image.network(
        user!.photoURL ?? noimage,
        // noimage,
        height: 100,
        width: 100,
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        user.displayName!,
        style: TextStyle(fontSize: 20, color: whiteColor),
      ),
      Text(
        user.email!,
        style: TextStyle(fontSize: 16, color: mutedColor),
      ),
      const SizedBox(
        height: 30,
      ),
    ],
  );
}

getChatTile(
    {required context,
    required userData,
    required chatRoomId,
    required lastM}) {
  DateTime date1 = DateTime.fromMillisecondsSinceEpoch(lastM['time']);

  return ListTile(
    onTap: () async {
      Navigator.push(
          context,
          // MaterialPageRoute(
          // builder: (context) => ChattyMessagePage(userData, chatRoomId))
          MaterialPageRoute(
              builder: (context) => Chat(
                    chatWith: userData['fname'],
                    chatRoomId: chatRoomId,
                  )));
    },
    leading: CircleAvatar(
      radius: 24.0,
      backgroundImage: NetworkImage(userData['photo']),
    ),
    title: Row(
      children: <Widget>[
        Text(userData['fname']),
      ],
    ),
    subtitle: Row(
      children: [
        Text(lastM['sendBy'] == uid() ? "You: " : userData['fname'] + ": "),
        Flexible(
          child: Text(
            lastM['message']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          getDate(date1),
          style: const TextStyle(fontSize: 12.0),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 14.0,
        ),
      ],
    ),
  );
}
