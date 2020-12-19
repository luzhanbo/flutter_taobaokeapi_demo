import 'package:flutter/material.dart';
import '../services/utils.dart';
import '../services/setting_utils.dart';
import 'package:taobaokeapi/taobaokeapi.dart';
import 'package:flutter/services.dart';

const contact = '\n有问题联系客服QQ:61315986';

class SettingPage extends StatefulWidget {
  final Map<String,dynamic> item;
  SettingPage(this.item);

  @override
  _SettingPageState createState() =>_SettingPageState();
}

class _SettingPageState extends State<SettingPage>{
  int id;
  TextEditingController _name = TextEditingController();
  TextEditingController _userToken = TextEditingController();
  TextEditingController _siteId = TextEditingController();
  TextEditingController _adzoneId = TextEditingController();

  _init() async{
    var item = widget.item;
    if(item!=null){
      id = item['id'];
      _name.text = item['name'];
      _userToken.text = item['user_token'];
      _siteId.text = item['site_id'];
      _adzoneId.text = item['adzone_id'];
    }
  }
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> saveSettingToDb(BuildContext context) async{
    var values = {'user_token':_userToken.text,'site_id':_siteId.text,
      'adzone_id':_adzoneId.text,'name':_name.text};
    print(values);
    print('id=$id');
    var db = await openUserDb();
    if(id!=null){
      var ret = await db.update('UserToken', values,where: 'id=?',whereArgs: [id]);
      print('update result:' );
      print(ret);
      await saveSettingToSP(values);
    }else{
      var ret = await db.insert('UserToken', values);
      print('insert result:' );
      print(ret);
      var list = await db.query('UserToken');
      if(list.length==1){
        await saveSettingToSP(values);
      }
    }
    await db.close();
    Navigator.of(context).pop(true);
  }

  Future<bool> check(BuildContext context) async{
    var name = _name.text;
    if(name.isEmpty ){
      alert(title: '出错啦',context:context,content: '帐号名称必须填写$contact');
      return false;
    }

    var usertoken = _userToken.text;
    if(usertoken.isEmpty || usertoken.length!=32){
      alert(title: '出错啦',context:context,content: '请检查usertoken是否填写正确$contact');
      return false;
    }

    var siteId = int.tryParse(_siteId.text);
    var adzoneId = int.tryParse(_adzoneId.text);
    showProgress(context);

    var ret;
    var client = TaobaokeAPI(userToken: usertoken,defaultAdzoneId: adzoneId,defaultSiteId: siteId);
    if(siteId==null || adzoneId==null){
      var method = 'taobao.tbk.sc.order.details.get';
      var startTime = DateTime.now();
      var endTime = startTime.subtract(Duration(minutes: 20));
      var params = <String,dynamic>{'end_time':formatTime(startTime),'start_time':formatTime(endTime)};
      ret = await client.execute(method, params);
    }else{
      ret = await client.search(q:'苹果',pageSize: 1);
    }
    Navigator.of(context).pop();

    var errMsg = ret['sub_msg']??ret['msg'];
    if(errMsg!=null){
      alert(title: '出错啦',context:context,content: '$errMsg $contact');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置帐号'),
        actions: [
          IconButton(icon: Icon(Icons.help),onPressed: (){
            alert(context: context,content: '快速录入，粘贴格式：\nname usertoken siteid adzoneid\n项之间是一个空格');
          },),
          IconButton(icon: Icon(Icons.paste),onPressed: () async{
            var line = await Clipboard.getData(Clipboard.kTextPlain);
            print(line.text);
            if(line.text.isNotEmpty){
              var items = line.text.split(' ');

              if(items.length==4 || items.length==2){
                _name.text = items[0];
                _userToken.text = items[1];
                if(items.length==4){
                  _siteId.text = items[2];
                  _adzoneId.text = items[3];
                }
              }
            }
          },tooltip: '粘贴',),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(decoration:
            InputDecoration(labelText: '帐号名称',
              helperText:'帐号名称，多个帐号时用于区分',
              prefixIcon: Icon(Icons.person)
            ),
              textInputAction: TextInputAction.next,
              controller: _name,
            ),
            TextField(decoration:
                  InputDecoration(labelText: 'usertoken',
                      helperText:'https://admin.taobaokeapi.com/后台授权获取',
                    prefixIcon: Icon(Icons.perm_identity)
                  ),
              textInputAction: TextInputAction.next,
              controller: _userToken,
            ),
            TextField(decoration:
                  InputDecoration(labelText: 'siteId',
                      prefixIcon: Icon(Icons.settings),
                      helperText:'淘宝联盟推广位pid的第二位，mm_xx_siteId_xx'),
              controller: _siteId,
              textInputAction: TextInputAction.next,
            ),
            TextField(decoration:
                  InputDecoration(labelText: 'adzoneId',
                      prefixIcon: Icon(Icons.settings),
                      helperText:'mm_xx_xx_adzoneId，如果只要订单功能可不输siteId/adzoneId'),
              controller: _adzoneId,
              textInputAction: TextInputAction.done,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                child: Text('保存设置'),
                onPressed: () async{
                  var ok = await check(context);
                  if(ok) {
                    await saveSettingToDb(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存成功'),));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}