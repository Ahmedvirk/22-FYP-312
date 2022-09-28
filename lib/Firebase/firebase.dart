import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:veterinaryapp/components/snackbar.dart';

createAccountWithEmailPassword({data, type, skey, file}) async {
  // print(data);

  bool userCreation = false;
  late UserCredential cred;
  try {
    cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'], password: data['password']);
    if (cred.user != null) {
      showSnackbar(key: skey, msg: 'User Created Succesfully', status: true);
      userCreation = true;
    } else {
      showSnackbar(key: skey, msg: 'Error with User Creation', status: false);
      return false;
    }

    // cred.user!.delete();
  } on FirebaseAuthException catch (ex) {
    // print(ex);
    showSnackbar(key: skey, msg: ex.message, status: false);
    return false;
  } on Exception catch (ex) {
    // print(ex);
    showSnackbar(key: skey, msg: ex, status: false);
    return false;
  }

  if (userCreation) {
    if (file != null) {
      String url = await uploadFile(file!);
      data['photo'] = url;
    } else {
      data['photo'] = '';
    }
    showSnackbar(key: skey, msg: 'Saving User Profile', status: true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set(data);
    } catch (ex) {
      // print(ex);
      showSnackbar(
          key: skey, msg: 'Error While Saving User Profile', status: false);
      return false;
    }
  }
  await FirebaseAuth.instance.currentUser!
      .updateDisplayName(data!['fname']! + " " + data['lname']);
  await FirebaseAuth.instance.currentUser!.updatePhotoURL(data['photo']!);
  return true;
}

loginWithEmailPassword({data, type, skey}) async {
  bool signIn = false;
  late UserCredential cred;
  try {
    cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'], password: data['password']);
    if (cred.user != null) {
      showSnackbar(key: skey, msg: 'Signed In Succesfully', status: true);
      signIn = true;
    } else {
      showSnackbar(key: skey, msg: 'Error while SignIn', status: false);
      return false;
    }

    // cred.user!.delete();
  } on FirebaseAuthException catch (ex) {
    // print(ex);
    showSnackbar(key: skey, msg: ex.message, status: false);
    return false;
  } on Exception catch (ex) {
    // print(ex);
    showSnackbar(key: skey, msg: ex, status: false);
    return false;
  }

  if (signIn) {
    showSnackbar(key: skey, msg: 'Fetching User Profile', status: true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get()
          .whenComplete(() {
            if (kDebugMode) {
              print("fetching complete");
            }
          })
          .then((value) async {
        var data = value.data();
        await FirebaseAuth.instance.currentUser!
            .updateDisplayName(data!['fname']! + " " + data['lname']);
        await FirebaseAuth.instance.currentUser!.updatePhotoURL(data['photo']!);

        // print("dsa");
        // print(value.data()!['photo']);
      });
    } catch (ex) {
      // print(ex);
      showSnackbar(
          key: skey, msg: 'Error While Fetching User Profile', status: false);
      return false;
    }
  }
  return true;
}

uid() {
  return FirebaseAuth.instance.currentUser!.uid;
}

Future<DocumentSnapshot<Object?>> getCurrentUser({id}) {
  String uid = id ?? FirebaseAuth.instance.currentUser!.uid;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');
  return collectionReference.doc(uid).get();
}

Future<String> uploadFile(File file) async {
  var userId = FirebaseAuth.instance.currentUser!.uid;

  var storageRef = FirebaseStorage.instance.ref().child("user/profile/$userId");
  var uploadTask = storageRef.putFile(file);
  var completedTask = await uploadTask;
  String downloadUrl = await completedTask.ref.getDownloadURL();
  return downloadUrl;
}

updateProfile(Map<String, dynamic> data, file) async {
  // print(data);
  try {
    var uploadingDone = false;
    var userId = FirebaseAuth.instance.currentUser!.uid;
    if (file != null) {
      String url = await uploadFile(file);
      data['photo'] = url;
      uploadingDone = true;
    } else {
      uploadingDone = true;
    }
    await FirebaseFirestore.instance.collection('users').doc(userId).set(data);

    await FirebaseAuth.instance.currentUser!
        .updateDisplayName(data['fname']! + " " + data['lname']);
    await FirebaseAuth.instance.currentUser!.updatePhotoURL(data['photo']!);

    if (uploadingDone) return;
  } catch (ex) {
    // print(ex);
  }
}

Future<String> getUserProfileImage(String uid) async {
  return await FirebaseStorage.instance
      .ref()
      .child("user/profile/$uid")
      .getDownloadURL();
}

deleteUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  String id = user!.uid;
  await FirebaseFirestore.instance.collection('users').doc(id).delete();
  await user.delete();
  await FirebaseAuth.instance.signOut();
  return;
}

Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(String uid) async {
  return await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .get()
      .catchError((e) {
    if (kDebugMode) {
      print(e.toString());
    }
  });
}
