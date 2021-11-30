import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:runtimetogether/map.dart';
import 'package:runtimetogether/states/userstate.dart';
import 'package:runtimetogether/sign_up.dart';
import 'package:http/http.dart' as http;

void main() => runApp(loginFormApp);

//==화면 전환을 할때 필요한 것
const String ROOT_PAGE = '/';

var loginFormApp = ChangeNotifierProvider(
  create: (context) => UserState(),
  child: home(),
);

class home extends StatefulWidget {
  home({Key? key}) : super(key: key);

  @override
  _home createState() => _home();
}

class _home extends State<home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: '지피에스',
      debugShowMaterialGrid: false,
      initialRoute: ROOT_PAGE,
      routes: {ROOT_PAGE: (context) => MapSample()},
      theme: new ThemeData(primarySwatch: Colors.green),
    );
  }
}
