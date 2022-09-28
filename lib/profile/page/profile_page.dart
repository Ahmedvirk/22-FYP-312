import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinaryapp/Firebase/firebase.dart';
import '../page/edit_profile_page.dart';
import '../widget/appbar_widget.dart';
import '../widget/button_widget.dart';
import '../widget/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: buildAppBar(context),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (BuildContext cxt,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child:  CircularProgressIndicator());
          }
          var user = snap.data!.data();
          return user!['type'] == "user"
              ? returnProfileUser(user)
              : returnProfileDoctor(user);
        },
      ),
    ));
  }

  returnProfileDoctor(user) {
    String urlImage =
        'https://www.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png';
    if (user['photo'].isNotEmpty) {
      urlImage = user['photo'];
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        ProfileWidget(
          u: user['type'].toString()[0].toUpperCase(),
          image: NetworkImage(urlImage),
          onClicked: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => EditProfilePage(user)),
            );
          },
        ),
        const SizedBox(height: 24),
        buildName(user!),
        const SizedBox(height: 48),
        buildAboutDoctor(user!),
      ],
    );
  }

  returnProfileUser(user) {
    // print(user);
    String urlImage =
        'https://www.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png';
    if (user['photo'].isNotEmpty) {
      urlImage = user['photo'];
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        ProfileWidget(
          u: user['type'].toString()[0].toUpperCase(),
          image: NetworkImage(urlImage),
          onClicked: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => EditProfilePage(user)),
            );
          },
        ),
        const SizedBox(height: 24),
        buildName(user!),
        const SizedBox(height: 48),
        buildAbout(user!),
      ],
    );
  }

  Widget buildName(user) => Column(
        children: [
          Text(
            user['fname'] ?? 'No Name',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            FirebaseAuth.instance.currentUser!.email!,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildUpgradeButton() => ButtonWidget(
        text: 'Upgrade To PRO',
        onClicked: () {},
      );
  Widget tile(k, v, icon) {
    return ListTile(
      trailing: Icon(icon),
      leading: Text(
        k,
        style:
            const TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.bold),
      ),
      title: Text(
        v,
        style: const TextStyle(fontSize: 16, height: 1.4),
      ),
    );
  }

  Widget buildAbout(user) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'About',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // tile('User', user['type'], Icons.person),
                tile('Location', user['location'] ?? '',
                    Icons.pin_drop_outlined),
                tile('First Name', user['fname'], Icons.person),
                tile('Last Name', user['lname'], Icons.title),
                tile('Phone Number', user['phone'], Icons.phone),
                tile('Email', FirebaseAuth.instance.currentUser!.email,
                    Icons.email),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 30),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       MaterialButton(
                //           color: Colors.red,
                //           onPressed: () async {
                //             await deleteUser();
                //             Navigator.of(context)
                //                 .pushReplacementNamed('/loginpage');
                //           },
                //           child: Row(children: [
                //             Icon(Icons.delete),
                //             Text("Delete User")
                //           ]))
                //     ],
                //   ),
                // ),
              ],
            ),
          ],
        ),
      );
  Widget buildAboutDoctor(user) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tile('Location', user['location'] ?? '',
                    Icons.pin_drop_outlined),
                ExpansionTile(
                  title: const Text("About"),
                  children: [
                    Text(
                      user!['about']!,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: const Text("Personal Details"),
                  children: [
                    const SizedBox(height: 16),
                    // tile('User', user['type'], Icons.person),
                    tile('First Name', user['fname'], Icons.person),
                    tile('Last Name', user['lname'], Icons.title),
                    tile('Phone Number', user['phone'], Icons.phone),
                    tile('Email', FirebaseAuth.instance.currentUser!.email,
                        Icons.email),
                  ],
                ),
                ExpansionTile(
                  title: const Text("Employment Details"),
                  children: [
                    const SizedBox(height: 16),
                    // tile('User', user['type'], Icons.person),
                    tile('Institute', user['institute'] ?? '',
                        Icons.local_hospital),
                    tile('Designation', user['designation'] ?? '',
                        Icons.design_services),
                  ],
                ),
                // getSchedual(user['timing']),
                // ExpansionTile(
                //   title: Text("Timings"),
                //   children: [getSchedual(user['timing'])],
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                          color: Colors.red,
                          onPressed: () async {
                            await deleteUser();
                            Navigator.of(context)
                                .pushReplacementNamed('/loginpage');
                          },
                          child: Row(children:const [
                             Icon(Icons.delete),
                             Text("Delete User")
                          ]))
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  getSchedual(timing) {
    try {
      // print(timing);
      List<Widget> wid = [];
      timing.forEach((key, value) {
        // print(key);
        Widget w = Column(
          children: [
            Text(key),
            Checkbox(
                value: timing![key]['status'],
                onChanged: (v) {
                  // timing![key]['status'] = v;
                  // value = v;
                  // setState(() {});
                })
          ],
        );
        wid.add(w);
      });
      return timing == null
          ? Container()
          : GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              children: wid,
            );
    } catch (ex) {
      return Text(ex.toString());
    }
  }
}
