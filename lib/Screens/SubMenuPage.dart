import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:ppac/Widgets/GasPriceListnew.dart';
import 'package:ppac/constant.dart';
import 'package:http/http.dart' as http;
import 'package:ppac/Model/DashboardModel.dart';
import 'package:ppac/Screens/forecastanalysis.dart';
import 'package:ppac/Screens/reportstudies.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ConnectionUtil.dart';
import '../Home/gridcells.dart';
import '../Model/MainMenuModel.dart';

import 'DocumentViewPageNew.dart';

class SubMenuPage extends StatefulWidget {
  String menuname;
  String submenuname;

  SubMenuPage({required this.menuname, required this.submenuname});

  @override
  _SubMenuPageState createState() => _SubMenuPageState();
}

class _SubMenuPageState extends State<SubMenuPage> {
  StreamSubscription? connection;
  List<DashboardModel> gridCells = [];
  bool isdataconnection = false;

  final CarouselController _controller = CarouselController();

  bool isLoading = false;

  late Future<List<Menu>> submenuData;

  var Internetstatus = "Unknown";
  bool showProgress = false;
  double progress = 0.2;

  bool _progressBarActive = true;
  bool loading = false;
  List<Menu> menuDataArr = <Menu>[];

  Future<List<Menu>> fetchSubMenuData(String parentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? stringMenuname = prefs.getString('SharedmenuName');
      print("stored_menuname$stringMenuname");
      Map data = {
        'parent_id': parentId,
        'menugrp_id': '1',
        'method': 'getAllMenus'
      };
      print(' param_getAllMenus:$data');
      var body = utf8.encode(json.encode(data));
      var response = await http
          .post(Uri.parse(ApiConstant.url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${ApiData.token}",
              },
              body: body)
          .timeout(const Duration(seconds: 500));
      if (response.statusCode == 200) {
        print('response:$response.body');
        List jsonResponse = [];
        try {
          Map decoded = json.decode(response.body);

          if (decoded.length > 0) {
            jsonResponse = decoded["Menu"] as List;
            for (var objMenuTitle in decoded["Menu"]) {
              var menuTitle = objMenuTitle['name'];
              print("File Title:$menuTitle");
            }
            setState(() {
              isdataconnection = true;
              isLoading = true;
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

        return jsonResponse.map((job) => Menu.fromJson(job)).toList();
      } else {
        print('Error, Could not load Data.');
        throw Exception('Unable to fetch contents');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  @override
  void initState() {
    super.initState();

    submenuData = fetchSubMenuData(ApiData.subMenuID);

    print("MenuName${widget.menuname}");
    print("Submenuname ${widget.submenuname}");
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connectionStatus.connectionChange.listen(connectionChanged);

    BackButtonInterceptor.add(myInterceptor);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected TO The Internet";
        isdataconnection = true;
        print('Data connection is available.');
      } else if (!isdataconnection) {
        Internetstatus = "No Data Connection";
        isdataconnection = false;
        print('You are disconnected from the internet.');
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    ApiData.gridclickcount = 0;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    return isdataconnection
        ? RefreshIndicator(
            color: const Color(0xff085196),
            child: Stack(children: <Widget>[
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
                // appBar: AppBar(
                //   toolbarHeight: 99,
                //   centerTitle: false,
                //   titleSpacing: 0.0,
                //   elevation: 1,
                //   title: Transform(
                //     // you can forcefully translate values left side using Transform
                //     transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                //     child: Column(
                //       children: [
                //         Row(
                //           children: [
                //             Image.asset(
                //               "assets/images/ppac_logo_full.gif",
                //               height: 48,
                //               width: 200,
                //             ),
                //             SizedBox(
                //               width: 10,
                //             ),
                //             Image.asset(
                //               "assets/images/g20.png",
                //               height: 48,
                //               width: 100,
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                //   shape: const RoundedRectangleBorder(
                //     borderRadius: BorderRadius.only(
                //       bottomLeft: Radius.circular(20.0),
                //       bottomRight: Radius.circular(20.0),
                //     ),
                //   ),
                //   backgroundColor: Colors.white,
                //   // actions: <Widget>[
                //   //   Row(
                //   //     children: [
                //   //       Container(
                //   //         // padding: const EdgeInsets.only(left: 5),
                //   //         margin: const EdgeInsets.only(right: 10),
                //   //         height: 18,
                //   //         width: 18,
                //   //         child: SvgPicture.asset(
                //   //           "assets/images/magnifying-glass.svg",
                //   //           color: const Color(0xff111111),
                //   //         ),
                //   //       ),
                //   //     ],
                //   //   ),
                //   // ],
                //   leading: Builder(
                //     builder: (context) => Container(
                //       margin: const EdgeInsets.only(left: 10),
                //       child: IconButton(
                //         alignment: Alignment.centerLeft,
                //         icon: SvgPicture.asset(
                //           "assets/images/arrow-left.svg",
                //           color: const Color(0xff085196),
                //           height: 21,
                //           width: 24,
                //         ),
                //         // Image.asset(
                //         //   'assets/images/menuicon.png',
                //         // ),
                //         onPressed: () {
                //           ApiData.gridclickcount = 0;
                //           Navigator.pop(context);
                //         },
                //       ),
                //     ),
                //   ),
                // ),
                appBar: AppBar(
                  toolbarHeight: 99,
                  centerTitle: true,
                  titleSpacing: 0.0,
                  elevation: 1,
                  title: Transform(
                    transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                    child: widget.submenuname
                            .isNotEmpty //ApiData.submenuName.isNotEmpty
                        ? Text(
                            widget.submenuname, // ApiData.submenuName,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(
                              fontFamily: 'GraphikBold',
                              fontSize: 17,
                              color: Color(0xff243444),
                            ),
                          )
                        : Text(
                            widget.menuname,
                            softWrap: true,
                            overflow: TextOverflow.visible,
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
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        FutureBuilder<List<Menu>>(
                          future:
                              submenuData, // fetchSubMenuData(ApiData.subMenuID),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              print('isLoading:$isLoading');
                              return GridView.builder(
                                physics: const ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data?.length ?? 0,
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.all(5),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 1,
                                  mainAxisSpacing: 18,
                                  //  childAspectRatio: 2,
                                  mainAxisExtent: 150,
                                  crossAxisCount: 2,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: GridCell(
                                        snapshot.data?[index] ?? Menu(), index),
                                    onTap: () => gridClicked(
                                        index,
                                        snapshot.data![
                                            index]), //gridClicked(index),
                                  );
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}'); //Text(MESSAGES.INTERNET_ERROR);
                            }
                            return Center(
                                child: Container(
                              margin: EdgeInsets.only(top: 200),
                              child: CircularProgressIndicator(
                                  color: Color(0xff085196)),
                            ));
                          },
                        ),
                        const SizedBox(
                          //height:288,
                          height: 182,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
            onRefresh: () {
              return Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  fetchSubMenuData(ApiData.subMenuID);
                });
              });
            })
        : Container(
            margin:
                const EdgeInsets.only(left: 30, top: 30, right: 30, bottom: 50),
            height: 150,
            width: 300,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffD0D3D4),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.signal_wifi_statusbar_connected_no_internet_4,
                  size: 70,
                  color: Color(0xffAB0E1E),
                ),
                SizedBox(
                  height: 10,
                ),
                DefaultTextStyle(
                  style: TextStyle(decoration: TextDecoration.none),
                  child: Text(
                    'No Internet Connection Found! ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'GraphikMedium',
                      color: Color(0xffAB0E1E),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DefaultTextStyle(
                  style: TextStyle(decoration: TextDecoration.none),
                  child: Text(
                    'Please enable your internet ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GraphikThin',
                      color: Color(0xff243444),
                    ),
                  ),
                ),
              ],
            ));
  }

  gridClicked(int index, Menu data) {
    if (ApiData.gridclickcount == 0) {
      ApiData.gridclickcount = ApiData.gridclickcount + 1;
      print("gridclickcount:" + ApiData.gridclickcount.toString());
      isLoading = true;
      ApiData.subMenuID = data.menuId;
      Selectedslugname.slugname = data.slug;
      print('gridClicked : $index');
      print("submenuname${data.name}");

      getSubMenuData(data);
    }
  }

  getSubMenuData(Menu data) async {
    await fetchSubMenuData(ApiData.subMenuID)
        .then((value) => menuDataArr = value);
    print('menuDataArr: $menuDataArr');
    print("submenuname${data.name}");

//26=gas price
    if (data.nId == "26") {
      ApiData.gridclickcount = 0;

      Platform.isIOS
          ? Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const GasPriceListnew()))
              .then((_) {
              setState(() {
                isLoading = false;
              });
            })
          : Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  //   child: GasPriceDataList(),
                  child: GasPriceListnew(),
                  inheritTheme: true,
                  ctx: context),
            ).then((_) {
              setState(() {
                isLoading = false;
              });
            });
    } else if (menuDataArr.isEmpty) {
      ApiData.submenuName = data.name;

      print("empty${data.name}");
      if (ApiData.subMenuID != '126') {
        ApiData.gridclickcount = 0;

        Platform.isIOS
            ? ApiData.subMenuID == "268"
                ? _launchLPG(slugname: Selectedslugname.slugname)
                : Navigator.of(context)
                    .push(MaterialPageRoute(
                    builder: (context) => ApiData.subMenuID == "218"
                        ? forcastanalysis()
                        : ApiData.subMenuID == "201"
                            ? reportstudies()
                            : DocumentViewPageNew(
                                menuname: ApiData.menuName,
                                submenuname: ApiData.submenuName),
                  ))
                    .then((_) {
                    setState(() {
                      isLoading = false;
                    });
                  })
            : Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: ApiData.subMenuID == "218"
                        ? forcastanalysis()
                        : ApiData.subMenuID == "201"
                            ? reportstudies()
                            : ApiData.subMenuID == "268"
                                ? _launchLPG(
                                    slugname: Selectedslugname.slugname)
                                : DocumentViewPageNew(
                                    menuname: ApiData.menuName,
                                    submenuname: ApiData.submenuName),
                    inheritTheme: true,
                    ctx: context),
              ).then((_) {
                setState(() {
                  isLoading = false;
                });
              });
      } else {
        ApiData.gridclickcount = 0;
        _launchURL();
      }
    } else {
      ApiData.submenuName = "${ApiData.submenuName} ${data.name}";
      print("submenu${ApiData.submenuName}");

      setState(() {
        ApiData.gridclickcount = 0;

        Platform.isIOS
            ? Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => SubMenuPage(
                        menuname: widget.menuname, submenuname: data.name)))
                .then((_) {
                setState(() {
                  isLoading = false;
                  widget.submenuname = '';
                });
              })
            : Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: SubMenuPage(
                        menuname: widget.menuname, submenuname: data.name),
                    inheritTheme: true,
                    ctx: context),
              ).then((_) {
                setState(() {
                  isLoading = false;
                  widget.submenuname = '';
                });
              });
      });
    }
  }

  _launchURL() async {
    const url = 'https://iocl.com/prices-of-petroleum-products';

    var urllaunchable =
        await canLaunch(url); //canLaunch is from url_launcher package
    if (urllaunchable) {
      await launch(url); //launch is from url_launcher package to launch URL
    } else {
      print("URL can't be launched.");
    }
  }

  _launchLPG({required String slugname}) async {
    var url = "${ApiConstant.baseurl}$slugname";
    final encodedUrl = Uri.encodeFull(url);

    print("lpg url:$encodedUrl");

    var urllaunchable =
        await canLaunch(encodedUrl); //canLaunch is from url_launcher package
    if (urllaunchable) {
      await launch(
          encodedUrl); //launch is from url_launcher package to launch URL
    } else {
      print("URL can't be launched.");
    }
  }
}
