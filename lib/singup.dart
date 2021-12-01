import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future userRegistration() async {
    setState(() {
      visible = true;
    });

    String user_id = user_idController.text;
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    var url = Uri.parse('http://152.70.93.137/register_user.php');

    var data = {
      'user_id': user_id,
      'name': name,
      'email': email,
      'password': password
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
                  Text("회원가입",
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
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: '닉네임'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: user_idController,
                            decoration: InputDecoration(labelText: '아이디'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(labelText: '비밀번호'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(labelText: '이메일'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 50),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff14511a),
                              minimumSize: Size(250, 55),
                            ),
                            child: const Text('회원가입',
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
