import 'package:flutter/material.dart';
import 'package:taobaokeui/taobaokeui.dart';
import '../services/utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key,this.shop="tb",@required this.keyword}):super(key: key);

  final String shop;
  final String keyword;
  @override
  _SearchPageState createState() =>_SearchPageState();

}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _list = [];
  int _pageNo = 1;
  int _pageSize = 20;
  bool finished = false;
  BuildContext _context;

  Widget _getListItem(BuildContext context, int index){
   var item = Goods.fromMap(_list[index] as Map<String,dynamic>);

   return GoodsListItem(item: item,
     onDetail: (String id,String shop){
       Navigator.of(context).pushNamed("/detail",arguments: item);
     },
   );
  }

  Widget _getListView(BuildContext context){
    return EasyRefresh(
        onLoad: _onLoad,
        onRefresh: _onRefresh,
        child: ListView.builder(  itemBuilder: _getListItem,  itemCount: _list.length)
    );
  }

  Future<void> _onRefresh() async{
    _pageNo = 1;
    await _search(refresh: true);
  }

  Future<void> _onLoad() async {
    _pageNo++;
    await _search();
  }

  _search({bool refresh=false}) async{
    var tbClient = await getTbClient();
    var tryTime = 0;

    while(tryTime<3) {
      var ret = await tbClient.search(q: widget.keyword,
          withCoupon: true,
          pageNo: _pageNo,
          pageSize: _pageSize);
      var errMsg = ret['sub_msg'] ?? ret['msg'];
      var code = ret['code'];
      var subCode = ret['sub_code'];
      if (errMsg != null) {
        if(code==15 && subCode==50001){
          print('retry search');
          continue;
        }else{
          print(ret);
          alert(context: _context, content: errMsg);
        }
      } else {
        setState(() {
          var list = ret["result_list"]["map_data"] as List<dynamic>;
          if (refresh || _list.length == 0) {
            _list = list;
          } else {
            _list.addAll(list);
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    Widget body;
    if(_list.length==0){
      _search();
      body = Center(
        child: Text("加载中..."),
      );
    }else{
      body = _getListView(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.keyword),
        actions: [
          IconButton(icon: Icon(Icons.help),onPressed: () async{
            alert(context: context,content: '查询需要设置siteId/adzoneId');
          },),
        ],
      ),
      body: body,
    );
  }
}