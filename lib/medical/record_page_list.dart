// ignore_for_file: prefer_const_constructors, prefer_collection_literals, must_be_immutable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordsList extends StatefulWidget {
  const MedicalRecordsList({Key? key}) : super(key: key);

  @override
  _MedicalRecordsListState createState() => _MedicalRecordsListState();
}

showRecordTile(document) {
  return controllers.map((v) {
    return Text(document[v.values.toList()[0]]);
  }).toList();
}

var controllers = [
  {'Name': TextEditingController()},
  {'Dosage': TextEditingController()},
  {'Usage': TextEditingController()},
  {'Price': TextEditingController()}
];

var searchController = TextEditingController();

class _MedicalRecordsListState extends State<MedicalRecordsList> {
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Medicine Record",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: BookList(),
    );
  }
}

class BookList extends StatefulWidget {
  const BookList({Key? key}) : super(key: key);

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  TextEditingController titleController = TextEditingController();

  TextEditingController authorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Padding(
        //   padding: EdgeInsets.symmetric(
        //     horizontal: 30,
        //     vertical: 20,
        //   ),
        //   child: Stack(
        //     children: <Widget>[
        //       Container(
        //         width: MediaQuery.of(context).size.width * 0.9,
        //         padding: EdgeInsets.symmetric(horizontal: 20),
        //         decoration: BoxDecoration(
        //           color: Colors.white54,
        //           borderRadius: BorderRadius.circular(20),
        //           border: Border.all(width: 1),
        //         ),
        //         child: TextField(
        //           autofocus: false,
        //           onChanged: (c) {
        //             setState(() {});
        //           },
        //           controller: searchController,
        //           decoration: InputDecoration(
        //             hintText: 'Search for Medicine',
        //             border: InputBorder.none,
        //           ),
        //         ),
        //       ),
        //       searchController.text.isNotEmpty
        //           ? Align(
        //               alignment: Alignment.centerRight,
        //               child: MaterialButton(
        //                 onPressed: () {
        //                   searchController.text = "";
        //                   setState(() {});
        //                 },
        //                 color: Colors.black87,
        //                 padding: EdgeInsets.symmetric(
        //                   horizontal: 3,
        //                   vertical: 11,
        //                 ),
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(20),
        //                 ),
        //                 child: Icon(Icons.cancel),
        //                 // child: SvgPicture.asset('assets/icons/search.svg'),
        //               ),
        //             )
        //           : Container(),
        //     ],
        //   ),
        // ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('records').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        child: Card(
                          child: ExpansionTile(
                            title: Text("Name: " + document['Name']),
                            trailing: Text("Price: " + document['Price']),
                            children: [
                              ListTile(
                                title: Text("Dosage: " + document['Dosage']),
                                subtitle: Text("Usage: " + document['Usage']),
                              )
                            ],
                            // subtitle: Text("Dosage: " + document['Dosage']),
                            // leading: Text("Usage: " + document['Usage']),
                          ),
                        ),
                      );
                    }).toList(),
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}
