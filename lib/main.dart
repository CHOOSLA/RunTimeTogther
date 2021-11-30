import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:runtimetogether/map.dart';
import 'package:runtimetogether/states/userstate.dart';

void main() => runApp(loginFormApp);

//화면 전환을 할때 필요한 것
const String ROOT_PAGE = '/';

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
      routes: {ROOT_PAGE: (context) => MapSample()},
      theme: new ThemeData(primarySwatch: Colors.green),
    );
  }
}
