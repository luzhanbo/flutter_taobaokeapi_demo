import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSettingToSP(Map<String,dynamic> item) async {
  var p = await SharedPreferences.getInstance();
  var p1 = p.setString('userToken', item['user_token']);
  var p2 = p.setString('siteId', item['site_id']);
  var p3 = p.setString('adzoneId', item['adzone_id']);
  var p4 = p.setString('name', item['name']);
  var results = await Future.wait([p1, p2, p3, p4]);
}

Future<void> deleteCurrentSetting() async {
  var p = await SharedPreferences.getInstance();
  var p1 = p.remove('userToken');
  var p2 = p.remove('name');
  var p3 = p.remove('siteId');
  var p4 = p.remove('adzoneId');
  var results = await Future.wait([p1, p2, p3, p4]);
}