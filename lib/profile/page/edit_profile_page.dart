import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:veterinaryapp/Firebase/firebase.dart';
import 'package:veterinaryapp/components/functions.dart';
import '../../login/constants/constants.dart';
import '../../map/locationfunction.dart';
import '../widget/appbar_widget.dart';
import '../widget/profile_widget.dart';
import '../widget/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  final user;
  const EditProfilePage(this.user, {Key? key}) : super(key: key);
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

File? file;

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey _key = GlobalKey<ScaffoldState>();
  var user;
  String urlImage =
      'https://www.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png';

  @override
  void initState() {
    super.initState();
    user = widget.user;
    if (widget.user['photo'].isNotEmpty) {
      urlImage = widget.user['photo'];
    }
  }

  File? file;
  late ImageProvider img = NetworkImage(urlImage);
  returnProfile(context, fun, key) {
    Map<String, TextEditingController> c = {
      'fname': TextEditingController(text: user['fname']),
      'lname': TextEditingController(text: user['lname']),
      'phone': TextEditingController(text: user['phone']),
    };
    if (user['type'] == "doctor") {
      c.addAll({
        'about': TextEditingController(text: user['about']),
        'institute': TextEditingController(text: user['institute']),
        'designation': TextEditingController(text: user['designation']),
      });
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 24),
        ExpansionTile(
          initiallyExpanded: user['type'] == "user",
          title: const Text("Personal Details"),
          children: [
            const SizedBox(height: 24),
            TextField(
              decoration: textFieldDecoration('First Name'),
              controller: c['fname']!,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: c['lname']!,
              decoration: textFieldDecoration('Last Name'),
            ),
            const SizedBox(height: 24),
            TextField(
              inputFormatters: [MaskTextInputFormatter()],
              controller: c['phone']!,
              decoration: textFieldDecoration('Phone'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(
                  text: FirebaseAuth.instance.currentUser!.email),
              enabled: false,
              decoration: textFieldDecoration('Email'),
              // controller: c['email']!,
            ),
          ],
        ),
        // const SizedBox(height: 24),
        ...returnDoctorEditView(c, user['type']),
        MaterialButton(
            onPressed: () async {
              Map<String, dynamic> data = {};
              data['type'] = user['type'];
              c.forEach((k, v) {
                if (v.text.isEmpty) {
                  data[k] = user[k];
                } else {
                  // print(v.text);
                  data[k] = v.text;
                }
              });
              if (file == null) {
                data['photo'] = user['photo'];
              }
              if (data['type'] == "doctor") {
                if (data['timing'] == null) {
                  data['timing'] = getDefaultSchedual();
                }
              }
              data['location'] = user['location'];
              dialog(context);
              await updateProfile(data, file);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Update")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // user = widget.user;
    return SafeArea(
        key: _key,
        child: Scaffold(
            appBar: buildAppBar(context),
            body: Column(
              children: [
                ProfileWidget(
                  image: img,
                  isEdit: true,
                  onClicked: () async {
                    XFile? image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      file = File(image.path);
                      img = FileImage(file!);
                      setState(() {});
                    }
                  },
                ),
                Expanded(child: returnProfile(context, setState, _key)),
              ],
            )));
  }

  returnDoctorEditView(c, type) {
    var location = ListTile(
      leading: MaterialButton(
        onPressed: () async {
          user['location'] = await getGeoLocationPosition();
          setState(() {});
        },
        child: const Icon(Icons.pin_drop),
      ),
      title: Text(user['location'] ?? 'No Location Yet'),
    );
    return type == "user"
        ? [Container(), location]
        : [
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text("About"),
              children: [
                const SizedBox(height: 24),
                TextField(
                  maxLines: 4,
                  decoration: textFieldDecoration('About'),
                  controller: c['about']!,
                ),
                const SizedBox(height: 24),
              ],
            ),
            ExpansionTile(
              title: const Text("Employment Details"),
              children: [
                const SizedBox(height: 24),
                TextField(
                  decoration: textFieldDecoration('Institute'),
                  controller: c['institute']!,
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: textFieldDecoration('Designation'),
                  controller: c['designation']!,
                ),
                const SizedBox(height: 24),
              ],
            ),
            location
          ];
  }
}

getDefaultSchedual() {
  return {
    'monday': {'status': true, 'from': '10 am', 'to': '6 pm'},
    'tuesday': {'status': true, 'from': '10 am', 'to': '6 pm'},
    'wednesday': {'status': true, 'from': '10 am', 'to': '6 pm'},
    'thursday': {'status': true, 'from': '10 am', 'to': '6 pm'},
    'friday': {'status': true, 'from': '10 am', 'to': '6 pm'},
    'saturday': {'status': false, 'from': '10 am', 'to': '6 pm'},
    'sunday': {'status': false, 'from': '10 am', 'to': '6 pm'},
  };
}
