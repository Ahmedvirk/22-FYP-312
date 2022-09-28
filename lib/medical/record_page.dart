// ignore_for_file: prefer_const_constructors, prefer_collection_literals, must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecords extends StatefulWidget {
  const MedicalRecords({Key? key}) : super(key: key);

  @override
  _MedicalRecordsState createState() => _MedicalRecordsState();
}

buildForm() {
  return controllers.map((v) {
    return TextField(
      controller: v.values.toList()[0],
      decoration: InputDecoration(hintText: v.keys.toList()[0]),
    );
  }).toList();
}

buildUpdateForm(var document) {
  return controllers.map((v) {
    v.values.toList()[0].text = document[v.keys.toList()[0]];
    return TextField(
      controller: v.values.toList()[0],
      decoration: InputDecoration(
          label: Text(v.keys.toList()[0]), hintText: v.keys.toList()[0]),
    );
  }).toList();
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

class _MedicalRecordsState extends State<MedicalRecords> {
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
      // ADD (Create)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[900],
        onPressed: () {
          for (var element in controllers) {
            element.values.toList()[0].text = "";
          }
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Add"),
                      ...buildForm(),
                    ],
                  ),
                ),
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  //Add Button
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    onPressed: () {
                      Map<String, dynamic> newBook = Map<String, dynamic>();
                      for (var element in controllers) {
                        newBook[element.keys.toList()[0]] =
                            element.values.toList()[0].text.toString();
                      }
                      FirebaseFirestore.instance
                          .collection("records")
                          .add(newBook)
                          .whenComplete(() {
                        Navigator.of(context).pop();
                      });
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add Medicine',
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}

class BookList extends StatelessWidget {
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();

  BookList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('records').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            return ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Update"),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ...buildUpdateForm(document),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          Colors.red,
                                        ),
                                      ),
                                      // color: Colors.red,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  // Update Button
                                  TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          Colors.blue,
                                        ),
                                      ),
                                      onPressed: () {

                                        Map<String, dynamic> updateBook =
                                            Map<String, dynamic>();
                                        for (var element in controllers) {
                                          updateBook[element.keys.toList()[0]] =
                                              element.values
                                                  .toList()[0]
                                                  .text
                                                  .toString();
                                        }

                                        // Updade Firestore record information regular way
                                        FirebaseFirestore.instance
                                            .collection("records")
                                            .doc(document.id)
                                            .update(updateBook)
                                            .whenComplete(() {
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text("Update",
                                          style:
                                              TextStyle(color: Colors.white))),
                                ],
                              );
                            });
                      },
                      title: Text("Name: " + document['Name']),
                      subtitle: Text("Price: " + document['Price']),
                      trailing:
                          // Delete Button
                          InkWell(
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection("records")
                              .doc(document.id)
                              .delete()
                              .catchError((e) {
                            if (kDebugMode) {
                              print(e);
                            }
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Icon(Icons.delete),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
