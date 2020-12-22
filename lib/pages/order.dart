import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:taobaokeapi/taobaokeapi.dart';
import 'package:taobaokeui/taobaokeui.dart';
import '../services/utils.dart';
import '../services/db_utils.dart';
import '../components/OrderMenu.dart';

var statesId = ['0','12','14','3','13'];
var statusName = ['全部', '付款', '收货', '确认', '失效'];

class OrderPage extends StatefulWidget {
  final StreamController streamController;

  OrderPage(this.streamController);

  @override
  _OrderPageState createState() =>_OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Order> _orders=[];
  bool _syncing = false;
  double _finishRate = 0;
  String filter = '所有订单';
  String _progressTip='';
  int _index = 0;

  List<Order> get _currentList {
    if(_index==0){
      return _orders;
    }else{
      return _orders.where((item) => item.orderStatus==statesId[_index]).toList();
    }
  }

  _init() async{
    await queryOrdersFromDb(filter);
  }

  @override
  void initState() {
    super.initState();
    widget.streamController.stream.listen((event){
      _init();
    });
    _init();
  }

  _syncOrders([TimeRange time]) async {
    if(_syncing){
      return;
    }

    DateTime startTime,endTime ;
    if(time==null){
      var lastSyncTime = await getLastSyncTime();
      print('last sync time>>>>');
      print(lastSyncTime);

      startTime= DateTime.now();
      endTime = lastSyncTime??lastMonthFirstDay(); //DateTime(2020,12,16); //
    }else{
      startTime = time.startTime;
      endTime = time.endTime;
    }

    var timeSpan = Duration(minutes: 180);
    var tbClient = await getTbClient();

    await updateSyncTime();

    var orderSteam = tbClient.syncOrders(startTime: startTime,endTime: endTime,
      timeSpan: timeSpan,
      threads: 1,onFinish: (SyncProgress progress){
          setState(() {
            _syncing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('订单同步已完成'),));
        },onProgress: (SyncProgress progress){
          print(progress);
          print('rate=${progress.finishRate}');
          setState(() {
            _finishRate = progress.finishRate;
            _progressTip = progress.tip;
          });
        },);
    setState(() {
      _syncing = true;
    });
    var stream = orderSteam.asBroadcastStream();
    stream.listen((order) {
      // print('display order>>>');
      setState(() {
        var newOrder = Order.fromMap(order);
        var orders = _orders.where((item) => item.orderId==newOrder.orderId).toList();
        if(orders.length==0){
          var index = 0;
          var total = _orders.length;
          for(var i =0;i<total;i++){
            if(newOrder.orderCreateTime.isBefore(_orders[i].orderCreateTime)){
              index = i;
            }
          }
          _orders.insert(index, newOrder);
        }else{
          var o = orders[0];
          // o.orderStatus
        }
      });
    });

    var db = await openOrderDb();
    stream.listen((order) async{
      // print('save order>>>');
      await saveOrder(order,db);
    });
  }

  Future<void> updateSyncTime() async{
    var time = DateTime.now().microsecondsSinceEpoch;
    var values = {'last_sync_time':time};
    var db = await openOrderDb();
    await db.insert('SyncTime', values);
  }

  Future<DateTime> getLastSyncTime() async {
    var db = await openOrderDb();
    var list = await db.query('SyncTime',orderBy: 'last_sync_time desc',limit: 1);
    if(list!=null && list.length==1){
      var syncTime = list[0]['last_sync_time'];
      return DateTime.fromMicrosecondsSinceEpoch(syncTime);
    }else{
      return null;
    }
  }

  Widget _getItem(BuildContext context,int index){
    return OrderItem(_currentList[index],(Map<String,dynamic> detail){
      Navigator.of(context).pushNamed('/orderDetail',arguments: detail);
    });
  }

  queryOrdersFromDb(String tag) async{
    //'今日订单','本月订单','上个月订单','所有订单'

    List<Map<String, dynamic>> list;
    var now = DateTime.now();
    var db = await openOrderDb();

    if(tag==null || tag=='所有订单'){
      list = await db.query('Orders');
    }else if(tag=='今日订单'){
      list = await db.query('Orders',where: 'y=? and m=? and d=?',
          whereArgs: [now.year,now.month,now.day],orderBy: 'create_time desc');
    }else if(tag=='本月订单'){var now = DateTime.now();
      list = await db.query('Orders',where: 'y=? and m=?',whereArgs: [now.year,now.month]);
    }else if(tag=='上个月订单'){
      var year = now.year;
      var month = now.month-1;
      if(month==0){
        year--;
        month = 12;
      }
      list = await db.query('Orders',where: 'y=? and m=?',whereArgs: [year,month]);
    }

    var orders = list.map((item) => Order.fromMap(jsonDecode(item['detail']))).toList();
    setState(() {
      _orders.clear();
      _orders.addAll(orders);
      filter = tag;
    });

  }

  Future<void> _onRefresh() async{
    await _syncOrders();
  }

  @override
  Widget build(BuildContext context) {
    var totals = [_orders.length,0,0,0,0];
    for(int i=1;i<5;i++){
      totals[i] = _orders.where((item) => item.orderStatus==statesId[i]).length;
    }
    var selected = [false,false,false,false,false];
    selected[_index] = true;
    var texts = <String>[];
    for(var i=0;i<5;i++){
      texts.add('${statusName[i]}[${totals[i]}]');
    }
    return Scaffold(
      appBar: AppBar(
        leading: buildFilterMenu(queryOrdersFromDb),
        title: Text('$filter[${_orders.length}]'),
        actions: [
          buildSyncMenu(_syncOrders)
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              ToggleButtons(
                children: texts.map((e) => Text(e,style: TextStyle(fontSize: 14)) ).toList(),
                isSelected:selected,
                borderWidth: 1,
                borderRadius: BorderRadius.circular(10),
                onPressed: (int index){
                  setState(() {
                    _index = index;
                  });
                },
              ),
             Expanded(
               child:  EasyRefresh(
                   onRefresh: _onRefresh,
                   child: ListView.builder(itemCount: _currentList.length,itemBuilder: _getItem,)
               ),
             ),
            ],
          ),
          Offstage(
            offstage: !_syncing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(value: _finishRate,minHeight: 10,),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  color: Colors.white,
                  child: Text(_progressTip,style: TextStyle(fontSize: 14),),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}