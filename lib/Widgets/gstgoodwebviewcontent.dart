import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:ppac/constant.dart';
import 'package:ppac/Response/CentralResponse.dart';
import 'package:ppac/Screens/WebHtml.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Home/HomeDashboard.dart';

class GstGoodWebViewContent extends StatefulWidget {
  String menuname;
  String submenuname;
  String pagetitle;
  String slugname;

  GstGoodWebViewContent(
      {required this.menuname,
      required this.submenuname,
      required this.pagetitle,
      required this.slugname});

  _GstGoodWebViewContentState createState() => _GstGoodWebViewContentState();
}

class _GstGoodWebViewContentState extends State<GstGoodWebViewContent> {
  String? menuname;
  String pagecontentId = " ";
  bool isLoading = true;

  @override
  void initState() {
    print("init webviewgst good");
    try {
      isLoading = true;

      fetchCentralData();
    } on Exception catch (e) {
      print("unable to load data");
      setState(() {
        isLoading = false;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Something went wrong.Please try again!!',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'GraphikRegular',
                fontSize: 15),
          ),
          backgroundColor: Color(0xff085196),
        ));
      });
    }

    super.initState();
  }

  void fetchCentralData() async {
    try {
      Map data = {
        'slug': Selectedslugname.slugname,
        'method': 'getImportExportcontent',
      };
      //encode Map to JSON
      print('param:$data');
      final prefs = await SharedPreferences.getInstance();
      menuname = prefs.getString("SharedmenuName");
      ApiData.menuName = menuname.toString();
      print("prefmenuname:${menuname!}");
      var body = utf8.encode(json.encode(data));
      var response = await http
          .post(Uri.parse(ApiConstant.url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${ApiData.token}",
              },
              body: body)
          .timeout(const Duration(seconds: 500));
      print("${response.statusCode}");
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          final centralData = centralResponseFromJson(response.body);

          TABULARPAGECONTENT.pagetitle =
              centralData.pageContents.pageTitle.toString();
          print("pagetitle:${TABULARPAGECONTENT.pagetitle}");

          TABULARPAGECONTENT.historyfilename =
              centralData.pageContents.historyUpload.toString();
          print("historyfilename:${TABULARPAGECONTENT.historyfilename}");

          TABULARPAGECONTENT.pagecontent =
              centralData.pageContents.pageContents!.replaceAll("\t\r", "");
          print("pagecontent:${TABULARPAGECONTENT.pagecontent}");

          TABULARPAGECONTENT.department =
              centralData.pageContents.department.toString();
          print("Page ID:$centralData.pageContents.id");

          /* SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('pagecontentid', centralData.pageContents.id);
*/
          pagecontentId = centralData.pageContents.id.toString();
          print("pagecontentid$pagecontentId");

          TABULARPAGECONTENT.tabs = centralData.tabs.toString();
          print('tabscontent:${TABULARPAGECONTENT.tabs}');

          /*if (centralData.tabs.isNotEmpty) {
            goodsitem = centralData.tabs;
          }
          if (centralData.tab.isNotEmpty) {
            centraltabList = centralData.tab;
          }*/

          isLoading = false;
        });
        //  return centralData;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                widget.pagetitle,
                softWrap: true,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontFamily: 'GraphikBold',
                  fontSize: 17,
                  color: Color(0xff243444),
                ),
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
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 2),
                    width: double.infinity,
                    height: 65,
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
                                                fullscreenDialog: true,
                                                builder: (context) =>
                                                    const HomeDashboard()))
                                        : Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType
                                                    .rightToLeft,
                                                child: HomeDashboard(),
                                                inheritTheme: true,
                                                ctx: context),
                                          );
                                  }),
                            WidgetSpan(
                                child: Container(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8),
                              child: SvgPicture.asset(
                                "assets/images/angle-right.svg",
                                width: 15,
                                height: 15,
                                color: const Color(0xff085196),
                              ),
                            )),
                            // TextSpan(
                            //     text: ApiData.menuName,
                            //     style: const TextStyle(
                            //         color: Color(0xff111111),
                            //         fontSize: 14,
                            //         fontFamily: 'GraphikLight'),
                            //     recognizer: TapGestureRecognizer()
                            //       ..onTap = () {
                            //         // navigate to desired screen
                            //       }),

                            widget.menuname.isNotEmpty
                                ? TextSpan(children: <TextSpan>[
                                    TextSpan(children: [
                                      TextSpan(
                                          text: widget.menuname,
                                          style: const TextStyle(
                                              color: Color(0xff111111),
                                              fontSize: 13,
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
                                          text: widget.submenuname,
                                          style: const TextStyle(
                                              color: Color(0xff111111),
                                              fontSize: 13,
                                              height: 1.2,
                                              fontFamily: 'GraphikLight'),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              // navigate to desired screen
                                            }),
                                    ])
                                  ])
                                : TextSpan(
                                    text: widget.submenuname,
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

                Expanded(
                  child: SizedBox(
                      height: 350,
                      child: WebHtml(
                        slugname: widget.slugname,
                      )

                      ),
                )
              ],
            ),
          ))
    ]);
  }
}
