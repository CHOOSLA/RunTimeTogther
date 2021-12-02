import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String _id = "";
  String _password = "";
  List<String> _friends = [];

  void setId(String id) {
    _id = id;
  }

  void setPassword(String password) {
    _password = password;
  }

  void setFriends(String friendid) {
    _friends.add(friendid);
  }

  String get id => _id;
  String get password => _password;
  List<String> get friends => _friends;
}
