import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:page_transition/page_transition.dart';

import 'package:ppac/Screens/WebHtml.dart';

import 'package:ppac/SizeConfig.dart';
import 'package:ppac/Widgets/PpacchartExpandable.dart';

import 'package:ppac/Widgets/webviewcontent.dart';

import 'package:shared_preferences/shared_preferences.dart';


import '../Home/HomeDashboard.dart';
import '../Model/ImportExportModel.dart';
import 'package:ppac/constant.dart';

import 'package:http/http.dart' as http;

import 'package:pdf/widgets.dart' as pw;
import '../ConnectionUtil.dart';

import '../Response/CentralResponse.dart';
import '../Response/YearImportExportResponse.dart';


import '../Widgets/WebviewiOS.dart';

import 'ContentViewPage.dart';
import 'DemoListView.dart';


import 'LocationofRefineriesPage.dart';
import 'LocationofRefineriesiOSPage.dart';


import 'gstgoods.dart';



final pdf = pw.Document();

class Items {
  String title;
  String selectedYear;
  List<String> selectedDatain;
  String selectedOilPrice;
  String selectedGoods;

  Items({
    required this.title,
    required this.selectedYear,
    required this.selectedDatain,
    required this.selectedOilPrice,
    required this.selectedGoods,
  });
}

class DocumentViewPageNew extends StatefulWidget {
  String menuname;
  String submenuname;

  DocumentViewPageNew({required this.menuname, required this.submenuname});

  @override
  State<DocumentViewPageNew> createState() => _DocumentViewPageNewState();
}

class _DocumentViewPageNewState extends State<DocumentViewPageNew> {
  StreamSubscription? connection;
  String exportfilename = "pdf";
  late FToast fToast;
  bool isLoading = true;
  List<Items> item = <Items>[];

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
  String? year;

// Initial Selected Value
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

