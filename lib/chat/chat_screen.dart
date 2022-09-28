import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinaryapp/components/functions.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String chatWith;

  const Chat({
    Key? key,
    required this.chatRoomId,
    required this.chatWith,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? chats;
  TextEditingController messageEditingController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();
  Widget chatMessages() {
    // return Container();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: chats,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        return snapshot.hasData
            ? Flexible(
                child: ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return getChatBubble(snapshot, index, uid);
                    }),
              )
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": uid,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      addMessageToDB(widget.chatRoomId, chatMessageMap);
      _scrollController.animateTo(
        // _scrollController.position.maxScrollExtent,
        00,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  String chatwith = "";
  @override
  void initState() {
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   curve: Curves.easeOut,
    //   duration: const Duration(milliseconds: 300),
    // );
    getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    chatField() {
      return Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        color: const Color(0x54FFFFFF),
        child: Row(
          children: [
            Expanded(
                child: TextField(
              keyboardType: TextInputType.multiline,
              controller: messageEditingController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: const InputDecoration(
                  hintText: "Message ...",
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  border: InputBorder.none),
            )),
            const SizedBox(
              width: 16,
            ),
            GestureDetector(
              onTap: () {
                addMessage();
              },
              child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0x36FFFFFF), Color(0x0FFFFFFF)],
                          begin: FractionalOffset.topLeft,
                          end: FractionalOffset.bottomRight),
                      borderRadius: BorderRadius.circular(40)),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.send)),
            ),
          ],
        ),
      );
    }

    var children2 = [
      chatMessages(),
      chatField(),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // floatingActionButton: chatField(),
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: Text(widget.chatWith),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: children2,
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

   const MessageTile({Key? key, required this.message, required this.sendByMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe
                  ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                  : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)],
            )),
        child: Text(message,
            textAlign: TextAlign.start,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
