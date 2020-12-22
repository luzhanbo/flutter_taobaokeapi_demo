import 'package:flutter/material.dart';
import 'package:taobaokeui/taobaokeui.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:taobaokeui/components/SwiperPager.dart';
import 'package:cached_network_image/cached_network_image.dart';

var shopStyle = TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Color(0xff9197a3));

var oldStyle = TextStyle(fontSize:13,color: Color(0xff9197a3));
var dolaStyle = TextStyle(fontSize: 13,color: Color(0xffdf3c31));
var moneyStyle = TextStyle(fontSize:28,color: Color(0xffdf3c31));

typedef BuyAction = Future<void> Function (BuildContext context);

class GoodsPrice extends StatelessWidget {
  GoodsPrice(this.newPrice,this.oldPrice);

  final num oldPrice;
  final num newPrice;

  @override
  Widget build(BuildContext context) {
    var oldPriceStyle = TextStyle(fontSize:13,color: Color(0xff9197a3),decoration: TextDecoration.lineThrough);

    return Text.rich(TextSpan(
        text:"￥",style:dolaStyle,
        children: [
          TextSpan(text: "$newPrice",style: moneyStyle),
          TextSpan(text: "$oldPrice",style: oldPriceStyle),
        ]
    ));
  }
}
class GoodsRebate extends StatelessWidget {
  GoodsRebate(this.rebateUser,this.tip);

  final String tip;
  final num rebateUser;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(
        text: tip,
        style: oldStyle,
        children: [
          TextSpan(text:"￥",style:dolaStyle),
          TextSpan(text: "$rebateUser",style: moneyStyle),
        ]
    ));
  }
}

class GoodsTitle extends StatelessWidget {
  GoodsTitle(this.goodsName,this.shopType);
  final String goodsName;
  final String shopType;

  @override
  Widget build(BuildContext context) {
    var titleStyle = TextStyle(fontSize: 18,color: Color(0xff3a3e45));

    return Stack(children: [
      Text("    "+goodsName,style: titleStyle,maxLines: 2,overflow: TextOverflow.ellipsis,),
      Baseline(baseline: 22,baselineType: TextBaseline.alphabetic,
        child: Image.asset("images/icon/$shopType.png",height: 18,width: 18,),),
    ]);
  }
}

class GoodsCoupon extends StatelessWidget {
  GoodsCoupon(this.coupon,this.startDate,this.endDate,this.onBuy);

  final num coupon;
  final String startDate;
  final String endDate;
  final BuyAction onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(height: 80,
      margin: EdgeInsets.only(top:16,bottom: 16,left:8,right: 8),
      padding: EdgeInsets.only(top: 10,bottom: 10,left:10,right: 20),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit:BoxFit.fill,
              image: AssetImage("images/bg/coupon.png")
          )
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(
                text: "¥",
                style: TextStyle(fontSize: 14,color: Color(0xffdf3c31)),
                children: [
                  TextSpan(text: "$coupon",style: TextStyle(fontSize:32,color: Color(0xffdf3c31))),
                ]
            )),
            Text("使用期限 $startDate - $endDate",
              style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color:Color.fromRGBO(223,60,49,.5)),),
          ],),
        InkWell(
          // onTap: ,
          child: InkWell(
            onTap: (){
              onBuy(context);
            },
            child: Text("立即领取",style: TextStyle(fontSize: 18,color: Color(0xffdf3c31),fontWeight: FontWeight.bold),),
          ),
        ),
      ],),
    );
  }
}

class GoodsDetail extends StatelessWidget{
  GoodsDetail({Key key,this.item,this.onBuy}):super(key: key);

  final Goods item;
  final BuyAction onBuy;

  Widget _getSwiper(BuildContext context,urls){
    var width = MediaQuery.of(context).size.width;

    return  SizedBox(width: width,height: width,
        child: Swiper(itemCount: urls.length,
          autoplay: true,
          pagination: SwiperPager(),
          itemBuilder: (BuildContext context,int index){
            return CachedNetworkImage(imageUrl:urls[index],width: width,height: width,);
          },)
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(children: [
      _getSwiper(context,item.goodsGalleryUrls),
      Padding(padding: EdgeInsets.all(8),child:Column(children: [
        GoodsTitle(item.goodsName,item.shopType),
        Padding(padding: EdgeInsets.symmetric(vertical: 8),child:
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(item.shopTitle,style: shopStyle,),
          Text("销量 ${item.saleNum}",style: shopStyle,),
        ],),),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GoodsPrice(item.goodsPriceNew, item.goodsPriceOld),
          GoodsRebate(item.promotionAmount,'佣金'),
        ],),
        Offstage(offstage:item.couponAmount==0,
          child: GoodsCoupon(item.couponAmount,item.couponStartTime,item.couponEndTime,onBuy),),
      ],)),
      Container(height: 10,color: Color(0xfff6f7f8)),
      Container(height: 50,alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xffe8eaf0)))
        ),
        child: Text("更多宝贝推荐",style: TextStyle(fontSize: 18,color: Color(0xff3a3e45)),),)
    ],);
  }
}

