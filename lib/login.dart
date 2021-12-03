import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:runtimetogether/main.dart';
import 'package:http/http.dart' as http;
import 'package:runtimetogether/states/env.dart';
import 'package:runtimetogether/withdrawal.dart';

import 'states/userstate.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  bool visible = false;

  TextEditingController user_idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future userLogin() async {
    setState(() {
      visible = true;
    });

    String user_id = user_idController.text;
    String password = passwordController.text;

    //전역변수 같은 느낌
    //여기에 어플 전체에서 저장이 필요한 것을 넣는다.
    final UserState state = Provider.of<UserState>(context, listen: false);
    state.setId(user_id);
    state.setPassword(password);

    var url = Uri.parse('${Env.URL_PREFIX}/login_user.php');

    var data = {'user_id': user_id, 'password': password};

    var response = await http.post(url, body: json.encode(data));

    var message = jsonDecode(response.body);

    if (message == 'Login Matched') {
      setState(() {
        visible = false;
      });

      Navigator.pushNamed(context, MAIN_PAGE);
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

  Future withdrawal() async {
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
                      Text("로그인",
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
                              TextField(
                                controller: passwordController,
                                decoration: InputDecoration(labelText: '비밀번호'),
                                keyboardType: TextInputType.text,
                                obscureText: true,
                              ),
                              SizedBox(height: 50),
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
                                  userLogin();
                                },
                              ),
                              SizedBox(height: 15),
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
                                  Navigator.pushNamed(context, SING_UP_PAGE);
                                },
                              ),
                              SizedBox(height: 15),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffB0C5B2),
                                  minimumSize: Size(250, 55),
                                ),
                                child: const Text('회원탈퇴',
                                    style: TextStyle(
                                      fontSize: 20,
                                    )),
                                onPressed: () {
                                  withdrawal();
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
