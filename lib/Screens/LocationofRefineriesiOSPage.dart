import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';



import '../Model/ImportExportModel.dart';
import 'package:ppac/constant.dart';

import '../ConnectionUtil.dart';

import '../Response/CentralResponse.dart';
import '../Response/YearImportExportResponse.dart';
import '../SizeConfig.dart';


import '../Widgets/WebviewiOS.dart';

import 'InstalledRefiningCapacityiOS.dart';


class LocationofRefineriesiOSPage extends StatefulWidget {
  String menuname;
  String submenuname;

  LocationofRefineriesiOSPage(
      {required this.menuname, required this.submenuname});

  @override
  State<LocationofRefineriesiOSPage> createState() =>
      _LocationofRefineriesiOSPageState();
}

class _LocationofRefineriesiOSPageState
    extends State<LocationofRefineriesiOSPage> {
  StreamSubscription? connection;
  String exportfilename = "pdf";
  late FToast fToast;
  bool isLoading = true;

  List<TableContents> tableContents = [];

  bool isdataconnection = true;
  late Future<List<TableContents>> _func;
  final double _height = 1;

  bool ishtmlload = false;
  final _key = UniqueKey();
  List<CentralTab> centraltabList = [];
  List<objTab> tabList = [];

  // List<objTab> tabList = [];
  List<String> oilitem = [];
  List<String> stroilitemslug = [];
  List<String> goodsitem = [];
  late String petroloilSlug;
  late String crudeoilSlug;
  late String dieseloilSlug;
  late String nongstgoodsSlug;
  late String gstgoodsSlug;

  // String selectedYearValue = '2022-2023';
  List<String> yearList = [];
  List<String> viewDataIn = [];
  late String pagetitle;
  String reportFileName = '';
  String viewhistoryfile = '';
  String fileurl = '';
  List<TableContents> tableColContents = [];
  String? htmlContent = "";
  String pagecontentId = " ";
  String? menuname;
  String? SelectYear;
  String? SelectVieDataIn;
  String? SelectOilPrice;
  String? selectedGoods;

  String dropdownvalue = 'Crude Oil FOB Price';
  bool submitButtonIsEnabled = true;



  var Internetstatus = "Unknown";

  Future setStr(ishtml) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString("ishtml", ishtml);
  }

  Future<String?> getishtml() async {
    final prefs = await SharedPreferences.getInstance();
    htmlContent = prefs.getString("ishtml");
    return prefs.getString("ishtml");
  }

  Future<String?> getmenuname() async {
    final prefs = await SharedPreferences.getInstance();
    menuname = prefs.getString("SharedmenuName");
    ApiData.menuName = menuname.toString();
    print("prefmenuname:${menuname!}");
    return prefs.getString("SharedmenuName");
  }

  int selectedColumnCount = 0;

  int fetchimportexportcounter = 0;

  int dropdownslugcnt = 0;

  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connectionStatus.connectionChange.listen(connectionChanged);

    fToast = FToast();
    fToast.init(context);


    print("menuname:${widget.menuname}");
    print("submenuname:${widget.submenuname}");

    BackButtonInterceptor.add(myInterceptor);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected To The Internet";
        isdataconnection = true;
        print('Data connection is available.');

      } else if (!isdataconnection) {
        Internetstatus = "No Data Connection";
        isdataconnection = false;
        print('You are disconnected from the internet.');

      }
    });
  }

  showCustomToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey,
      ),
      child: const Text(
        "Downloading...",
        style: TextStyle(
          fontFamily: 'GraphikBlack',
          fontSize: 14,
          color: Color(0xffFFFFFF),
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      toastDuration: const Duration(seconds: 2),
      gravity: ToastGravity.BOTTOM,
      //fadeDuration: 2000,
    );
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    connection?.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("Back To Home Page");
    ApiData.gridclickcount = 0;
    if (["submenu"].contains(info.currentRoute(context))) return true;

    return false;
  }

  ScrollController horizontalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,

        body: Container(

            color: Colors.transparent,

            //203=Production
            child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // SizedBox(
                    //   height: 20,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    InstalledRefiningCapacityiOS(
                                      slugname:
                                          "infrastructure/installed-refinery-capacity",
                                      submenuname: widget.submenuname,
                                    )));
                          },
                          style: ElevatedButton.styleFrom(
                            primary: const Color(0xff085196),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0)),
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            minimumSize: const Size(151.92, 36),
                          ),
                          child: Wrap(
                            children: <Widget>[

                              SvgPicture.asset(
                                  "assets/images/file-arrow-down-solid.svg",
                                  width: 15,
                                  height: 15,
                                  color: Colors.white),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Download Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'GraphikMedium',
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      color: Colors.transparent,
                      // height: 400,
                      height: SizeConfig.safeBlockVertical * 65,
                      child: WebviewIOS(
                        slugname: Selectedslugname.slugname,
                      ),
                    ),
                  ],
                ))));
  }
}
