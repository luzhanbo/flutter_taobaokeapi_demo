import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/index.dart';
import 'pages/search.dart';
import 'pages/detail.dart';
import 'store/global.dart';
import 'pages/order_detail.dart';
import 'pages/setting.dart';
import 'package:taobaokeui/taobaokeui.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 强制竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      return MultiProvider(providers: [
          ChangeNotifierProvider(create: (_)=>Global())
    ],child:MaterialApp(
      title: 'TaobaokeAPI Demo',
      routes: {
        "/search": (BuildContext context) {
          var params = ModalRoute.of(context).settings.arguments;
          return SearchPage(
            keyword: params,
          );
        },
        "/orderDetail": (BuildContext context) {
          var params = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          return OrderDetailPage( params);
        },
        "/detail": (BuildContext context) {
          var params =  ModalRoute.of(context).settings.arguments as Goods;
          return DetailPage(item:params);
        },
        "/setting": (BuildContext context) {
          var params = ModalRoute.of(context).settings.arguments;
          // print('to setting page-->>>');
          // print(params);
          return SettingPage(params);
        },
      },
      home: IndexPage(),
    ));
  }
}
