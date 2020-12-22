import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:taobaokeui/taobaokeui.dart';
import '../services/utils.dart';
import '../components/DetailComponent.dart';

class DetailPage extends StatefulWidget{
  DetailPage({Key key,this.item}):super(key: key);

  final Goods item;

  @override
  _DetailPageState createState() =>_DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<dynamic> _list = [];
  bool loaded = false;
  Goods item;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    _getRecommend();
  }

  _getRecommend() async{
    var tbClient = await getTbClient();
    var ret = await tbClient.search(q: item.categoryName);
    setState(() {
      if(ret["result_list"]!=null){
        var data = ret["result_list"]["map_data"];
        if(data is List<dynamic>){
          _list = ret["result_list"]["map_data"];
        }else if(data!=null){
          _list = [data];
        }
      }
    });
  }

  Widget _getListItem(BuildContext context,int index){
    if(index==0){
      return GoodsDetail(item: item,onBuy: _buy,);
    }else{
      var item = Goods.fromMap(_list[index-1] as Map<String,dynamic>);
      return GoodsListItem(item: item,onDetail: (String id,String shop){
        Navigator.of(context).pushReplacementNamed("/detail",arguments: item);
      },);
    }
  }
  Future<void> _buy(BuildContext context) async{
    var detail = item.detail;
    var url = item.couponAmount==0?detail['item_url']:detail['coupon_share_url'];
    var text = item.goodsName;
    var logo = item.goodsThumbnailUrl;
    var client = await getTbClient();
    var ret = await client.tkl(url: url,logo: logo,text:text);
    await Clipboard.setData(ClipboardData(text: ret));
    alert(context: context,content:'淘口令已粘贴，\n打开淘宝APP进行购买');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("商品详情"),
      ),
      body: ListView.builder(itemBuilder: _getListItem,itemCount: _list.length+1),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _buy(context);
        },
        child: Text('购买',style: TextStyle(fontSize: 14),),
      ),
    );
  }
}