import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/utils.dart';
import '../services/setting_utils.dart';
import 'dart:async';

class MyPage extends StatefulWidget {
  final StreamController streamController;

  MyPage(this.streamController);

  @override
  _MyPageState createState() =>_MyPageState();
}

class _MyPageState extends State<MyPage>{
  var _list = <Map<String,dynamic>>[];
  String userToken;

  _init() async{
    var p = await SharedPreferences.getInstance();
    setState(() {
      userToken = p.getString('userToken');
    });
    await _initListFromDb(context);
  }
  @override
  void initState() {
    super.initState();
    _init();
  }

  _initListFromDb(BuildContext context) async{
    var db = await openUserDb();
    var list = await db.query('UserToken');
    setState(() {
      _list = list;
      if(userToken==null && _list.length>0){
         saveCurrentSetting(_list[0]);
      }
    });
    await db.close();
  }

  Future<void> saveCurrentSetting(Map<String,dynamic> item) async{
    var newToken = item['user_token'];
    if(newToken!=userToken){
      await saveSettingToSP(item);
      setState(() {
        userToken = item['user_token'];
      });
      widget.streamController.add(userToken);
    }
  }

  Widget _getListItem(BuildContext context,int index){
    var item = _list[index];
    var trailing = item['user_token']==userToken?Icon(Icons.done):null;
    return InkWell(
      onTap: () async{
        await saveCurrentSetting(item);
      },
      child: ListTile(title: Text(item['name']??'未知'),
          subtitle: Text(item['user_token']),
          leading: Icon(Icons.person),
          trailing:trailing
      ),
    );
  }

  _edit(BuildContext context) async{
    if(userToken!=null){
      var item = _list.where((item) => item['user_token']==userToken).first;
      await Navigator.of(context).pushNamed('/setting',arguments: item);
    }else{
      await Navigator.of(context).pushNamed('/setting');
    }
    await _initListFromDb(context);
  }

  _delete() async{
    var db = await openUserDb();
    await db.delete('UserToken',where: 'user_token=?',whereArgs: [userToken]);
    await deleteCurrentSetting();
    setState(() {
      userToken = null;
    });

    await db.close();
    await _initListFromDb(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('帐号设置'),
        actions: [
          IconButton(icon: Icon(Icons.help),onPressed: () async{
            alert(context: context,content: '帐号信息获取请登录\ntaobapapi官网获取\nhttps://taobaokeapi.com/');
          },),
          IconButton(icon: Icon(Icons.add),onPressed: () async{
            await Navigator.of(context).pushNamed('/setting');
            _init();
          },),
          Offstage(
            offstage: userToken==null,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: (){
                _edit(context);
              },
            ),
          ),
          Offstage(
            offstage: userToken==null,
            child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: (){
                    confirm(context: context,content: '确认要删除帐号信息？\n【该帐号的订单会不会被删除】',onConfirm: (){
                      _delete();
                    });
                  },
            ))
        ],
      ),
      body: ListView.separated(
        itemCount: _list.length,
        itemBuilder: _getListItem,
        separatorBuilder:(BuildContext context,int index)=>Divider(),
      ),

    );
  }
}