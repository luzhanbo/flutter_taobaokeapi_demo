import 'dart:convert';
import 'package:sqflite/sqflite.dart';

Future<void> saveOrder(Map<String,dynamic> order,Database db) async{
  var detail = jsonEncode(order);
  var orderId = order['trade_id'];
  var status = int.parse(order['tk_status']);

  var list = await db.query('Orders',where: 'order_id=?',whereArgs: [orderId]);
  var values = <String,dynamic>{};

  if(list.length==0){
    var sTime = order['tk_create_time'];
    var time = DateTime.parse(sTime) ;
    values = {'order_id':orderId,'detail':detail,
      'y':time.year,'m':time.month,'d':time.day,'status':status,
      'create_time':time.microsecondsSinceEpoch};

    var ret = await db.insert('Orders', values);
    // print('insert >>');
    // print(ret);
  }else{
    values = {'detail':detail,'status':status};
    var ret = await db.update('Orders', values,where: 'order_id=?',whereArgs: [orderId]);
    // print('update >>');
    // print(ret);
  }
}
