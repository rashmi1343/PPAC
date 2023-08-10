import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:ppac/Home/HomeDashboard.dart';
import 'package:ppac/Model/ppactrackermodel.dart';
import 'package:ppac/constant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../SizeConfig.dart';

class ppacnewspage extends StatefulWidget {
  @override
  ppacnewspageState createState() {
    return ppacnewspageState();
  }
}

class ppacnewspageState extends State<ppacnewspage> {
  List<ppacnewsmodel> arrppacnews = [];
  bool isdataconnection = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getreportstudiesfromapi(ApiConstant.url);
  }

  Future<List<ppacnewsmodel>> getreportstudiesfromapi(String url) async {
    try {
      Map data = {'method': 'getdetails', 'type': 'PPAC News'};
      var body = utf8.encode(json.encode(data));

      var response = await http
          .post(Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${ApiData.token}",
              },
              body: body)
          .timeout(const Duration(seconds: 500));

      print("response:${response.statusCode}");

      if (response.statusCode == 200) {
        try {
          Map decoded = json.decode(response.body);

          if (decoded.length > 0) {
            print("decoded:$decoded");
            arrppacnews = [];
            for (var objppacnews in decoded["PPAC News"]) {
              arrppacnews.add(ppacnewsmodel(
                  id: int.parse(objppacnews['id']),
                  newstitle: objppacnews['title'],
                  newsurl: objppacnews['url'],
                  newsperiod: objppacnews['created_date']));
            }
            setState(() {
              isdataconnection = true;
              isLoading = false;
            });
          } else {
            setState(() {
              isdataconnection = true;
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
        } on Exception catch (e) {
          print("unable to load data");
          setState(() {
            isdataconnection = true;
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

        return arrppacnews;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
            transform: Matrix4.translationValues(0.0, 0.0, 0.0),
            child: Text(
              "PPAC In News",
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
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    width: double.infinity,
                    height: 58,

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
                            TextSpan(
                                text: "PPAC In News",
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
                isLoading
                    ? Container(
                        margin: EdgeInsets.only(top: 200),
                        child: const CircularProgressIndicator(
                            color: Color(0xff085196)))
                    : Container(

                        height: Platform.isIOS
                            ? SizeConfig.safeBlockVertical * 75
                            : SizeConfig.safeBlockVertical * 78,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10),
                            physics: const ScrollPhysics(),
                            itemCount: arrppacnews.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Center(
                                child: Card(
                                  elevation: 20,
                                  shadowColor: Colors.black,
                                  color: Colors.white,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: Platform.isIOS ? null : 153,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0, top: 10.0),
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/images/calendar-solid.svg",
                                                    width: 20,
                                                    height: 20,
                                                    color: Color(0xff085196),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    child: Text(
                                                      arrppacnews[index]
                                                          .newsperiod
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              "GraphikRegular"), //Textstyle
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 9,
                                              ),
                                              Text(
                                                arrppacnews[index]
                                                    .newstitle
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        "GraphikMedium"), //Textstyle
                                              ), //Text
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                padding: EdgeInsets.only(
                                                  bottom: 5,
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () {

                                                    ApiData.pdfUrl =
                                                        arrppacnews[index]
                                                            .newsurl
                                                            .replaceAll(
                                                                ' ', '%20');

                                                    print(ApiData.pdfUrl);


                                                    if (arrppacnews[index]
                                                        .newsurl
                                                        .isNotEmpty) {


                                                      print("url:" +
                                                          ApiData.pdfUrl);
                                                      ApiConstant.launchURL(
                                                          ApiData.pdfUrl);
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xff085196),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0)),
                                                    textStyle: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    minimumSize:
                                                        const Size(151.92, 36),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [

                                                      Icon(Icons.visibility),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        'View News',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'GraphikMedium',
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
              ],
            ),
          ),
        ),
      )
    ]);
  }

}
