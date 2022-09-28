import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widgets/textformfield.dart';

class RecoverPage extends StatefulWidget {
  const RecoverPage({Key? key}) : super(key: key);

  @override
  State<RecoverPage> createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  final _auth = FirebaseAuth.instance;
  var emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recover")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextField(
            keyboardType: TextInputType.emailAddress,
            textEditingController: emailController,
            icon: Icons.email,
            hint: "Email ID",
          ),
          MaterialButton(
            child: const Text("Recover"),
            onPressed: () async {
              bool res = await recover();
              if (res) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text("Recovery Email Sent Successfully."),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
    );
  }

  recover() async {
    bool status = false;
    if (emailController.text != "") {
      await _auth
          .sendPasswordResetEmail(email: emailController.text)
          .then((value) {
        status = true;
      }).catchError((e) {
        if (kDebugMode) {
          print(e);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Provide Email"),
        ),
      );
      return false;
    }
    return status;
  }
}
