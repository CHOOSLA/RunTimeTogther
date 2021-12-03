import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:runtimetogether/main.dart';
import 'package:http/http.dart' as http;
import 'package:runtimetogether/states/env.dart';
import 'package:runtimetogether/withdrawal.dart';

import 'states/userstate.dart';

class AddFriend extends StatefulWidget {
  @override
  _AddFriend createState() => _AddFriend();
}

class _AddFriend extends State<AddFriend> {
  bool visible = false;

  final user_idController = TextEditingController();

  Future userAddFriend() async {
    setState(() {
      visible = true;
    });

    String user_id = user_idController.text;

    final UserState state = Provider.of<UserState>(context, listen: false);

    var url = Uri.parse('${Env.URL_PREFIX}/add_friend.php');

    var data = {'userid': state.id, 'freindid': user_id};

    var response = await http.post(url, body: json.encode(data));

    var message = jsonDecode(response.body);

    if (message == '친구추가 완료') {
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
    } else {
      setState(() {
        visible = false;
      });

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
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
                  height: 30,
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
                                labelStyle: TextStyle(
                                    color: Colors.grey, fontSize: 15))),
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
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xff45983f),
                                  minimumSize: Size(250, 55),
                                ),
                                child: const Text('로그인',
                                    style: TextStyle(
                                      fontSize: 20,
                                    )),
                                onPressed: () {
                                  userAddFriend();
                                  if (visible) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          ),
                        )))
              ],
            ),
          ),
        ));
  }
}
