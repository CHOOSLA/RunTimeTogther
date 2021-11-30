import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String _id = "";
  String _password = "";

  void setId(String id) {
    _id = id;
  }

  void setPassword(String password) {
    _password = password;
  }

  String get id => _id;
  String get password => _password;
}
