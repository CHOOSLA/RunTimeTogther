import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'states/env.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool visible = false;

  final user_idController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  PickedFile? image;

  late List<int> bytes;

  Future userRegistration() async {
    setState(() {
      visible = true;
    });

    String user_id = user_idController.text;
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String phone = phoneController.text;

    var url = Uri.parse('${Env.URL_PREFIX}/register_user.php');

    var data = {
      'userid': user_id,
      'username': name,
      'email': email,
      'password': password,
      'phone': phone,
      'image': base64.encode(File(image!.path).readAsBytesSync())
    };

    var response = await http.post(url, body: json.encode(data));

    var message = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        visible = false;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(message),
          actions: <Widget>[
            TextButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future getImageFromGallery() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    this.image = image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff4fef2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Center(
              child: Image(
                image: AssetImage('assets/images/logo1.png'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 350,
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text("????????????",
                      style: const TextStyle(
                          color: const Color(0xff02171a), fontSize: 20),
                      textAlign: TextAlign.left),
                ],
              ),
            ),
            Form(
                child: Theme(
                    data: ThemeData(
                        primaryColor: Color(0xff819395),
                        inputDecorationTheme: InputDecorationTheme(
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 15))),
                    child: Container(
                      padding: EdgeInsets.all(45.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            '????????? ?????????',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: getImageFromGallery,
                            child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff14511a)),
                                child: this.image == null
                                    ? Center(
                                        child: FittedBox(
                                            child: Icon(Icons.add),
                                            fit: BoxFit.fill),
                                      )
                                    : Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: Image.file(
                                                        File(image!.path))
                                                    .image)),
                                      )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: '?????????'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: user_idController,
                            decoration: InputDecoration(labelText: '?????????'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(labelText: '????????????'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(labelText: '?????????'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: phoneController,
                            decoration: InputDecoration(labelText: '?????????'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 50),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff14511a),
                              minimumSize: Size(250, 55),
                            ),
                            child: const Text('????????????',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            onPressed: () {
                              userRegistration();
                              Navigator.pop(context);
                            },
                          ),
                          Visibility(
                              visible: visible,
                              child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  child: CircularProgressIndicator())),
                        ],
                      ),
                    )))
          ],
        ),
      ),
    );
  }
}
