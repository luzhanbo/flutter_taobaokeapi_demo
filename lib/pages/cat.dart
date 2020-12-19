import 'package:flutter/material.dart';
import 'package:taobaokeui/taobaokeui.dart';
import '../services/utils.dart';

class CatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TaobaokeAPI'),
        actions: [
          IconButton(icon: Icon(Icons.help),onPressed: () async{
            alert(context: context,content: '需要淘客应用定制，\n请联系客服QQ：61315986\n请备注：定制APP\nhttps://taobaokeapi.com/');
          },),
        ],
      ),
      body:Category(onSearch: (String keyword){
        Navigator.of(context).pushNamed("/search",arguments: keyword);
      },),
    );
  }
}