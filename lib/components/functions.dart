import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:veterinaryapp/chat/bubble.dart';

addChatRoom(chatRoom, chatRoomId) {
  FirebaseFirestore.instance
      .collection("chatRoom")
      .doc(chatRoomId)
      .set(chatRoom)
      .catchError((e) {
    return false;
  });
  return true;
}

sendMessage(String otherUserId) async {
  List<String> users = [FirebaseAuth.instance.currentUser!.uid, otherUserId];

  String chatRoomId = getChatRoomId(users[0], users[1]);
  Map<String, dynamic> chatRoom = {
    "users": users,
    "chatRoomId": chatRoomId,
  };

  bool s = await addChatRoom(chatRoom, chatRoomId);
  var status = {};
  status['room_id'] = chatRoomId;
  status['status'] = s;
  return status;
}

getChatRoomId(String a, String b) {
  // return "$a\_$b";
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}

getInbox(AsyncSnapshot<QuerySnapshot> snap, index) {
// other user id for user details
  // print(data['chatRoomId']); // chat room id for latest message

  // print(data.map((e) => e));
}

getChats(String chatRoomId) async {
  return FirebaseFirestore.instance
      .collection("chatRoom")
      .doc(chatRoomId)
      .collection("chats")
      .orderBy('time', descending: true)
      .snapshots();
}

Future<void> addMessageToDB(String chatRoomId, chatMessageData) async {
  FirebaseFirestore.instance
      .collection("chatRoom")
      .doc(chatRoomId)
      .collection("chats")
      .add(chatMessageData)
      .catchError((e) {
    if (kDebugMode) {
      print(e.toString());
    }
  });
}

getChatBubble(snapshot, index, uid) {
  bool isCurrentUser = snapshot.data.docs[index].data()["sendBy"] == uid;
  String message = snapshot.data.docs[index].data()["message"];
  // return MessageTile(message: message, sendByMe: isCurrentUser);
  return ChatBubble(
    isCurrentUser: isCurrentUser,
    text: message,
  );
}

getDate(DateTime date) {
  if (kDebugMode) {
    print(date.difference(DateTime.now()).inDays);
  }
  if (date.difference(DateTime.now()).inDays > 0) {
    return date.toIso8601String().split('T')[0].toString();
  } else {
    return date
        // DateFormat("h:mma").format(date);
        // .toLocal()
        .toIso8601String()
        .split('T')[1]
        .split('.')[0]
        .toString();
  }
}

dialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              CircularProgressIndicator(),
              Padding(
                padding:  EdgeInsets.all(8.0),
                child: Text("Loading"),
              ),
            ],
          ),
        ),
      );
    },
  );
}
