import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runtimetogether/map.dart';
import 'package:runtimetogether/singup.dart';
import 'package:runtimetogether/states/userstate.dart';

import 'login.dart';

void main() => runApp(loginFormApp);

//화면 전환을 할때 필요한 것
//로그인화면
const String ROOT_PAGE = '/';
//회원가입 화면
const String SING_UP_PAGE = '/signup';
//메인 페이지
const String MAIN_PAGE = '/map';

var loginFormApp = ChangeNotifierProvider(
  create: (context) => UserState(),
  child: RunTimeTogether(),
);

class RunTimeTogether extends StatefulWidget {
  RunTimeTogether({Key? key}) : super(key: key);

  @override
  _RunTimeTogetherState createState() => _RunTimeTogetherState();
}

class _RunTimeTogetherState extends State<RunTimeTogether> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '지피에스',
      debugShowMaterialGrid: false,
      initialRoute: ROOT_PAGE,
      routes: {
        ROOT_PAGE: (context) => Login(),
        MAIN_PAGE: (context) => MapSample(),
        SING_UP_PAGE: (context) => SignUp()
      },
      theme: new ThemeData(primarySwatch: Colors.green),
    );
  }
}
