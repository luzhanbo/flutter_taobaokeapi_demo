import 'dart:async';

import 'package:flutter/material.dart';
import 'cat.dart';
import 'order.dart';
import 'my.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() =>_IndexPageState();
}

class _IndexPageState extends State<IndexPage>{
  int _currentIndex=0;
  CatPage catPage;
  OrderPage orderPage;
  MyPage myPage;
  StreamController _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();

    catPage = CatPage();
    orderPage = OrderPage(_streamController);
    myPage = MyPage(_streamController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(
            offstage: _currentIndex!=0,
            child: catPage,
          ),
          Offstage(
            offstage: _currentIndex!=1,
            child: orderPage,
          ),
          Offstage(
            offstage: _currentIndex!=2,
            child: myPage,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon:Icon(Icons.category),
            label: '分类',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reorder),
            label: '订单'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置'
          )
        ],
        onTap: (int index){
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}