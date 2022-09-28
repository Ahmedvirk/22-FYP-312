// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veterinaryapp/Firebase/firebase.dart';
import 'package:veterinaryapp/client/components/doctor_card.dart';
import 'package:veterinaryapp/client/constant.dart';
import 'package:veterinaryapp/components/drawer.dart';

var noimage =
    "https://firebasestorage.googleapis.com/v0/b/doctorapp-6e8f4.appspot.com/o/image.png?alt=media&token=56b613a8-f6d8-4412-bd5e-551ce3781119";
final usersRef = FirebaseFirestore.instance.collection('users');
User user = FirebaseAuth.instance.currentUser!;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> data;
  var type;
  bool loader = true;

  getType() async {
    var docSnapshot = await usersRef.doc(user.uid).get();
    if (docSnapshot.exists) {
      data = docSnapshot.data()!;
    }
    return data['type']!;
  }

  var searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getType().then((value) {
      type = value;
    }).whenComplete(() {
      loader = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // drawerScrimColor: Colors.black,
        appBar: AppBar(
          foregroundColor: Colors.black,
          shadowColor: Colors.transparent,
          backgroundColor: kBackgroundColor,
          title: Text("Vets"),
          centerTitle: true,
        ),
        drawer: loader ? Container() : buildDrawer(context, type),
        backgroundColor: kBackgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Find Your Desired Doctor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: kTitleTextColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: kSearchBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1),
                        ),
                        child: TextField(
                          autofocus: false,
                          onChanged: (c) {
                            setState(() {});
                          },
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for doctors',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      searchController.text.isNotEmpty
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: MaterialButton(
                                onPressed: () {
                                  searchController.text = "";
                                  setState(() {});
                                },
                                color: kOrangeColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.cancel),
                                // child: SvgPicture.asset('assets/icons/search.svg'),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Vets',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kTitleTextColor,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // TextButton(
                //     onPressed: () {
                //       Navigator.of(context)
                //           .push(MaterialPageRoute(builder: (x) => MessagePage()));
                //     },
                //     child: Text("Chat")),
                buildDoctorList(searchController.text.toLowerCase()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var alldoctors = [];
  var doctorstoshow = [];
  buildDoctorList(text) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'doctor')
          .snapshots(),
      builder: (BuildContext cxt,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 5,
              );
            },
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var data = snap.data!.docs[index];
              
              if (data['lname'].toString().toLowerCase().contains(text) ||
                  data['fname'].toString().toLowerCase().contains(text)) {
                if (snap.data!.docs[index].id != uid()) {
                  alldoctors.add(data);
                  return DoctorCard(
                    data,
                    data['fname'] + " " + data['lname'],
                    data['designation'] + "  " + data['institute'],
                    data['photo'] == "" ? noimage : data['photo'],
                    kBlueColor,
                  );
                } else {
                  return Container();
                }
              } else {
                return Container();
              }
            },
            itemCount: snap.data!.docs.length,
          ),
        );
      },
    );
  }
}
