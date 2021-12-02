import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String _id = "";
  String _password = "";
  List<Map> _friends = [];

  void setId(String id) {
    _id = id;
  }

  void setPassword(String password) {
    _password = password;
  }

  void setFriends(Map friend) {
    _friends.add(friend);
  }

  String get id => _id;
  String get password => _password;
  List<Map> get friends => _friends;
}
