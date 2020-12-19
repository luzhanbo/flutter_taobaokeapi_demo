import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      width: width-20,
      height: 34,
      // padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xffe8eaf0),
        borderRadius: BorderRadius.circular(17),
      ),
      alignment: Alignment.center,
      child: Wrap(
        children: [
          Icon(Icons.search,size: 20,color: Color(0xff3a3e45),),
          Text('请粘贴商品链接、名称或者淘口令',
            style: TextStyle(fontSize: 14,color: Color(0xff3a3e45)),)
        ],
      ),
    );
  }
}