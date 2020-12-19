import 'package:flutter/material.dart';
import '../services/utils.dart';

List<PopupMenuItem<String>> _buildSyncMenuItems(){
  final map = {
    '同步今天订单':'today',
    '同步昨天订单':'yesterday',
    '同步前天订单':'beforeYesterday',
    '同步本月订单':'thisMonth',
    '同步上个月订单':'lastMonth',
    '同步最近一个月订单':'recentOneMonth',
    '同步最近三个月订单':'recentThreeMonth'
  };
  return map.keys.toList().map((e)=>PopupMenuItem(
    value:map[e],
    child: Wrap(
      spacing: 10,
      children: <Widget>[
        Icon(Icons.sync_outlined,color:Colors.blue),
        Text(e),
      ],
    ),
  )).toList();
}

Widget buildSyncMenu(Function(TimeRange) syncCallBack){
  var menuItems = _buildSyncMenuItems();
  return PopupMenuButton<String>(
    icon: Icon(Icons.sync),
    itemBuilder: (BuildContext context)=>[
      ...menuItems.sublist(0,3),
      PopupMenuDivider(),
      ...menuItems.sublist(3,5),
      PopupMenuDivider(),
      ...menuItems.sublist(5,7),
    ],
    onSelected: (String tag){
      print(tag);
      var timeRange = getTimeRange(tag);
      print(timeRange);
      syncCallBack(timeRange);
    },
  );
}

List<PopupMenuItem<String>> _buildFilterMenuItems(){
  final list = ['今日订单','本月订单','上个月订单','所有订单'];
  return list.map((e)=>PopupMenuItem(
    value:e,
    child: Wrap(
      spacing: 10,
      children: <Widget>[
        Icon(Icons.apps,color:Colors.blue),
        Text(e),
      ],
    ),
  )).toList();
}

Widget buildFilterMenu(Function(String) filterCallback){
  return PopupMenuButton<String>(
    icon: Icon(Icons.menu),
    itemBuilder: (BuildContext context)=>_buildFilterMenuItems(),
    onSelected: (String tag){
      filterCallback(tag);
    },
  );
}

