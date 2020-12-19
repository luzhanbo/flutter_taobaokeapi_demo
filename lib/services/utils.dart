import 'package:taobaokeapi/taobaokeapi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

alert({String title,String content,BuildContext context}){
  showDialog(context: context,builder: (BuildContext context){
    return AlertDialog(
      title: Text(title??"提示"),
      content: Text(content),
      actions: [
        FlatButton(child: Text('确定'),onPressed: (){
          Navigator.of(context).pop();
        },)
      ],
    );
  },barrierDismissible: false);
}

confirm({String title,String content,BuildContext context,Function() onConfirm}){
  showDialog(context: context,builder: (BuildContext context){
    return AlertDialog(
      title: Text(title??"提示"),
      content: Text(content),
      actions: [
        FlatButton(child: Text('确定'),onPressed: (){
          Navigator.of(context).pop();
          onConfirm();
        },),
        FlatButton(child: Text(' 取消'),onPressed: (){
          Navigator.of(context).pop();
        },),
      ],
    );
  },barrierDismissible: false);
}


showProgress(BuildContext context){
  showDialog(context: context,builder: (BuildContext context){
    return Center(
      child: RefreshProgressIndicator(),
    );
  },barrierDismissible: false);
}

Future<TaobaokeAPI> getTbClient() async{
  var p = await SharedPreferences.getInstance();
  var usertoken = p.getString('userToken');
  var siteId = int.tryParse(p.getString('siteId')) ;
  var adzoneId = int.tryParse(p.getString('adzoneId'));

  if(usertoken!=null){
    var tbClient = TaobaokeAPI(userToken: usertoken,defaultAdzoneId: adzoneId,defaultSiteId: siteId);
    return tbClient;
  }else{
    return null;
  }
}

Future<Database> openOrderDb() async {
  var p = await SharedPreferences.getInstance();
  var userToken = p.getString('userToken');
  var db = await openDatabase('order_$userToken.db',version: 1,onCreate: (Database db,int version) async{
    var sql = 'CREATE TABLE Orders (id INTEGER PRIMARY KEY, order_id TEXT, detail TEXT,'
        'y INTEGER,m INTEGER,d INTEGER,create_time INTEGER,status INTEGER)';
    await db.execute(sql);

    sql = 'CREATE TABLE SyncTime (id INTEGER PRIMARY KEY, create_time INTEGER,last_sync_time INTEGER)';
    await db.execute(sql);

  });
  return db;
}

Future<Database> openUserDb() async {
  var db = await openDatabase('taobaokeapi.db',version: 1,onCreate: (Database db,int version) async{
    var sql = 'CREATE TABLE UserToken (id INTEGER PRIMARY KEY, name TEXT, '
        'user_token TEXT,site_id TEXT,adzone_id TEXT)';
    await db.execute(sql);

    var values =
      { 'name':'测试帐号（初级帐号，佣金比较低）',
        'user_token':'fa7b58e0af54983e37cdad2efe6f1556',
        'site_id':1131100112,
        'adzone_id':109849650053
      };

    await db.insert('UserToken', values);
  });
  return db;
}

class TimeRange {
  DateTime startTime;
  DateTime endTime;

  TimeRange(this.startTime,this.endTime);

  @override
  String toString() {
    return 'TimeRange{startTime: $startTime, endTime: $endTime}';
  }
}
TimeRange getTimeRange(String tag){
  DateTime startTime,endTime;

  var now = DateTime.now();
  if(tag=='thisMonth'){
    startTime = DateTime.now();
    endTime = DateTime(startTime.year,startTime.month,1);
  }else if(tag=='lastMonth'){

    var year = now.year;
    var month = now.month-1;
    if(month==0){
      year--;
      month = 12;
    }
    startTime = DateTime(now.year,now.month,1);
    endTime = DateTime(year,month,1);

  }else if(tag=='recentOneMonth'){
    startTime = now;
    endTime = now.subtract(Duration(days: 30));
  }else if(tag=='recentThreeMonth'){
    startTime = now;
    endTime = now.subtract(Duration(days: 90));
  }else if(tag=='today') {
    startTime = now;
    endTime = DateTime(now.year,now.month,now.day) ;
  }else if(tag=='yesterday'){
    startTime = DateTime(now.year,now.month,now.day);
    endTime = startTime.subtract(Duration(days: 1));
  }else if(tag=='beforeYesterday'){
    startTime = DateTime(now.year,now.month,now.day).subtract(Duration(days: 1));
    endTime = startTime.subtract(Duration(days: 1));
  }

  return TimeRange(startTime,endTime);
}


