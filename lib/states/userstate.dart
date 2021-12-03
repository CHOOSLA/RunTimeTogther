import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String _id = "";
  String _password = "";
  List<Map> _friends = [];
  bool _isRun = false;

  void setId(String id) {
    _id = id;
  }

  void setPassword(String password) {
    _password = password;
  }

  void setFriends(Map friend) {
    _friends.add(friend);
  }

  void setIsRun(bool set) {
    _isRun = set;
  }

  String get id => _id;
  String get password => _password;
  List<Map> get friends => _friends;
  bool get isRun => _isRun;
}
