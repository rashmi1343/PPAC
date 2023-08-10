
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:ppac/constant.dart';


import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';


import '../../Home/HomeDashboard.dart';

import '../SizeConfig.dart';
import 'WebHtml.dart';

class ExciseDutyScreen extends StatefulWidget {
  String slugname;

  ExciseDutyScreen({required this.slugname});
  @override
  ExciseDutyScreenState createState() {
    return ExciseDutyScreenState();
  }
}

class ExciseDutyScreenState extends State<ExciseDutyScreen> {

  bool isLoading = true;
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  var loadingPercentage = 0;
  late WebViewController _webViewController;
  var isdownload = false;
  String _progress = "-";
  var dio = Dio();

  @override
  void initState() {
    super.initState();
  }


  int index = 0;
  MediaQueryData? queryData;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print("size:$size");
    SizeConfig().init(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData!.devicePixelRatio;
    print("devicePixelRatio:$devicePixelRatio");
    return Stack(children: <Widget>[
      Container(
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/splash_background.jpg',
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
          backgroundColor: Colors.white.withOpacity(0.2),
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: 99,
            centerTitle: true,
            titleSpacing: 0.0,
            elevation: 1,
            title: Transform(
              // you can forcefully translate values left side using Transform
              transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
              child: Text(
                // 'Petroleum',
                "Excise duty on Export of Petrol, Diesel & ATF",
                softWrap: true,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontFamily: 'GraphikBold',
                  fontSize: 17,
                  color: Color(0xff243444),
                ),
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            backgroundColor: Colors.white,
            actions: <Widget>[
              Row(
                children: [
                  Container(
                    // padding: const EdgeInsets.only(left: 5),
                    margin: const EdgeInsets.only(right: 20),
                    height: 60,
                    width: 60,
                    child: Image.asset(
                      "assets/images/ppac_logo.png",
                    ),
                  ),
                ],
              ),
            ],
            leading: Builder(
              builder: (context) => Container(
                margin: const EdgeInsets.only(left: 10),
                child: IconButton(
                  alignment: Alignment.centerLeft,
                  icon: SvgPicture.asset(
                    "assets/images/arrow-left.svg",
                    color: const Color(0xff085196),
                    height: 21,
                    width: 24,
                  ),

                  onPressed: () {
                    ApiData.gridclickcount = 0;
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: screenHeight - keyboardHeight,
                      child: Column(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 15, top: 2),
                              width: double.infinity,
                              height: 50,
                              // color: const Color(0xffF3F3F3),
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                          text: 'Home',
                                          style: const TextStyle(
                                              color: Color(0xff085196),
                                              fontSize: 14,
                                              fontFamily: 'GraphikSemiBold'),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Platform.isIOS
                                                  ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      fullscreenDialog:
                                                      true,
                                                      builder: (context) =>
                                                      const HomeDashboard()))
                                                  : Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      fullscreenDialog:
                                                      true,
                                                      builder: (context) =>
                                                      const HomeDashboard()));
                                            }),
                                      WidgetSpan(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8),
                                            child: SvgPicture.asset(
                                              "assets/images/angle-right.svg",
                                              width: 15,
                                              height: 15,
                                              color: const Color(0xff085196),
                                            ),
                                          )),
                                      TextSpan(
                                          text: "Prices ",
                                          style: const TextStyle(
                                              color: Color(0xff111111),
                                              fontSize: 14,
                                              fontFamily: 'GraphikLight'),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // navigate to desired screen
                                            }),
                                      WidgetSpan(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8),
                                            child: SvgPicture.asset(
                                              "assets/images/angle-right.svg",
                                              width: 15,
                                              height: 15,
                                              color: const Color(0xff085196),
                                            ),
                                          )),
                                      TextSpan(
                                          text: "Excise duty on Export of Petrol, Diesel & ATF and Special Additional Excise Duty(SAED) on Domestic Crude Oil Production",
                                          style: const TextStyle(
                                              color: Color(0xff111111),
                                              fontSize: 13,
                                              fontFamily: 'GraphikLight'),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // navigate to desired screen
                                            }),
                                    ],
                                  ),
                                ]),
                              )),
                          SizedBox(
                            height: 10,
                          ),

                          Expanded(
                            child: Container(
                                height: Platform.isIOS
                                    ? SizeConfig.safeBlockVertical * 75
                                    : SizeConfig.safeBlockVertical * 76,
                                child: WebHtml(
                                  slugname: widget.slugname,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))
    ]);
  }
}
