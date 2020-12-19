import 'package:flutter/material.dart';

const orderFieldNames = ['adzone_id','adzone_name','alimama_rate','alimama_share_fee','alipay_total_price','click_time','deposit_price','flow_source','income_rate','is_lx','item_category_name','item_id','item_img','item_link','item_num','item_price','item_title','order_type','pub_id','pub_share_fee','pub_share_pre_fee','pub_share_rate','refund_tag','seller_nick','seller_shop_title','site_id','site_name','subsidy_fee','subsidy_rate','subsidy_type','tb_deposit_time','tb_paid_time','terminal_type','tk_commission_fee_for_media_platform','tk_commission_pre_fee_for_media_platform','tk_commission_rate_for_media_platform','tk_create_time','tk_deposit_time','tk_order_role','tk_paid_time','tk_status','tk_total_rate','total_commission_fee','total_commission_rate','trade_id','trade_parent_id'];

class OrderDetailPage extends StatelessWidget {
  final Map<String,dynamic> item;
  OrderDetailPage(this.item);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('订单详情'),
      ),
      body: ListView.separated(itemCount: orderFieldNames.length,
        itemBuilder: (BuildContext context,int index){
        return ListTile(leading: Icon(Icons.reorder), title: Text(orderFieldNames[index]),subtitle: Text(item[orderFieldNames[index]]),);
      },separatorBuilder: (BuildContext context,int index){
        return Divider();
        },),
    );
  }
}