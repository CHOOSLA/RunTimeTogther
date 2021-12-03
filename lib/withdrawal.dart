import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'states/env.dart';

class Withdrawal extends StatefulWidget {
  @override
  _WithdrawalState createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {
  bool visible = false;

  final user_idController = TextEditingController();
  final passwordController = TextEditingController();

  late List<int> bytes;

  Future userRegistration() async {
    setState(() {
      visible = true;
    });

    String user_id = user_idController.text;
    String password = passwordController.text;

    var url = Uri.parse('${Env.URL_PREFIX}/delete_user.php');

    var data = {
      'userid': user_id,
      'password': password,
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
                  Text("회원탈퇴",
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
                          SizedBox(height: 50),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff14511a),
                              minimumSize: Size(250, 55),
                            ),
                            child: const Text('탈퇴',
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