  Future<ImportExportModel> fetchImportExportData() async {
    late ImportExportModel importExportData;

    Map data = {
      'slug': Selectedslugname.slugname,
      'method': 'getImportExportcontent',
    };
    //encode Map to JSON
    print('param:$data');
    final prefs = await SharedPreferences.getInstance();
    menuname = prefs.getString("SharedmenuName");
    ApiData.menuName = menuname.toString();
    // print("prefmenuname:${menuname}");
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
      try {
        importExportData = importExportModelFromJson(response.body);

        if (importExportData.htmlcontent == "True") {
          print("htmlcontent is true");
          htmlContent = "true";
          ishtmlload = true;
          setStr(htmlContent);

        } else {
          print("htmlcontent is false");
          htmlContent = "false";
          ishtmlload = false;
          setStr(htmlContent);

        }
        TABULARPAGECONTENT.pagetitle = importExportData.pageContents.pageTitle!;
        print("pagetitle:${TABULARPAGECONTENT.pagetitle}");

        TABULARPAGECONTENT.pagename = importExportData.pageContents.pageName!;
        print("pagetitle:${TABULARPAGECONTENT.pagename}");

        TABULARPAGECONTENT.historyfilename =
        importExportData.pageContents.historyUpload!;
        print("historyfilename:${TABULARPAGECONTENT.historyfilename}");

        TABULARPAGECONTENT.pagecontent =
            importExportData.pageContents.pageContents!.replaceAll("\t\r", "");
        print("pagecontent:${TABULARPAGECONTENT.pagecontent}");

        TABULARPAGECONTENT.department =
        importExportData.pageContents.department!;
        print("Page ID:$importExportData.pageContents.id");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('pagecontentid', importExportData.pageContents.id!);

        pagecontentId = importExportData.pageContents.id!;
        print("pagecontentid$pagecontentId");

        TABULARPAGECONTENT.tabs = importExportData.tabs.toString();
        print('tabscontent:${TABULARPAGECONTENT.tabs}');

        TABULARPAGECONTENT.baseurl =
            importExportData.pageContents.baseurl.toString();
        print('baseurl:${TABULARPAGECONTENT.baseurl}');

        setState(() {
          submitButtonIsEnabled = false;
        });

        if (fetchimportexportcounter == 0) {
          setState(() {
            yearList = importExportData.yearList;

            viewDataIn = importExportData.viewDataIn;

            item.add(Items(
                title: 'Data for Crude and Products-\nin Quantity',
                selectedYear: yearList[0],
                selectedDatain: viewDataIn,
                selectedOilPrice: 'Crude Oil FOB Price',
                selectedGoods: 'Non-GST Goods'));


            fileurl = importExportData.pageContents.baseurl.toString();
            viewhistoryfile = importExportData.pageContents.historyUpload!;

            if (importExportData.tabs.isNotEmpty) {
              oilitem = importExportData.tabs;
            }
            if (importExportData.strTab.isNotEmpty) {
              stroilitemslug = importExportData.strTab;
            }

            if (importExportData.tab.isNotEmpty) {
              tabList = importExportData.tab;
            }




            print("yearList:${yearList[0]}");
            print("viewDataIn:$viewDataIn");
            print("oilitem:$oilitem");
            print("stroilitemslug:$stroilitemslug");
            print("tabList:$tabList");
            print("History File Name:$viewhistoryfile");

            if (!ishtmlload) {

              SelectedYear = yearList[0].toString();
              SelectedQty = "(\$/bbl.)";
              SelectedOilPrice = 'Crude Oil FOB Price';
              selectedGoods = 'Non-GST Goods';
            }

            // Setting default values for dropdowns
            if (ApiData.subMenuID == '115') {
              SelectedYear = yearList[0].toString();
              SelectedQty = "(\$/bbl.)";
              SelectedOilPrice = 'Crude Oil FOB Price';
            } else {
              if (viewDataIn.isNotEmpty) {
                SelectedYear = yearList[0].toString();
                SelectedQty = viewDataIn[0];
              } else {
                SelectedYear = yearList[0].toString();
                SelectedQty = 'Quantity (\'000 Metric Tonnes)';
              }
            }

            isLoading = false;
          });
        }
      } on Exception catch (e) {
        print("unable to load data");
        setState(() {
          isdataconnection = true;
          isLoading = false;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Some thing Went Wrong Please Try Again'),
            backgroundColor: Color(0xff085196),
          ));
        });
      }
    } else {
      throw Exception('Failed to load');
    }
    return importExportData;
  }



  Future<List<TableContents>> fetchSummarydefault() async {

    Map jsonMap = {
      'year': SelectedYear,
      'viewdata': SelectedQty,
      'pageid': pagecontentId,
      'method': 'getImportExports'
    };

    print(' param_getimportexport:$jsonMap');
    var body = utf8.encode(json.encode(jsonMap));
    final response =
    await http.post(Uri.parse(ApiConstant.url), body: body, headers: {
      'Accept': 'application/json',
      "Authorization": "Bearer ${ApiData.token}",
    });
    if (response.statusCode == 200) {
      print('response:$response.body');
      Map decoded = json.decode(response.body);

      List jsonResponse = decoded["TableContents"] as List;
      for (var objtblcontent in decoded["TableContents"]) {
        reportFileName = objtblcontent['report_file_name'];
        print("File Name:$reportFileName");

        if (objtblcontent['cols'] == "True") {
          tableContents.add(TableContents(
              productTitle: objtblcontent['product_title'],
              reportFileName: objtblcontent['report_file_name'],
              createdAt: objtblcontent['created_at'],
              updatedAt: objtblcontent['updated_at'],
              rdId: objtblcontent['rd_id'],
              april: objtblcontent['april'],
              may: objtblcontent['may'],
              june: objtblcontent['june'],
              july: objtblcontent['july'],
              august: objtblcontent['august'],
              september: objtblcontent['september'],
              october: objtblcontent['october'],
              november: objtblcontent['november'],
              december: objtblcontent['december'],
              january: objtblcontent['january'],
              february: objtblcontent['february'],
              march: objtblcontent['march'],
              total: objtblcontent['total'],
              cols: true,
              reportId: objtblcontent['report_id']));
        } else {
          tableContents.add(TableContents(
              productTitle: objtblcontent['product_title'],
              reportFileName: objtblcontent['report_file_name'],
              createdAt: objtblcontent['created_at'],
              updatedAt: objtblcontent['updated_at'],
              rdId: objtblcontent['rd_id'],
              april: objtblcontent['april'],
              may: objtblcontent['may'],
              june: objtblcontent['june'],
              july: objtblcontent['july'],
              august: objtblcontent['august'],
              september: objtblcontent['september'],
              october: objtblcontent['october'],
              november: objtblcontent['november'],
              december: objtblcontent['december'],
              january: objtblcontent['january'],
              february: objtblcontent['february'],
              march: objtblcontent['march'],
              total: objtblcontent['total'],
              cols: false,
              reportId: objtblcontent['report_id']));
        }
      }


      return tableContents;
    } else {
      print('Error, Could not load Data.');
      throw Exception('Unable to fetch contents');
    }
  }



  @override
  void initState() {
    super.initState();

    try {
      ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
      connectionStatus.initialize();
      connectionStatus.connectionChange.listen(connectionChanged);

      fToast = FToast();
      fToast.init(context);

      fetchImportExportData();

      print("menuname:${widget.menuname}");
      print("submenuname:${widget.submenuname}");
      print("subMenuID:${ApiData.subMenuID}");

      BackButtonInterceptor.add(myInterceptor);
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

  bool _isCurrentYearVisible = true;
  bool _isVisible = false;
  bool _tabVisible = false;
  bool _isDatatableVisible = false;
  int selected = 0;
  int selectedIndex = -1;
  String SelectedYear = '';


  String SelectedQty = 'Quantity (\'000 Metric Tonnes)'; //'';
  String SelectedOilPrice = '';
  ScrollController horizontalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));

    SizeConfig().init(context);
    return isdataconnection
        ? isLoading
        ? Scaffold(
        body: Center(
            child: CircularProgressIndicator(
              color: Color(0xff085196),
            )))
        : Stack(children: <Widget>[
      Container(
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/splash_background.jpg',
          height: MediaQuery
              .of(context)
              .size
              .height,
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
            child: ApiData.subMenuID == "124"
                ? Text(
              // 'Petroleum',
              "Retail Selling Price (RSP) of Petrol, Diesel and Domestic LPG",
              softWrap: true,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontFamily: 'GraphikBold',
                fontSize: 17,
                color: Color(0xff243444),
              ),
            )
                : ApiData.subMenuID == "125"
                ? Text(
              // 'Petroleum',
              "Retail Selling Price (RSP) of Petrol, Diesel and Domestic LPG",
              softWrap: true,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontFamily: 'GraphikBold',
                fontSize: 17,
                color: Color(0xff243444),
              ),
            )
                : ApiData.subMenuID == "127"
                ? Text(
              // 'Petroleum',
              "Retail Selling Price (RSP) of Petrol, Diesel and Domestic LPG",
              softWrap: true,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontFamily: 'GraphikBold',
                fontSize: 17,
                color: Color(0xff243444),
              ),
            )
                : ApiData.subMenuID == "192"
                ? Text(
              // 'Petroleum',
              "Import/Export",
              softWrap: true,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontFamily: 'GraphikBold',
                fontSize: 17,
                color: Color(0xff243444),
              ),
            )
                : ApiData.subMenuID == "129"
                ? Text(
              // 'Petroleum',
              "Subsidies/ Under Recoveries to Oil Marketing Companies (OMCs) on Sale of Sensitive  Petroleum Products (Rs. Crore)",
              softWrap: true,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontFamily: 'GraphikBold',
                fontSize: 14,
                color: Color(0xff243444),
              ),
            )
                :ApiData.subMenuID == "128"
                ? Text(
              // 'Petroleum',
              "Fiscal Subsidy on Public Distribution System (PDS) Kerosene and Domestic LPG (Rs. Crore)",
              softWrap: true,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontFamily: 'GraphikBold',
                fontSize: 14,
                color: Color(0xff243444),
              ),
            )
                :ApiData.subMenuID == "130"
                ? Text(
              // 'Petroleum',
              "Subsidy on Sale of Administered Price Mechanism (APM) Natural Gas in North East Region",
              softWrap: true,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontFamily: 'GraphikBold',
                fontSize: 14,
                color: Color(0xff243444),
              ),
            )
                : Text(
              // 'Petroleum',
              widget.submenuname,
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
            builder: (context) =>
                Container(
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
          physics: ApiData.subMenuID == "134"
              ? NeverScrollableScrollPhysics()
              : ScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ApiData.subMenuID == "116"
                    ? Container()
                    : ApiData.subMenuID == "118"
                    ? Container()
                    : ApiData.subMenuID == "119"
                    ? Container()
                    : Container(
                    margin: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 15,
                    ),
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
                                    color:
                                    Color(0xff085196),
                                    fontSize: 14,
                                    fontFamily:
                                    'GraphikSemiBold'),
                                recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    Platform.isIOS
                                        ? Navigator.of(context).push(
                                        MaterialPageRoute(
                                            fullscreenDialog:
                                            true,
                                            builder:
                                                (context) =>
                                            const HomeDashboard()))
                                        : Navigator
                                        .push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType
                                              .rightToLeft,
                                          child:
                                          HomeDashboard(),
                                          inheritTheme:
                                          true,
                                          ctx:
                                          context),
                                    );
                                  }),
                            WidgetSpan(
                                child: Container(
                                  padding:
                                  const EdgeInsets.only(
                                      left: 8.0,
                                      right: 8),
                                  child: SvgPicture.asset(
                                    "assets/images/angle-right.svg",
                                    width: 15,
                                    height: 15,
                                    color: const Color(
                                        0xff085196),
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
                                ? TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      children: [
                                        ApiData.subMenuID ==
                                            "262"
                                            ? TextSpan(
                                            text:
                                            "Natural Gas",
                                            style: const TextStyle(
                                                color: Color(0xff111111),
                                                fontSize: 13,
                                                fontFamily: 'GraphikLight'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // navigate to desired screen
                                              })
                                            : ApiData.subMenuID == "128"
                                            ? TextSpan(
                                            text: "Subsidy",
                                            style: const TextStyle(
                                                color: Color(0xff111111),
                                                fontSize: 13,
                                                fontFamily: 'GraphikLight'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // navigate to desired screen
                                              })
                                            : ApiData.subMenuID == "129"
                                            ? TextSpan(
                                            text: "Subsidy",
                                            style: const TextStyle(
                                                color: Color(0xff111111),
                                                fontSize: 13,
                                                fontFamily: 'GraphikLight'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // navigate to desired screen
                                              })
                                            : ApiData.subMenuID == "130"
                                            ? TextSpan(
                                            text: "Subsidy",
                                            style: const TextStyle(
                                                color: Color(0xff111111),
                                                fontSize: 13,
                                                fontFamily: 'GraphikLight'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // navigate to desired screen
                                              })
                                            : ApiData.subMenuID == "124"
                                            ? TextSpan(
                                            text: "Retail Selling Price (RSP) of Petrol, Diesel and Domestic LPG",
                                            style: const TextStyle(
                                                color: Color(0xff111111),
                                                fontSize: 13,
                                                fontFamily: 'GraphikLight'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // navigate to desired screen
                                              })
                                            : ApiData.subMenuID == "125"
                                            ? TextSpan(
                                            text: "Retail Selling Price (RSP) of Petrol, Diesel and Domestic LPG",
                                            style: const TextStyle(
                                                color: Color(0xff111111),
                                                fontSize: 13,
                                                fontFamily: 'GraphikLight'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // navigate to desired screen
                                              })
                                            : ApiData.subMenuID == "127"
                                            ? TextSpan(
                                            text: "Retail Selling Price (RSP) of Petrol, Diesel and Domestic LPG",
                                            style: const TextStyle(
                                                color: Color(0xff111111),
                                                fontSize: 13,
                                                fontFamily: 'GraphikLight'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // navigate to desired screen
                                              })
                                            : TextSpan(
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
                                            child:
                                            Container(
                                              padding: const EdgeInsets
                                                  .only(
                                                  left:
                                                  8.0,
                                                  right:
                                                  8),
                                              child: SvgPicture
                                                  .asset(
                                                "assets/images/angle-right.svg",
                                                width:
                                                15,
                                                height:
                                                15,
                                                color: const Color(
                                                    0xff085196),
                                              ),
                                            )),
                                        TextSpan(
                                            text: widget
                                                .submenuname,
                                            style: const TextStyle(
                                                color: Color(
                                                    0xff111111),
                                                fontSize:
                                                13,
                                                height:
                                                1.2,
                                                fontFamily:
                                                'GraphikLight'),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // navigate to desired screen
                                              }),
                                      ])
                                ])
                                : TextSpan(
                                text: widget
                                    .submenuname,
                                style: const TextStyle(
                                    color: Color(
                                        0xff111111),
                                    fontSize: 13,
                                    fontFamily:
                                    'GraphikLight'),
                                recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    // navigate to desired screen
                                  }),

                          ],
                        ),
                      ]),
                    )),

                SizedBox(
                  height: 20,
                ),

                Center(
                  child: ListView.builder(
                      key: Key('builder ${selected.toString()}'),
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,

                      // itemCount: item.length,
                      itemCount: item.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Column(children: <Widget>[

                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // const SizedBox(
                              //   height: 10,
                              // ),

                              ishtmlload
                                  ? Container(
                                   height: SizeConfig.safeBlockVertical *
                                      78,
                                  width: Platform.isAndroid
                                      ? SizeConfig.safeBlockHorizontal *
                                      95
                                      : null, //10 for example

                                  color: Colors.transparent,

                                  //203=Production
                                  child: ApiData.subMenuID ==
                                      "203"
                                      ?
                                   ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT
                                          .baseurl,
                                      viewhistoryfile:
                                      viewhistoryfile,
                                      pageContent:
                                      TABULARPAGECONTENT
                                          .pagecontent)

                                 //136=State wise
                                      : ApiData.subMenuID == "136"
                                      ?
                                     ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT
                                          .baseurl,
                                      viewhistoryfile:
                                      viewhistoryfile,
                                      pageContent:
                                      TABULARPAGECONTENT
                                          .pagecontent)

                                   //57=Pipeline Structure
                                      : ApiData.subMenuID ==
                                      "57"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT
                                          .baseurl,
                                      viewhistoryfile:
                                      viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                      //147=City Gas Distribution Network
                                      : ApiData.subMenuID ==
                                      "147"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)

                                 //137=LPG Distributors //LNG Import
                                      : ApiData.subMenuID == "137"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)

                                  //138=SKO/LDO Dealership
                                      : ApiData.subMenuID == "138"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)

                                   //139=Retail Outlets
                                      : ApiData.subMenuID == "139"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)

                                    //128=Fiscal Subsidy on Public Distribution System (PDS) Kerosene and Domestic LPG (Rs. Crore)
                                      : ApiData.subMenuID == "128"

                                  // ? MyWebViewNew()
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                    //129=Subsidies/ Under recoveries to Oil Marketing Companies (OMCs) on Sale of Sensitive  Petroleum Products (Rs. Crore)
                                      : ApiData.subMenuID == "129"
                                  //? MyWebViewNew()
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                  //130=Subsidy on sale of Administered Price Mechanism (APM) natural gas in North East Region
                                      : ApiData.subMenuID == "130"
                                  // ? MyWebViewNew()
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                  //224=State wise PMUY data
                                      : ApiData.subMenuID == "224"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                 //248=Active Domestic Customers
                                      : ApiData.subMenuID == "248"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                   //116=Central Excise and Customs Rate on Major Petroleum Products
                                      : ApiData.subMenuID == "116"
                                      ? GstGoods(menuname: widget.menuname,
                                      submenuname: widget.submenuname)
                                  //118=Contribution
                                      : ApiData.subMenuID == "118"
                                      ? GstGoods(menuname: widget.menuname,
                                      submenuname: widget.submenuname)
                                  //119=Dealers/Distributors Commission on Petrol, Diesel
                                      : ApiData.subMenuID == "119"
                                      ? GstGoods(menuname: widget.menuname,
                                      submenuname: widget.submenuname)
                                  //120=Petroleum Prices and Under recoveries
                                      : ApiData.subMenuID == "120"
                                      ?
                                      ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                  //124=RSP of Petrol and Diesel in metro cities since 16.6.2017
                                      : ApiData.subMenuID == "124"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)

                                  //127=Price Build up of Petrol and Diesel
                                      : ApiData.subMenuID == "127"
                                      ? ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                    //193=History
                                      : ApiData.subMenuID == "193"
                                      ?

                                  ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                       : ApiData.subMenuID == "63"
                                      ?
                                   Webview(slugname: Selectedslugname.slugname)
                                    //25=import
                                      : ApiData.subMenuID == "262"
                                      ?
                                   ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                  //25=LNG import
                                      : ApiData.subMenuID == "25"
                                      ?
                                  ContentViewPage(
                                      baseUrl: TABULARPAGECONTENT.baseurl,
                                      viewhistoryfile: viewhistoryfile,
                                      pageContent: TABULARPAGECONTENT
                                          .pagecontent)
                                 //236=Organization Chart
                                      : ApiData.subMenuID == "236"
                                  //  ? OrganizationChart()
                                      ?
                                  // Platform.isIOS
                                  //     ? WebviewIOS(slugname: Selectedslugname.slugname) //Webview()
                                  //     :
                                  /* WebHtml(
                                                                                                                                                slugname: Selectedslugname.slugname,
                                                                                                                                              )*/
                                  //   ppacorgchart()
                                  PpacchartExpandable()
                                      : ApiData.subMenuID ==
                                      "134" // Location of refineries
                                  //  ? InfrastructurePage(  slugname: Selectedslugname.slugname,)
                                      ? Platform.isIOS
                                      ? LocationofRefineriesiOSPage(
                                    menuname: widget.menuname,
                                    submenuname: widget.submenuname,
                                  ) // WebviewIOS(slugname: Selectedslugname.slugname) //Webview()
                                      : LocationofRefineriesPage(
                                    menuname: widget.menuname,
                                    submenuname: widget.submenuname,
                                  )

                                      : ApiData.subMenuID == "239"
                                      ? Platform.isIOS
                                      ? WebviewIOS(slugname: Selectedslugname
                                      .slugname) //Webview()
                                      : Webview(
                                      slugname: Selectedslugname.slugname)
                                  //234=Vission Mission
                                      : ApiData.subMenuID == "234"
                                      ? Platform.isIOS
                                      ? WebviewIOS(slugname: Selectedslugname
                                      .slugname) //Webview()
                                      : Webview(
                                      slugname: Selectedslugname.slugname)
                                   //235=Mandate
                                      : ApiData.subMenuID == "235"
                                      ? Platform.isIOS
                                      ? WebviewIOS(slugname: Selectedslugname
                                      .slugname) //Webview()
                                      : Webview(
                                      slugname: Selectedslugname.slugname)
                                    //237=Governing Body
                                      : ApiData.subMenuID == "237"
                                      ? Platform.isIOS
                                      ? WebviewIOS(slugname: Selectedslugname
                                      .slugname) //Webview()
                                      : Webview(
                                      slugname: Selectedslugname.slugname)
                                     //238=Formation
                                      : ApiData.subMenuID == "238"
                                      ? Platform.isIOS
                                      ? WebviewIOS(slugname: Selectedslugname
                                      .slugname) //Webview()
                                      : Webview(
                                      slugname: Selectedslugname.slugname)
                                   //117=VAT/Sales-Tax/GST Rates
                                      : ApiData.subMenuID == "117"
                                      ? Webview(
                                      slugname: Selectedslugname.slugname)
                                   //108=Installed Refinery Capacity
                                      : ApiData.subMenuID == "108"
                                      ? Platform.isIOS
                                      ? WebviewIOS(slugname: Selectedslugname
                                      .slugname) //Webview()
                                      :
                                  //   Webview()
                                  WebHtml(
                                    slugname: Selectedslugname.slugname,
                                  )
                                  //  125=RSP of Petrol and Diesel at Delhi up to 15.6.2017
                                      : ApiData.subMenuID == "125"
                                      ? Webview(
                                      slugname: Selectedslugname.slugname)
                                      : Webview(
                                      slugname: Selectedslugname.slugname))
                                  : Center(
                                child: Column(
                                  children: [
                                      ApiData.subMenuID == '115'
                                        ? Container(
                                      alignment: Alignment
                                          .center,
                                      margin:
                                      const EdgeInsets
                                          .only(
                                          left: 10.0,
                                          top: 10,
                                          bottom: 10,
                                          right: 10),
                                      padding:
                                      const EdgeInsets
                                          .all(10.0),
                                      decoration:
                                      BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .grey),
                                        borderRadius:
                                        const BorderRadius
                                            .all(
                                            Radius.circular(
                                                5.0) //
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceAround,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
                                        children: <
                                            Widget>[
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              const Text(
                                                'Select Oil Price :',
                                                style:
                                                TextStyle(
                                                  color: Colors
                                                      .black,
                                                  fontFamily:
                                                  'GraphikMedium',
                                                  fontSize:
                                                  14,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                  height:
                                                  1.4,
                                                ),
                                              ),
                                              DropdownButton(
                                                underline:
                                                const SizedBox(),
                                                // Initial Value
                                                value: item[
                                                index]
                                                    .selectedOilPrice,

                                                // Down Arrow Icon
                                                icon:
                                                const Icon(
                                                  Icons
                                                      .keyboard_arrow_down,
                                                  color: Color(
                                                      0xff085196),
                                                ),
                                                hint: Text(
                                                    "Select Oil Price"),

                                                // Array list of Oil Price
                                                items: oilitem.map(
                                                        (String
                                                    items) {
                                                      return DropdownMenuItem(
                                                        value:
                                                        items,
                                                        child:
                                                        Text(
                                                          items,
                                                          style:
                                                          const TextStyle(
                                                            color: Color(
                                                                0xff085196),
                                                            fontFamily: 'GraphikRegular',
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            height: 1.4,
                                                          ),
                                                        ), //Text(items),
                                                      );
                                                    }).toList(),
                                                // After selecting the desired option,it will
                                                // change button value to selected value
                                                onChanged:
                                                    (String?
                                                newValue) {
                                                  setState(
                                                          () {
                                                        item[index]
                                                            .selectedOilPrice =
                                                            newValue ?? "";
                                                        submitButtonIsEnabled =
                                                        true;
                                                        selected =
                                                            index;
                                                        SelectedOilPrice =
                                                            item[index]
                                                                .selectedOilPrice;

                                                        //   if (newValue!
                                                        //    .contains(
                                                        //    oilitem[index]))
                                                        //
                                                        var idexvalue =
                                                        oilitem.indexOf(
                                                            newValue!);
                                                        //  print("slug change:"+dropdownslugcnt.toString());
                                                        Selectedslugname
                                                            .slugname =
                                                        stroilitemslug[idexvalue];
                                                        fetchimportexportcounter =
                                                        1;
                                                        fetchImportExportData();
                                                        //  }  else {
                                                        //    print(
                                                        //       "No Oil Price is Selected");
                                                        // }
                                                      });
                                                  print(
                                                      "Selected Oil Price:${newValue!}");
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              const Text(
                                                'Year :',
                                                style:
                                                TextStyle(
                                                  color: Colors
                                                      .black,
                                                  fontFamily:
                                                  'GraphikMedium',
                                                  fontSize:
                                                  14,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                  height:
                                                  1.4,
                                                ),
                                              ),
                                              DropdownButton(
                                                underline:
                                                const SizedBox(),
                                                // Initial Value
                                                value: item[
                                                index]
                                                    .selectedYear,

                                                // Down Arrow Icon
                                                icon:
                                                const Icon(
                                                  Icons
                                                      .keyboard_arrow_down,
                                                  color: Color(
                                                      0xff085196),
                                                ),

                                                // Array list of yearList
                                                items: yearList.map(
                                                        (String
                                                    items) {
                                                      return DropdownMenuItem(
                                                        value:
                                                        items,
                                                        child:
                                                        Text(
                                                          items,
                                                          style:
                                                          const TextStyle(
                                                            color: Color(
                                                                0xff085196),
                                                            fontFamily: 'GraphikRegular',
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            height: 1.4,
                                                          ),
                                                        ), //Text(items),
                                                      );
                                                    }).toList(),
                                                // After selecting the desired option,it will
                                                // change button value to selected value
                                                onChanged:
                                                    (String?
                                                newValue) {
                                                  setState(
                                                          () {
                                                        item[index]
                                                            .selectedYear =
                                                            newValue ?? "";
                                                        const Duration(
                                                            seconds: 20000);
                                                        selected =
                                                            index;
                                                        SelectedYear =
                                                            item[index]
                                                                .selectedYear;
                                                      });
                                                  print(
                                                      "Selected Year${newValue!}");
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              const Text(
                                                'View Data In :',
                                                style:
                                                TextStyle(
                                                  color: Colors
                                                      .black,
                                                  fontFamily:
                                                  'GraphikMedium',
                                                  fontSize:
                                                  14,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                  height:
                                                  1.4,
                                                ),
                                              ),
                                              DropdownButton(
                                                isDense:
                                                true,
                                                underline:
                                                const SizedBox(),
                                                // Initial Value
                                                value:
                                                SelectedQty,
                                                // viewDataIn[index],

                                                // Down Arrow Icon
                                                icon:
                                                const Icon(
                                                  Icons
                                                      .keyboard_arrow_down,
                                                  color: Color(
                                                      0xff085196),
                                                ),

                                                // Array list of viewDataIn
                                                items: viewDataIn.map(
                                                        (String
                                                    items) {
                                                      return DropdownMenuItem(
                                                        value:
                                                        items,
                                                        child:
                                                        Text(
                                                          items,
                                                          style:
                                                          const TextStyle(
                                                            color: Color(
                                                                0xff085196),
                                                            fontFamily: 'GraphikRegular',
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            height: 1.4,
                                                          ),
                                                        ), //Text(items),
                                                      );
                                                    }).toList(),
                                                // After selecting the desired option,it will
                                                // change button value to selected value
                                                onChanged:
                                                    (String?
                                                newValue) {
                                                  setState(
                                                          () {
                                                        // viewDataIn[index] =
                                                        SelectedQty =
                                                            newValue ?? "";
                                                        const Duration(
                                                            seconds: 20000);
                                                        selected =
                                                            index;
                                                      });
                                                  print(
                                                      "Selected Data In${SelectedQty}");

                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(

                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [

                                              ElevatedButton(
                                                onPressed:
                                                    () {
                                                  submitButtonIsEnabled
                                                      ? null
                                                      : Platform.isIOS
                                                      ? Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        DemoListView(
                                                          menuname: widget
                                                              .menuname,
                                                          submenuname: widget
                                                              .submenuname,
                                                          SelectedYear: SelectedYear,
                                                          SelectedQty: SelectedQty,
                                                          pagecontentId: pagecontentId,
                                                          SelectedOilPrice: SelectedOilPrice,
                                                        ),
                                                  ))
                                                      : Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        child: DemoListView(
                                                          menuname: widget
                                                              .menuname,
                                                          submenuname: widget
                                                              .submenuname,
                                                          SelectedYear: SelectedYear,
                                                          SelectedQty: SelectedQty,
                                                          pagecontentId: pagecontentId,
                                                          SelectedOilPrice: SelectedOilPrice,
                                                        ),
                                                        inheritTheme: true,
                                                        ctx: context),
                                                  );
                                                },
                                                style: ElevatedButton
                                                    .styleFrom(
                                                  backgroundColor:
                                                  const Color(0xff085196),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          6.0)),
                                                  textStyle: const TextStyle(
                                                      fontSize:
                                                      14,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                  minimumSize: const Size(
                                                      151.92,
                                                      36),
                                                ),
                                                child: (submitButtonIsEnabled)
                                                    ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ))
                                                    : const Text(
                                                  'Show',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'GraphikMedium',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight
                                                        .normal,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),


                                        ],
                                      ),
                                    )
                                        : viewhistoryfile == ""
                                        ? Container(
                                      alignment:
                                      Alignment
                                          .center,
                                      margin:
                                      const EdgeInsets
                                          .only(
                                          left:
                                          10.0,
                                          top: 10,
                                          bottom:
                                          10,
                                          right:
                                          10),
                                      padding:
                                      const EdgeInsets
                                          .all(
                                          10.0),
                                      decoration:
                                      BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .grey),
                                        borderRadius: const BorderRadius
                                            .all(
                                            Radius.circular(
                                                5.0) //
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceEvenly,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
                                        children: <
                                            Widget>[
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              const Text(
                                                'Year :',
                                                style:
                                                TextStyle(
                                                  color:
                                                  Colors.black,
                                                  fontFamily:
                                                  'GraphikMedium',
                                                  fontSize:
                                                  14,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                  height:
                                                  1.4,
                                                ),
                                              ),
                                              DropdownButton(
                                                underline:
                                                const SizedBox(),
                                                // Initial Value
                                                value:
                                                item[index].selectedYear,

                                                // Down Arrow Icon
                                                icon:
                                                const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color:
                                                  Color(0xff085196),
                                                ),

                                                // Array list of yearList
                                                items:
                                                yearList.map((String items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: Text(
                                                      items,
                                                      style: const TextStyle(
                                                        color: Color(
                                                            0xff085196),
                                                        fontFamily: 'GraphikRegular',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal,
                                                        height: 1.4,
                                                      ),
                                                    ), //Text(items),
                                                  );
                                                }).toList(),
                                                // After selecting the desired option,it will
                                                // change button value to selected value
                                                onChanged:
                                                    (String? newValue) {
                                                  setState(() {
                                                    item[index].selectedYear =
                                                        newValue ?? "";
                                                    const Duration(
                                                        seconds: 20000);
                                                    selected = index;
                                                    SelectedYear = item[index]
                                                        .selectedYear;
                                                  });
                                                  print(
                                                      "Selected Year${newValue!}");
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              const Text(
                                                'View Data In :',
                                                style:
                                                TextStyle(
                                                  color:
                                                  Colors.black,
                                                  fontFamily:
                                                  'GraphikMedium',
                                                  fontSize:
                                                  14,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                  height:
                                                  1.4,
                                                ),
                                              ),
                                              DropdownButton(
                                                isDense:
                                                true,
                                                underline:
                                                const SizedBox(),
                                                // Initial Value
                                                value:
                                                SelectedQty,
                                                // viewDataIn[index],

                                                // Down Arrow Icon
                                                icon:
                                                const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color:
                                                  Color(0xff085196),
                                                ),

                                                // Array list of viewDataIn
                                                items:
                                                viewDataIn.map((String items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: Text(
                                                      items,
                                                      style: const TextStyle(
                                                        color: Color(
                                                            0xff085196),
                                                        fontFamily: 'GraphikRegular',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal,
                                                        height: 1.4,
                                                      ),
                                                    ), //Text(items),
                                                  );
                                                }).toList(),
                                                // After selecting the desired option,it will
                                                // change button value to selected value
                                                onChanged:
                                                    (String? newValue) {
                                                  setState(() {
                                                    // viewDataIn[index] =
                                                    SelectedQty =
                                                        newValue ?? "";
                                                    const Duration(
                                                        seconds: 20000);
                                                    selected = index;
                                                  });
                                                  print(
                                                      "Selected Data In${SelectedQty}");
                                                  // SelectedQty =
                                                  //     viewDataIn[
                                                  //         index];
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height:
                                            10,
                                          ),
                                          Row(
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment
                                            //         .spaceBetween,
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [

                                              ElevatedButton(
                                                onPressed:
                                                    () {
                                                  Platform.isIOS
                                                      ? Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          DemoListView(
                                                            menuname: widget
                                                                .menuname,
                                                            submenuname: widget
                                                                .submenuname,
                                                            SelectedYear: SelectedYear,
                                                            SelectedQty: SelectedQty,
                                                            pagecontentId: pagecontentId,
                                                            SelectedOilPrice: SelectedOilPrice,
                                                          )))
                                                      : Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        child: DemoListView(
                                                          menuname: widget
                                                              .menuname,
                                                          submenuname: widget
                                                              .submenuname,
                                                          SelectedYear: SelectedYear,
                                                          SelectedQty: SelectedQty,
                                                          pagecontentId: pagecontentId,
                                                          SelectedOilPrice: SelectedOilPrice,
                                                        ),
                                                        inheritTheme: true,
                                                        ctx: context),
                                                  );
                                                },
                                                style:
                                                ElevatedButton.styleFrom(
                                                  primary:
                                                  const Color(0xff085196),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(6.0)),
                                                  textStyle:
                                                  const TextStyle(fontSize: 14,
                                                      fontWeight: FontWeight
                                                          .bold),
                                                  minimumSize:
                                                  const Size(151.92, 36),
                                                ),
                                                child:
                                                const Text(
                                                  'Show',
                                                  style:
                                                  TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'GraphikMedium',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight
                                                        .normal,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                        : Container(
                                      alignment:
                                      Alignment
                                          .center,
                                      margin:
                                      const EdgeInsets
                                          .only(
                                          left:
                                          10.0,
                                          top: 10,
                                          bottom:
                                          10,
                                          right:
                                          10),
                                      padding:
                                      const EdgeInsets
                                          .all(
                                          10.0),
                                      decoration:
                                      BoxDecoration(
                                        border: Border.all(
                                            color: Colors
                                                .grey),
                                        borderRadius: const BorderRadius
                                            .all(
                                            Radius.circular(
                                                5.0) //
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceEvenly,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
                                        children: <
                                            Widget>[
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              const Text(
                                                'Year :',
                                                style:
                                                TextStyle(
                                                  color:
                                                  Colors.black,
                                                  fontFamily:
                                                  'GraphikMedium',
                                                  fontSize:
                                                  14,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                  height:
                                                  1.4,
                                                ),
                                              ),
                                              DropdownButton(
                                                underline:
                                                const SizedBox(),
                                                // Initial Value
                                                value:
                                                item[index].selectedYear,

                                                // Down Arrow Icon
                                                icon:
                                                const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color:
                                                  Color(0xff085196),
                                                ),

                                                // Array list of yearList
                                                items:
                                                yearList.map((String items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: Text(
                                                      items,
                                                      style: const TextStyle(
                                                        color: Color(
                                                            0xff085196),
                                                        fontFamily: 'GraphikRegular',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal,
                                                        height: 1.4,
                                                      ),
                                                    ), //Text(items),
                                                  );
                                                }).toList(),
                                                // After selecting the desired option,it will
                                                // change button value to selected value
                                                onChanged:
                                                    (String? newValue) {
                                                  setState(() {
                                                    item[index].selectedYear =
                                                        newValue ?? "";
                                                    const Duration(
                                                        seconds: 20000);
                                                    selected = index;
                                                    SelectedYear = item[index]
                                                        .selectedYear;
                                                  });
                                                  print(
                                                      "Selected Year${newValue!}");
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              const Text(
                                                'View Data In :',
                                                style:
                                                TextStyle(
                                                  color:
                                                  Colors.black,
                                                  fontFamily:
                                                  'GraphikMedium',
                                                  fontSize:
                                                  14,
                                                  fontWeight:
                                                  FontWeight.normal,
                                                  height:
                                                  1.4,
                                                ),
                                              ),
                                              DropdownButton(
                                                isDense:
                                                true,
                                                underline:
                                                const SizedBox(),
                                                // Initial Value
                                                value:
                                                SelectedQty,
                                                // viewDataIn[index],

                                                // Down Arrow Icon
                                                icon:
                                                const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color:
                                                  Color(0xff085196),
                                                ),

                                                // Array list of viewDataIn
                                                items:
                                                viewDataIn.map((String items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: Text(
                                                      items,
                                                      style: const TextStyle(
                                                        color: Color(
                                                            0xff085196),
                                                        fontFamily: 'GraphikRegular',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight
                                                            .normal,
                                                        height: 1.4,
                                                      ),
                                                    ), //Text(items),
                                                  );
                                                }).toList(),
                                                // After selecting the desired option,it will
                                                // change button value to selected value
                                                onChanged:
                                                    (String? newValue) {
                                                  setState(() {
                                                    // viewDataIn[index] =
                                                    SelectedQty =
                                                        newValue ?? "";
                                                    const Duration(
                                                        seconds: 20000);
                                                    selected = index;
                                                  });
                                                  print(
                                                      "Selected Data In${SelectedQty}");

                                                },
                                              ),

                                            ],
                                          ),
                                          const SizedBox(
                                            height:
                                            10,
                                          ),
                                          Row(

                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: [

                                              ElevatedButton(
                                                onPressed:
                                                    () {
                                                  Platform.isIOS
                                                      ? Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          DemoListView(
                                                            menuname: widget
                                                                .menuname,
                                                            submenuname: widget
                                                                .submenuname,
                                                            SelectedYear: SelectedYear,
                                                            SelectedQty: SelectedQty,
                                                            pagecontentId: pagecontentId,
                                                            SelectedOilPrice: SelectedOilPrice,
                                                          )))
                                                      : Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        child: DemoListView(
                                                          menuname: widget
                                                              .menuname,
                                                          submenuname: widget
                                                              .submenuname,
                                                          SelectedYear: SelectedYear,
                                                          SelectedQty: SelectedQty,
                                                          pagecontentId: pagecontentId,
                                                          SelectedOilPrice: SelectedOilPrice,
                                                        ),
                                                        inheritTheme: true,
                                                        ctx: context),
                                                  );

                                                  setState(() {
                                                    _isDatatableVisible = true;
                                                  });
                                                },
                                                style:
                                                ElevatedButton.styleFrom(
                                                  primary:
                                                  const Color(0xff085196),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(6.0)),
                                                  textStyle:
                                                  const TextStyle(fontSize: 14,
                                                      fontWeight: FontWeight
                                                          .bold),
                                                  minimumSize:
                                                  const Size(151.92, 36),
                                                ),
                                                child:
                                                const Text(
                                                  'Show',
                                                  style:
                                                  TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'GraphikMedium',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight
                                                        .normal,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height:
                                            10,
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ]);
                      }),
                ),
                const SizedBox(
                  height: 10,
                ),

                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    ])
    // )

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
}

