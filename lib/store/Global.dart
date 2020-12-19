import 'package:flutter/material.dart';
import 'package:taobaokeui/taobaokeui.dart';

class Global with ChangeNotifier {
  int _cat = 0;
  int _tab = 0;

  String _userToken;

  int get cat =>_cat;
  int get tab =>_tab;


  String get userToken => _userToken;

  set userToken(String value) {
    _userToken = value;
    notifyListeners();
  }

  void setCat(int cat){
    _cat = cat;
    notifyListeners();
  }

  void setTab(int tab){
    _tab = tab;
    notifyListeners();
  }
}