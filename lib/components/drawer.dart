// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinaryapp/client/screens/home_screen.dart';

Drawer buildDrawer(BuildContext context, var type) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          currentAccountPicture: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL ?? noimage)),
          ),
          accountEmail: Row(
            children: [
              user.emailVerified
                  ? Icon(
                      Icons.verified,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
              Text(user.email!),
              user.emailVerified
                  ? Text("")
                  : TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.currentUser!
                            .sendEmailVerification();
                      },
                      child: Text("Verify")),
            ],
          ),
          accountName: Text(
            user.displayName!,
            style: TextStyle(fontSize: 20.0),
          ),
          decoration: BoxDecoration(
            color: Colors.black87,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.chat),
          title: const Text(
            'Chats',
            style: TextStyle(fontSize: 24.0),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/chats');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text(
            'Profile',
            style: TextStyle(fontSize: 24.0),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/profile');
          },
        ),
        type == 'user'
            ? Container()
            : ListTile(
                leading: const Icon(Icons.post_add),
                title: const Text(
                  'Add Post',
                  style: TextStyle(fontSize: 24.0),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/upload');
                },
              ),
        type == 'doctor'
            ? ListTile(
                leading: const Icon(Icons.feed),
                title: const Text(
                  'Your Feed',
                  style: TextStyle(fontSize: 24.0),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/feed');
                },
              )
            : ListTile(
                leading: const Icon(Icons.feed),
                title: const Text(
                  'News Feed',
                  style: TextStyle(fontSize: 24.0),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/newsfeed');
                },
              ),
        type == 'doctor'
            ? ListTile(
                leading: const Icon(Icons.fiber_smart_record_outlined),
                title: const Text(
                  'Medicine Record',
                  style: TextStyle(fontSize: 24.0),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/record');
                },
              )
            : ListTile(
                leading: const Icon(Icons.fiber_smart_record),
                title: const Text(
                  'Medicine Record',
                  style: TextStyle(fontSize: 24.0),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/medicines');
                },
              ),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text(
            'Doctors',
            style: TextStyle(fontSize: 24.0),
          ),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/doctors');
          },
        ),
        const Divider(
          height: 10,
          thickness: 1,
        ),
        ListTile(
          leading: const Icon(Icons.logout_rounded),
          title: const Text(
            'Logout',
            style: TextStyle(fontSize: 24.0),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();

            Navigator.of(context).pushReplacementNamed('/loginpage');
          },
        ),
      ],
    ),
  );
}
