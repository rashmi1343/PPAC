import 'dart:convert';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/svg.dart';

import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';
import '../constant.dart';
import '../Home/HomeDashboard.dart';
import '../Model/ImportExportModel.dart';
import '../Response/PriceResponse.dart';
import '../Response/YearImportExportResponse.dart';
import 'package:http/http.dart' as http;
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';


class DemoListView extends StatefulWidget {
  String menuname;
  String submenuname;
  String SelectedYear;
  String SelectedQty = '';
  String SelectedOilPrice = '';
  String pagecontentId = " ";


  DemoListView({
    required this.menuname,
    required this.submenuname,
    required this.SelectedYear,
    required this.SelectedQty,
    required this.pagecontentId,
    required this.SelectedOilPrice,

  });

  @override
  _DemoListViewState createState() => _DemoListViewState();
}

class _DemoListViewState extends State<DemoListView> {
  List<TableContents> tableContents = [];
  List<TableContents> tableColContents = [];
  List<TableContent> tablePriceContents = [];
  List<TableContent> tableColPriceContents = [];
  ScrollController horizontalScrollController = ScrollController();
  ScrollController verticalScrollController = ScrollController();
  bool isLoading = false;
  String reportFileName = '';
  String rid = '';
  String reportSourceFileName = '';
  String producttitleColumn = '';
  String updatedate = '';
  String viewhistoryfile = '';
  String fileurl = '';
  String? htmlContent = "";
  String pagecontentId = " ";
  String? menuname;
  String? submenuname;
  String? SelectYear;
  String? SelectVieDataIn;
  String? SelectOilPrice;
  String? selectedGoods;
  bool ishtmlload = false;
  bool downloading = false;
  bool permissionGranted = true;

  List<String> yearList = [];
  List<String> viewDataIn = [];
  late String pagetitle;

  Future setStr(ishtml) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString("ishtml", ishtml);
  }

  String downloadfolder = "";

  @override
  void initState() {
    super.initState();

    try {
      isLoading = true;

      menuname = widget.menuname;
      submenuname = widget.submenuname;
      fetchSummarydefault();
      fetchImportExportData();
      BackButtonInterceptor.add(myInterceptor);
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
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("Back To DocumentView Page");
    //  Navigator.pop(context);
    ApiData.gridclickcount = 0;
    if (["docRoute"].contains(info.currentRoute(context))) return true;

    return false;
  }

  Future<ImportExportModel> fetchImportExportData() async {
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
      ApiData.submenuName = submenuname.toString();
      print("submenuName:${ApiData.submenuName}");
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
        final importExportData = importExportModelFromJson(response.body);

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

        TABULARPAGECONTENT.historyfilename =
            importExportData.pageContents.historyUpload!;
        print("historyfilename:${TABULARPAGECONTENT.historyfilename}");

        TABULARPAGECONTENT.pagecontent =
            importExportData.pageContents.pageContents!.replaceAll("\t\r", "");
        print("pagecontent:${TABULARPAGECONTENT.pagecontent}");

        TABULARPAGECONTENT.department =
            importExportData.pageContents.department!;
        print("Page ID:$importExportData.pageContents.id");

        TABULARPAGECONTENT.metadescriptions =
            importExportData.pageContents.metaDescriptions!;
        print(
            "Page Meta Descriptions:$importExportData.pageContents.metadescriptions");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('pagecontentid', importExportData.pageContents.id!);

        pagecontentId = importExportData.pageContents.id!;
        print("pagecontentid$pagecontentId");

        TABULARPAGECONTENT.tabs = importExportData.tabs.toString();
        print('tabscontent:${TABULARPAGECONTENT.tabs}');

        TABULARPAGECONTENT.baseurl = importExportData.pageContents.baseurl!;
        print('baseurl:${TABULARPAGECONTENT.baseurl}');

        setState(() {
          yearList = importExportData.yearList;

          viewDataIn = importExportData.viewDataIn;

          fileurl = importExportData.pageContents.baseurl!;
          viewhistoryfile = importExportData.pageContents.historyUpload!;
          reportSourceFileName = importExportData.pageContents.sourceUpload!;
          print("Source History File Name:$reportSourceFileName");

          print("History File Name:$viewhistoryfile");

          isLoading = false;
        });

        return importExportData;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<List<TableContents>> fetchSummarydefault() async {

    Map jsonMap = {
      'year': widget.SelectedYear,
      'viewdata': widget.SelectedQty,
      'pageid': widget.pagecontentId,
      'method': 'getImportExports'
    };

    print(' param_getimportexport:$jsonMap\n');
    print(Uri.parse(ApiConstant.url));
    var body = utf8.encode(json.encode(jsonMap));
    final response =
        await http.post(Uri.parse(ApiConstant.url), body: body, headers: {
      'Accept': 'application/json',
      "Authorization": "Bearer ${ApiData.token}",
    });
    if (response.statusCode == 200) {
      print('response:${response.body}');
      Map decoded = json.decode(response.body);

      List jsonResponse = decoded["TableContents"] as List;

      print("TableContents: $jsonResponse");
      for (var objtblcontent in decoded["TableContents"]) {
        // return jsonResponse.map((job) => TableContents.fromJson(job)).toList();
        reportFileName = objtblcontent['report_file_name'];
        rid = objtblcontent['rd_id'];
        producttitleColumn = objtblcontent['product_title'];
        updatedate = objtblcontent['updated_at'];
        print("Report File Name:$reportFileName");
        if ((objtblcontent['cols'] == "TRUE") &&
            (objtblcontent['product_title'] != 'IMPORT^') &&
            (objtblcontent['product_title'] !=
                'CONSUMPTION OF PETROLEUM PRODUCTS (P) (as on 07.10.2022)') &&
            (objtblcontent['product_title'] != 'PRODUCTS') &&
            (objtblcontent['product_title'] != 'Bitumen') &&
            (objtblcontent['product_title'] != 'ATF') &&
            (objtblcontent['product_title'] != 'SKO') &&
            (objtblcontent['product_title'] != 'IMPORT/EXPORT') &&
            (objtblcontent['product_title'] != 'OIL COMPANIES') &&
            (objtblcontent['product_title'] != 'CPCL-NARIMANAM,TAMILNADU') &&
            (objtblcontent['product_title'] !=
                'Bharat Petroleum Corporation Ltd.  (BPCL)') &&
            (objtblcontent['product_title'] !=
                'Hindustan Petroleum Corporation Ltd.  (HPCL)') &&
            (objtblcontent['product_title'] != 'Month') &&
            (objtblcontent['product_title'] != 'Year') &&
            (objtblcontent['product_title'] !=
                'Indigenous crude oil production') &&
            (objtblcontent['product_title'] != 'PSU companies') &&
            (objtblcontent['product_title'] !=
                'Indian Oil Corporation Ltd.(IOCL)') &&
            (objtblcontent['product_title'] !=
                'Chennai Petroleum Corporation Ltd. (CPCL)') &&
            (objtblcontent['product_title'] !=
                'Bharat Petroleum Corporation Ltd. (BPCL)') &&
            (objtblcontent['product_title'] != 'NRL-NUMALIGARH, ASSAM') &&
            (objtblcontent['product_title'] !=
                'Oil & Natural Gas Corporation Ltd. (ONGC)') &&
            (objtblcontent['product_title'] !=
                'Hindustan Petroleum Corporation Ltd. (HPCL)') &&
            (objtblcontent['product_title'] !=
                'Reliance Industries Ltd. (RIL)') &&
            (objtblcontent['product_title'] != 'NEL-VADINAR,GUJARAT') &&
            (objtblcontent['product_title'] != 'of which') &&
            (objtblcontent['product_title'] != 'HSD-IV') &&
            (objtblcontent['product_title'] != '2023-24') &&
            (objtblcontent['product_title'] != 'PRODUCT EXPORT @') &&
            (objtblcontent['product_title'] != 'LDO')) {
          tableColContents.add(TableContents(
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
      setState(() {

       tableContents.removeAt(0);
      });

      return tableContents;
    } else {
      print('Error, Could not load Data.');
      throw Exception('Unable to fetch contents');
    }
  }



  var dio = Dio();
  var isdownload = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double originalDevicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    double devicePixelRatioToSet =
        originalDevicePixelRatio * (isTablet ? 1.2 : 1);
    final _screen =  MediaQuery.of(context).size;

    return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(devicePixelRatio: devicePixelRatioToSet),
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
                  ApiData.submenuName,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontFamily: 'GraphikBold',
                    fontSize: 18,
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
                    // Image.asset(
                    //   'assets/images/menuicon.png',
                    // ),
                    onPressed: () {
                      ApiData.gridclickcount = 0;
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  width: double.infinity,
                  height: 58,
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
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: SvgPicture.asset(
                              "assets/images/angle-right.svg",
                              width: 15,
                              height: 15,
                              color: const Color(0xff085196),
                            ),
                          )),


                          ApiData.menuName.isNotEmpty
                              ? TextSpan(children: <TextSpan>[
                                  TextSpan(children: [
                                    TextSpan(
                                        text: ApiData.menuName,
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
                                        text: ApiData.submenuName,
                                        style: const TextStyle(
                                            color: Color(0xff111111),
                                            fontSize: 14,
                                            height: 1.2,
                                            fontFamily: 'GraphikLight'),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // navigate to desired screen
                                          }),
                                  ])
                                ])
                              : TextSpan(
                                  text: ApiData.submenuName,
                                  style: const TextStyle(
                                      color: Color(0xff111111),
                                      fontSize: 14,
                                      fontFamily: 'GraphikLight'),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // navigate to desired screen
                                    }),

                        ],
                      ),
                    ]),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                ApiData.subMenuID == "115"
                    ? Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(
                                left: 10.0, top: 20, bottom: 20, right: 10),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0) //
                                      ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Expanded(child:
                                Container(
                                    width: _screen.width * 0.45,

                                    child:
                                Center(child:
                                ElevatedButton(

                                  onPressed: () async {
                                    print("reportFileName:$reportFileName");
                                    reportFileName =
                                        reportFileName.replaceAll(' ', '%20');
                                    if (Platform.isAndroid) {
                                      Map<Permission, PermissionStatus>
                                          statuses = await [
                                        Permission.manageExternalStorage,
                                        //add more permission to request here.
                                      ].request();

                                      if (statuses[
                                              Permission.manageExternalStorage]!
                                          .isGranted) {
                                        var dir = await DownloadsPathProvider
                                            .downloadsDirectory;
                                        if (dir != null) {
                                          String savename = reportFileName;
                                          String savePath =
                                              '/storage/emulated/0/Downloads' +
                                                  "/$savename";
                                          print(savePath);
                                          //output:  /storage/emulated/0/Download/banner.png

                                          try {
                                            await Dio().download(
                                                '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                savePath, onReceiveProgress:
                                                    (received, total) {
                                              if (total != -1) {
                                                setState(() {
                                                  downloading = true;
                                                  isdownload = true;
                                                  _progress =
                                                      "${((received / total) * 100).toStringAsFixed(0)}%";
                                                  print((received / total * 100)
                                                          .toStringAsFixed(0) +
                                                      "%");
                                                });
                                              }
                                            });

                                            _showAlertDialog(
                                                '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                savename);
                                            print(
                                                "File is saved to download folder.");
                                          } on DioError catch (e) {
                                            print(e.message);
                                          }
                                        }
                                      } else {
                                        print(
                                            "No permission to read and write.");
                                      }
                                    } else if (Platform.isIOS) {
                                      downloadios(dio,
                                          '${ApiConstant.pdfUrlEndpoint}/reports/$reportFileName');
                                    }
                                        },

                                  style: ElevatedButton.styleFrom(
                                    primary: const Color(0xff085196),

                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    //minimumSize: const Size(151.92, 36),
                                  ),
                                  child: Wrap(
                                    children: <Widget>[

                                      SvgPicture.asset(
                                          "assets/images/file-arrow-down-solid.svg",
                                          width: 20,
                                          height: 20,
                                          color: Colors.white),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Download Current',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'GraphikMedium',
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                )))),
                                Expanded(child: Container(
                                    width: _screen.width * 0.45,
                                  child:Center(child:
                                ElevatedButton(
                                  //  onPressed: _createPDF,
                                  // onPressed: generateExcel,
                                  onPressed: () async {
                                    print("viewhistoryfile:$viewhistoryfile");
                                    print("fileurl:$fileurl");
                                    if (Platform.isAndroid) {
                                      Map<Permission, PermissionStatus>
                                          statuses = await [
                                        Permission.manageExternalStorage,
                                        //add more permission to request here.
                                      ].request();

                                      if (statuses[
                                              Permission.manageExternalStorage]!
                                          .isGranted) {
                                        var dir = await DownloadsPathProvider
                                            .downloadsDirectory;
                                        if (dir != null) {
                                          String savename = viewhistoryfile;
                                          String savePath =
                                              '/storage/emulated/0/Downloads' +
                                                  "/$savename";
                                          print(savePath);
                                          //output:  /storage/emulated/0/Download/banner.png

                                          try {
                                            await Dio().download(
                                                '${fileurl}${viewhistoryfile}',
                                                savePath, onReceiveProgress:
                                                    (received, total) {
                                              if (total != -1) {
                                                setState(() {
                                                  downloading = true;
                                                  isdownload = true;
                                                  _progress =
                                                      "${((received / total) * 100).toStringAsFixed(0)}%";
                                                  print((received / total * 100)
                                                          .toStringAsFixed(0) +
                                                      "%");
                                                });
                                              }
                                            });

                                            _showHistoryAlertDialog(
                                                '${fileurl}${viewhistoryfile}',
                                                savename);
                                            print(
                                                "File is saved to download folder.");
                                          } on DioError catch (e) {
                                            print(e.message);
                                          }
                                        }
                                      } else {
                                        print(
                                            "No permission to read and write.");
                                      }
                                    } else if (Platform.isIOS) {
                                      downloadhistoryios(
                                          dio, '${fileurl}${viewhistoryfile}');
                                    }
     },

                                  style: ElevatedButton.styleFrom(
                                    primary: const Color(0xff085196),

                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),

                                  ),
                                  child: Wrap(
                                    children: <Widget>[
                                      SvgPicture.asset(
                                          "assets/images/file-arrow-down-solid.svg",
                                          width: 20,
                                          height: 20,
                                          color: Colors.white),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      const Text(
                                        'Download History',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'GraphikMedium',
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                )))),
                              ],
                            ),
                          ),
                          Container(
                            child: Text(
                              "Note : The Datatable below will scroll separately!",
                              style: const TextStyle(
                                  color: Color(0xff111111),
                                  fontSize: 10,
                                  height: 1.2,
                                  fontFamily: 'GraphikLight'),
                            ),
                          )
                        ],
                      )
                    : ApiData.subMenuID == "131"
                        ? Column(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                      left: 10.0,
                                      top: 20,
                                      bottom: 20,
                                      right: 10),
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0) //
                                        ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,

                                    children: [
                                      Expanded(child:
                                      Container(
                                          width: _screen.width * 0.45,

                                          child:
                                          Center(child:
                                      ElevatedButton(
                                        //  onPressed: _createPDF,
                                        // onPressed: generateExcel,
                                        onPressed: () async {
                                          print(
                                              "reportFileName:$reportFileName");
                                          reportFileName = reportFileName
                                              .replaceAll(' ', '%20');
                                          if (Platform.isAndroid) {
                                            Map<Permission, PermissionStatus>
                                                statuses = await [
                                              Permission.manageExternalStorage,
                                              //add more permission to request here.
                                            ].request();

                                            if (statuses[Permission
                                                    .manageExternalStorage]!
                                                .isGranted) {
                                              var dir =
                                                  await DownloadsPathProvider
                                                      .downloadsDirectory;
                                              if (dir != null) {
                                                String savename =
                                                    reportFileName;
                                                String savePath =
                                                    '/storage/emulated/0/Downloads' +
                                                        "/$savename";
                                                print(savePath);
                                                //output:  /storage/emulated/0/Download/banner.png

                                                try {
                                                  await Dio().download(
                                                      '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                      savePath,
                                                      onReceiveProgress:
                                                          (received, total) {
                                                    if (total != -1) {
                                                      setState(() {
                                                        downloading = true;
                                                        isdownload = true;
                                                        _progress =
                                                            "${((received / total) * 100).toStringAsFixed(0)}%";
                                                        print((received /
                                                                    total *
                                                                    100)
                                                                .toStringAsFixed(
                                                                    0) +
                                                            "%");
                                                      });
                                                    }
                                                  });

                                                  _showAlertDialog(
                                                      '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                      savename);
                                                  print(
                                                      "File is saved to download folder.");
                                                } on DioError catch (e) {
                                                  print(e.message);
                                                }
                                              }
                                            } else {
                                              print(
                                                  "No permission to read and write.");
                                            }
                                          } else if (Platform.isIOS) {
                                            downloadios(dio,
                                                '${ApiConstant.pdfUrlEndpoint}/reports/$reportFileName');
                                          }
                                          },

                                        style: ElevatedButton.styleFrom(
                                          primary: const Color(0xff085196),

                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6.0)),
                                          textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                         // minimumSize: const Size(151.92, 36),
                                        ),
                                        child: Wrap(
                                          children: <Widget>[
                                            SvgPicture.asset(
                                                "assets/images/file-arrow-down-solid.svg",
                                                width: 20,
                                                height: 20,
                                                color: Colors.white),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Download Current',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'GraphikMedium',
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )))),
                                      Expanded(child:
                                      Container(
                                          width: _screen.width * 0.45,

                                          child:
                                          Center(child:
                                      ElevatedButton(
                                        //  onPressed: _createPDF,
                                        // onPressed: generateExcel,
                                        onPressed: () async {
                                          print(
                                              "viewhistoryfile:$viewhistoryfile");
                                          print("fileurl:$fileurl");
                                          if (Platform.isAndroid) {
                                            Map<Permission, PermissionStatus>
                                                statuses = await [
                                              Permission.manageExternalStorage,
                                              //add more permission to request here.
                                            ].request();

                                            if (statuses[Permission
                                                    .manageExternalStorage]!
                                                .isGranted) {
                                              var dir =
                                                  await DownloadsPathProvider
                                                      .downloadsDirectory;
                                              if (dir != null) {
                                                String savename =
                                                    viewhistoryfile;
                                                String savePath =
                                                    '/storage/emulated/0/Downloads' +
                                                        "/$savename";
                                                print(savePath);
                                                //output:  /storage/emulated/0/Download/banner.png

                                                try {
                                                  await Dio().download(
                                                      '${fileurl}${viewhistoryfile}',
                                                      savePath,
                                                      onReceiveProgress:
                                                          (received, total) {
                                                    if (total != -1) {
                                                      setState(() {
                                                        downloading = true;
                                                        isdownload = true;
                                                        _progress =
                                                            "${((received / total) * 100).toStringAsFixed(0)}%";
                                                        print((received /
                                                                    total *
                                                                    100)
                                                                .toStringAsFixed(
                                                                    0) +
                                                            "%");
                                                      });
                                                    }
                                                  });

                                                  _showHistoryAlertDialog(
                                                      '${fileurl}${viewhistoryfile}',
                                                      savename);
                                                  print(
                                                      "File is saved to download folder.");
                                                } on DioError catch (e) {
                                                  print(e.message);
                                                }
                                              }
                                            } else {
                                              print(
                                                  "No permission to read and write.");
                                            }
                                          } else if (Platform.isIOS) {
                                            downloadhistoryios(dio,
                                                '${fileurl}${viewhistoryfile}');
                                          }
                                               },

                                        style: ElevatedButton.styleFrom(
                                          primary: const Color(0xff085196),

                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6.0)),
                                          textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),

                                        ),
                                        child: Wrap(
                                          children: <Widget>[
                                            SvgPicture.asset(
                                                "assets/images/file-arrow-down-solid.svg",
                                                width: 20,
                                                height: 20,
                                                color: Colors.white),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            const Text(
                                              'Download History',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'GraphikMedium',
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )))),
                                    ],
                                  )),
                              Container(
                                child: Text(
                                  "Note : The Datatable below will scroll separately!",
                                  style: const TextStyle(
                                      color: Color(0xff111111),
                                      fontSize: 10,
                                      height: 1.2,
                                      fontFamily: 'GraphikLight'),
                                ),
                              )
                            ],
                          )
                        : ApiData.subMenuID == "132"
                            ? Column(
                                children: [
                                  Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(
                                          left: 10.0,
                                          top: 20,
                                          bottom: 20,
                                          right: 10),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0) //
                                            ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                       // crossAxisAlignment:
                                         //   CrossAxisAlignment.center,
                                        children: [
                                          Expanded(child:
                                          Container(
                                              width: _screen.width * 0.45,

                                              child:
                                              Center(child:
                                          ElevatedButton(

                                            onPressed: () async {
                                              print(
                                                  "reportFileName:$reportFileName");
                                              reportFileName = reportFileName
                                                  .replaceAll(' ', '%20');
                                              if (Platform.isAndroid) {
                                                Map<Permission,
                                                        PermissionStatus>
                                                    statuses = await [
                                                  Permission
                                                      .manageExternalStorage,
                                                  //add more permission to request here.
                                                ].request();

                                                if (statuses[Permission
                                                        .manageExternalStorage]!
                                                    .isGranted) {
                                                  var dir =
                                                      await DownloadsPathProvider
                                                          .downloadsDirectory;
                                                  if (dir != null) {
                                                    String savename =
                                                        reportFileName;
                                                    String savePath =
                                                        '/storage/emulated/0/Downloads' +
                                                            "/$savename";
                                                    print(savePath);
                                                    //output:  /storage/emulated/0/Download/banner.png

                                                    try {
                                                      await Dio().download(
                                                          '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                          savePath,
                                                          onReceiveProgress:
                                                              (received,
                                                                  total) {
                                                        if (total != -1) {
                                                          setState(() {
                                                            downloading = true;
                                                            isdownload = true;
                                                            _progress =
                                                                "${((received / total) * 100).toStringAsFixed(0)}%";
                                                            print((received /
                                                                        total *
                                                                        100)
                                                                    .toStringAsFixed(
                                                                        0) +
                                                                "%");
                                                          });
                                                        }
                                                      });

                                                      _showAlertDialog(
                                                          '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                          savename);
                                                      print(
                                                          "File is saved to download folder.");
                                                    } on DioError catch (e) {
                                                      print(e.message);
                                                    }
                                                  }
                                                } else {
                                                  print(
                                                      "No permission to read and write.");
                                                }
                                              } else if (Platform.isIOS) {
                                                downloadios(dio,
                                                    '${ApiConstant.pdfUrlEndpoint}/reports/$reportFileName');
                                              }
                                                    },

                                            style: ElevatedButton.styleFrom(
                                              primary: const Color(0xff085196),

                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0)),
                                              textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),

                                            ),
                                            child: Wrap(
                                              children: <Widget>[
                                                SvgPicture.asset(
                                                    "assets/images/file-arrow-down-solid.svg",
                                                    width: 20,
                                                    height: 20,
                                                    color: Colors.white),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Download Current',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'GraphikMedium',
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )))),
                                          Expanded(child:
                                          Container(
                                              width: _screen.width * 0.45,

                                              child:
                                              Center(child:
                                          ElevatedButton(

                                            onPressed: () async {
                                              print(
                                                  "viewhistoryfile:$viewhistoryfile");
                                              print("fileurl:$fileurl");

                                              if (Platform.isAndroid) {
                                                Map<Permission,
                                                        PermissionStatus>
                                                    statuses = await [
                                                  Permission
                                                      .manageExternalStorage,
                                                  //add more permission to request here.
                                                ].request();

                                                if (statuses[Permission
                                                        .manageExternalStorage]!
                                                    .isGranted) {
                                                  var dir =
                                                      await DownloadsPathProvider
                                                          .downloadsDirectory;
                                                  if (dir != null) {
                                                    String savename =
                                                        viewhistoryfile;
                                                    String savePath =
                                                        '/storage/emulated/0/Downloads' +
                                                            "/$savename";
                                                    print(savePath);
                                                    //output:  /storage/emulated/0/Download/banner.png

                                                    try {
                                                      await Dio().download(
                                                          '${fileurl}${viewhistoryfile}',
                                                          savePath,
                                                          onReceiveProgress:
                                                              (received,
                                                                  total) {
                                                        if (total != -1) {
                                                          setState(() {
                                                            downloading = true;
                                                            isdownload = true;
                                                            _progress =
                                                                "${((received / total) * 100).toStringAsFixed(0)}%";
                                                            print((received /
                                                                        total *
                                                                        100)
                                                                    .toStringAsFixed(
                                                                        0) +
                                                                "%");
                                                          });
                                                        }
                                                      });

                                                      _showHistoryAlertDialog(
                                                          '${fileurl}${viewhistoryfile}',
                                                          savename);
                                                      print(
                                                          "File is saved to download folder.");
                                                    } on DioError catch (e) {
                                                      print(e.message);
                                                    }
                                                  }
                                                } else {
                                                  print(
                                                      "No permission to read and write.");
                                                }
                                              } else if (Platform.isIOS) {
                                                downloadhistoryios(dio,
                                                    '${fileurl}${viewhistoryfile}');
                                              }
                                                    },

                                            style: ElevatedButton.styleFrom(
                                              primary: const Color(0xff085196),

                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0)),
                                              textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                             // minimumSize:
                                               //   const Size(151.92, 36),
                                            ),
                                            child: Wrap(
                                              children: <Widget>[
                                                SvgPicture.asset(
                                                    "assets/images/file-arrow-down-solid.svg",
                                                    width: 20,
                                                    height: 20,
                                                    color: Colors.white),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                const Text(
                                                  'Download History',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'GraphikMedium',
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )))),
                                        ],
                                      )),
                                  Container(
                                    child: Text(
                                      "Note : The Datatable below will scroll separately!",
                                      style: const TextStyle(
                                          color: Color(0xff111111),
                                          fontSize: 10,
                                          height: 1.2,
                                          fontFamily: 'GraphikLight'),
                                    ),
                                  )
                                ],
                              )
                            : ApiData.subMenuID == "133"
                                ? Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.only(
                                            left: 12.0,
                                            top: 20,
                                            bottom: 20,
                                            right: 12),
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5.0) //
                                              ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 45,
                                              child: ElevatedButton(

                                                onPressed: () async {
                                                  print(
                                                      "reportFileName:$reportFileName");
                                                  reportFileName =
                                                      reportFileName.replaceAll(
                                                          ' ', '%20');
                                                  if (Platform.isAndroid) {
                                                    Map<Permission,
                                                            PermissionStatus>
                                                        statuses = await [
                                                      Permission
                                                          .manageExternalStorage,
                                                      //add more permission to request here.
                                                    ].request();

                                                    if (statuses[Permission
                                                            .manageExternalStorage]!
                                                        .isGranted) {
                                                      var dir =
                                                          await DownloadsPathProvider
                                                              .downloadsDirectory;
                                                      if (dir != null) {
                                                        String savename =
                                                            reportFileName;
                                                        String savePath =
                                                            '/storage/emulated/0/Downloads' +
                                                                "/$savename";
                                                        print(savePath);
                                                        //output:  /storage/emulated/0/Download/banner.png

                                                        try {
                                                          await Dio().download(
                                                              '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                              savePath,
                                                              onReceiveProgress:
                                                                  (received,
                                                                      total) {
                                                            if (total != -1) {
                                                              setState(() {
                                                                downloading =
                                                                    true;
                                                                isdownload =
                                                                    true;
                                                                _progress =
                                                                    "${((received / total) * 100).toStringAsFixed(0)}%";
                                                                print((received /
                                                                            total *
                                                                            100)
                                                                        .toStringAsFixed(
                                                                            0) +
                                                                    "%");
                                                              });
                                                            }
                                                          });

                                                          _showAlertDialog(
                                                              '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                              savename);
                                                          print(
                                                              "File is saved to download folder.");
                                                        } on DioError catch (e) {
                                                          print(e.message);
                                                        }
                                                      }
                                                    } else {
                                                      print(
                                                          "No permission to read and write.");
                                                    }
                                                  } else if (Platform.isIOS) {
                                                    downloadios(dio,
                                                        '${ApiConstant.pdfUrlEndpoint}/reports/$reportFileName');
                                                  }
                                                       },

                                                style: ElevatedButton.styleFrom(
                                                  primary:
                                                      const Color(0xff085196),

                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0)),
                                                  textStyle: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  minimumSize:
                                                      const Size(100, 36),
                                                ),
                                                child: Wrap(
                                                  children: <Widget>[
                                                    SvgPicture.asset(
                                                        "assets/images/file-arrow-down-solid.svg",
                                                        width: 20,
                                                        height: 20,
                                                        color: Colors.white),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'Download Current',
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
                                            Container(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 50,
                                              child: ElevatedButton(
                                                //  onPressed: _createPDF,
                                                // onPressed: generateExcel,
                                                onPressed: () async {
                                                  print(
                                                      "viewhistoryfile:$viewhistoryfile");
                                                  print("fileurl:$fileurl");
                                                  if (Platform.isAndroid) {
                                                    Map<Permission,
                                                            PermissionStatus>
                                                        statuses = await [
                                                      Permission
                                                          .manageExternalStorage,
                                                      //add more permission to request here.
                                                    ].request();

                                                    if (statuses[Permission
                                                            .manageExternalStorage]!
                                                        .isGranted) {
                                                      var dir =
                                                          await DownloadsPathProvider
                                                              .downloadsDirectory;
                                                      if (dir != null) {
                                                        String savename =
                                                            viewhistoryfile;
                                                        String savePath =
                                                            '/storage/emulated/0/Downloads' +
                                                                "/$savename";
                                                        print(savePath);
                                                        //output:  /storage/emulated/0/Download/banner.png

                                                        try {
                                                          await Dio().download(
                                                              '${fileurl}${viewhistoryfile}',
                                                              savePath,
                                                              onReceiveProgress:
                                                                  (received,
                                                                      total) {
                                                            if (total != -1) {
                                                              setState(() {
                                                                downloading =
                                                                    true;
                                                                isdownload =
                                                                    true;
                                                                _progress =
                                                                    "${((received / total) * 100).toStringAsFixed(0)}%";
                                                                print((received /
                                                                            total *
                                                                            100)
                                                                        .toStringAsFixed(
                                                                            0) +
                                                                    "%");
                                                              });
                                                            }
                                                          });

                                                          _showHistoryAlertDialog(
                                                              '${fileurl}${viewhistoryfile}',
                                                              savename);
                                                          print(
                                                              "File is saved to download folder.");
                                                        } on DioError catch (e) {
                                                          print(e.message);
                                                        }
                                                      }
                                                    } else {
                                                      print(
                                                          "No permission to read and write.");
                                                    }
                                                  } else if (Platform.isIOS) {
                                                    downloadhistoryios(dio,
                                                        '${fileurl}${viewhistoryfile}');
                                                  }
                                                  },

                                                style: ElevatedButton.styleFrom(
                                                  primary:
                                                      const Color(0xff085196),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0)),
                                                  textStyle: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  minimumSize:
                                                      const Size(100, 36),
                                                ),
                                                child: Wrap(
                                                  children: <Widget>[
                                                    SvgPicture.asset(
                                                        "assets/images/file-arrow-down-solid.svg",
                                                        width: 20,
                                                        height: 20,
                                                        color: Colors.white),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    const Text(
                                                      'Download History by Product',
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
                                            Container(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 50,
                                              child: ElevatedButton(

                                                onPressed: () async {
                                                  print(
                                                      "reportSourceFileName:$reportSourceFileName");
                                                  print("fileurl:$fileurl");
                                                  if (Platform.isAndroid) {
                                                    Map<Permission,
                                                            PermissionStatus>
                                                        statuses = await [
                                                      Permission
                                                          .manageExternalStorage,
                                                      //add more permission to request here.
                                                    ].request();

                                                    if (statuses[Permission
                                                            .manageExternalStorage]!
                                                        .isGranted) {
                                                      var dir =
                                                          await DownloadsPathProvider
                                                              .downloadsDirectory;
                                                      if (dir != null) {
                                                        String savename =
                                                            reportSourceFileName;
                                                        String savePath =
                                                            '/storage/emulated/0/Downloads' +
                                                                "/$savename";
                                                        print(savePath);
                                                        //output:  /storage/emulated/0/Download/banner.png

                                                        try {
                                                          await Dio().download(
                                                              '${fileurl}${reportSourceFileName}',
                                                              savePath,
                                                              onReceiveProgress:
                                                                  (received,
                                                                      total) {
                                                            if (total != -1) {
                                                              setState(() {
                                                                downloading =
                                                                    true;
                                                                isdownload =
                                                                    true;
                                                                _progress =
                                                                    "${((received / total) * 100).toStringAsFixed(0)}%";
                                                                print((received /
                                                                            total *
                                                                            100)
                                                                        .toStringAsFixed(
                                                                            0) +
                                                                    "%");
                                                              });
                                                            }
                                                          });

                                                          _showHistorySourceAlertDialog(
                                                              '${fileurl}${reportSourceFileName}',
                                                              savename);
                                                          print(
                                                              "File is saved to download folder.");
                                                        } on DioError catch (e) {
                                                          print(e.message);
                                                        }
                                                      }
                                                    } else {
                                                      print(
                                                          "No permission to read and write.");
                                                    }
                                                  } else if (Platform.isIOS) {
                                                    downloadhistoryios(dio,
                                                        '${fileurl}${viewhistoryfile}');
                                                  }
                                                   },

                                                style: ElevatedButton.styleFrom(
                                                  primary:
                                                      const Color(0xff085196),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0)),
                                                  textStyle: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  minimumSize:
                                                      const Size(100, 36),
                                                ),
                                                child: Wrap(
                                                  children: <Widget>[
                                                    SvgPicture.asset(
                                                        "assets/images/file-arrow-down-solid.svg",
                                                        width: 20,
                                                        height: 20,
                                                        color: Colors.white),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'Download History by Source',
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
                                      Container(
                                        child: Text(
                                          "Note : The Datatable below will scroll separately!",
                                          style: const TextStyle(
                                              color: Color(0xff111111),
                                              fontSize: 10,
                                              height: 1.2,
                                              fontFamily: 'GraphikLight'),
                                        ),
                                      )
                                    ],
                                  )
                                : ApiData.subMenuID == "135"
                                    ? Column(
                                        children: [
                                          Container(
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.only(
                                                  left: 10.0,
                                                  top: 20,
                                                  bottom: 20,
                                                  right: 10),
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5.0) //
                                                        ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                               children: [
                                                  Expanded(child:
                                                  Container(
                                                      width: _screen.width * 0.45,

                                                      child:
                                                      Center(child:
                                                  ElevatedButton(

                                                    onPressed: () async {
                                                      print(
                                                          "reportFileName:$reportFileName");
                                                      reportFileName =
                                                          reportFileName
                                                              .replaceAll(
                                                                  ' ', '%20');
                                                      if (Platform.isAndroid) {
                                                        Map<Permission,
                                                                PermissionStatus>
                                                            statuses = await [
                                                          Permission
                                                              .manageExternalStorage,
                                                          //add more permission to request here.
                                                        ].request();

                                                        if (statuses[Permission
                                                                .manageExternalStorage]!
                                                            .isGranted) {
                                                          var dir =
                                                              await DownloadsPathProvider
                                                                  .downloadsDirectory;
                                                          if (dir != null) {
                                                            String savename =
                                                                reportFileName;
                                                            String savePath =
                                                                '/storage/emulated/0/Downloads' +
                                                                    "/$savename";
                                                            print(savePath);
                                                            //output:  /storage/emulated/0/Download/banner.png

                                                            try {
                                                              await Dio().download(
                                                                  '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                                  savePath,
                                                                  onReceiveProgress:
                                                                      (received,
                                                                          total) {
                                                                if (total !=
                                                                    -1) {
                                                                  setState(() {
                                                                    downloading =
                                                                        true;
                                                                    isdownload =
                                                                        true;
                                                                    _progress =
                                                                        "${((received / total) * 100).toStringAsFixed(0)}%";
                                                                    print((received /
                                                                                total *
                                                                                100)
                                                                            .toStringAsFixed(0) +
                                                                        "%");
                                                                  });
                                                                }
                                                              });

                                                              _showAlertDialog(
                                                                  '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                                  savename);
                                                              print(
                                                                  "File is saved to download folder.");
                                                            } on DioError catch (e) {
                                                              print(e.message);
                                                            }
                                                          }
                                                        } else {
                                                          print(
                                                              "No permission to read and write.");
                                                        }
                                                      } else if (Platform
                                                          .isIOS) {
                                                        downloadios(dio,
                                                            '${ApiConstant.pdfUrlEndpoint}/reports/$reportFileName');
                                                      }
                                                    },


                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: const Color(
                                                          0xff085196),

                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6.0)),
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                   //   minimumSize: const Size(
                                                    //      151.92, 36),
                                                    ),
                                                    child: Wrap(
                                                      children: <Widget>[
                                                        SvgPicture.asset(
                                                            "assets/images/file-arrow-down-solid.svg",
                                                            width: 20,
                                                            height: 20,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          'Download Current',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'GraphikMedium',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )))),
                                                  Expanded(child:
                                                  Container(
                                                      width: _screen.width * 0.45,

                                                      child:
                                                      Center(child:
                                                  ElevatedButton(

                                                    onPressed: () async {
                                                      print(
                                                          "viewhistoryfile:$viewhistoryfile");
                                                      print("fileurl:$fileurl");
                                                      if (Platform.isAndroid) {
                                                        Map<Permission,
                                                                PermissionStatus>
                                                            statuses = await [
                                                          Permission
                                                              .manageExternalStorage,
                                                          //add more permission to request here.
                                                        ].request();

                                                        if (statuses[Permission
                                                                .manageExternalStorage]!
                                                            .isGranted) {
                                                          var dir =
                                                              await DownloadsPathProvider
                                                                  .downloadsDirectory;
                                                          if (dir != null) {
                                                            String savename =
                                                                viewhistoryfile;
                                                            String savePath =
                                                                '/storage/emulated/0/Downloads' +
                                                                    "/$savename";
                                                            print(savePath);
                                                            //output:  /storage/emulated/0/Download/banner.png

                                                            try {
                                                              await Dio().download(
                                                                  '${fileurl}${viewhistoryfile}',
                                                                  savePath,
                                                                  onReceiveProgress:
                                                                      (received,
                                                                          total) {
                                                                if (total !=
                                                                    -1) {
                                                                  setState(() {
                                                                    downloading =
                                                                        true;
                                                                    isdownload =
                                                                        true;
                                                                    _progress =
                                                                        "${((received / total) * 100).toStringAsFixed(0)}%";
                                                                    print((received /
                                                                                total *
                                                                                100)
                                                                            .toStringAsFixed(0) +
                                                                        "%");
                                                                  });
                                                                }
                                                              });

                                                              _showHistoryAlertDialog(
                                                                  '${fileurl}${viewhistoryfile}',
                                                                  savename);
                                                              print(
                                                                  "File is saved to download folder.");
                                                            } on DioError catch (e) {
                                                              print(e.message);
                                                            }
                                                          }
                                                        } else {
                                                          print(
                                                              "No permission to read and write.");
                                                        }
                                                      } else if (Platform
                                                          .isIOS) {
                                                        downloadhistoryios(dio,
                                                            '${fileurl}${viewhistoryfile}');
                                                      }
                                                         },

                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: const Color(
                                                          0xff085196),

                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6.0)),
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    //  minimumSize: const Size(
                                                 //         151.92, 36),
                                                    ),
                                                    child: Wrap(
                                                      children: <Widget>[
                                                        SvgPicture.asset(
                                                            "assets/images/file-arrow-down-solid.svg",
                                                            width: 20,
                                                            height: 20,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        const Text(
                                                          'Download History',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'GraphikMedium',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )))),
                                                ],
                                              )),
                                          Container(
                                            child: Text(
                                              "Note : The Datatable below will scroll separately!",
                                              style: const TextStyle(
                                                  color: Color(0xff111111),
                                                  fontSize: 10,
                                                  height: 1.2,
                                                  fontFamily: 'GraphikLight'),
                                            ),
                                          )
                                        ],
                                      )
                                    : ApiData.subMenuID == "141"
                                        ? Column(
                                            children: [
                                              Container(
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets.only(
                                                      left: 10.0,
                                                      top: 20,
                                                      bottom: 20,
                                                      right: 10),
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                5.0) //
                                                            ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,

                                                    children: [
                                                      Expanded(child:
                                                      Container(
                                                          width: _screen.width * 0.45,

                                                          child:
                                                          Center(child:
                                                      ElevatedButton(

                                                        onPressed: () async {
                                                          print(
                                                              "reportFileName:$reportFileName");
                                                          reportFileName =
                                                              reportFileName
                                                                  .replaceAll(
                                                                      ' ',
                                                                      '%20');
                                                          if (Platform
                                                              .isAndroid) {
                                                            Map<Permission,
                                                                    PermissionStatus>
                                                                statuses =
                                                                await [
                                                              Permission
                                                                  .manageExternalStorage,
                                                              //add more permission to request here.
                                                            ].request();

                                                            if (statuses[Permission
                                                                    .manageExternalStorage]!
                                                                .isGranted) {
                                                              var dir =
                                                                  await DownloadsPathProvider
                                                                      .downloadsDirectory;
                                                              if (dir != null) {
                                                                String
                                                                    savename =
                                                                    reportFileName;
                                                                String
                                                                    savePath =
                                                                    '/storage/emulated/0/Downloads' +
                                                                        "/$savename";
                                                                print(savePath);
                                                                //output:  /storage/emulated/0/Download/banner.png

                                                                try {
                                                                  await Dio().download(
                                                                      '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                                      savePath,
                                                                      onReceiveProgress:
                                                                          (received,
                                                                              total) {
                                                                    if (total !=
                                                                        -1) {
                                                                      setState(
                                                                          () {
                                                                        downloading =
                                                                            true;
                                                                        isdownload =
                                                                            true;
                                                                        _progress =
                                                                            "${((received / total) * 100).toStringAsFixed(0)}%";
                                                                        print((received / total * 100).toStringAsFixed(0) +
                                                                            "%");
                                                                      });
                                                                    }
                                                                  });

                                                                  _showAlertDialog(
                                                                      '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                                      savename);
                                                                  print(
                                                                      "File is saved to download folder.");
                                                                } on DioError catch (e) {
                                                                  print(e
                                                                      .message);
                                                                }
                                                              }
                                                            } else {
                                                              print(
                                                                  "No permission to read and write.");
                                                            }
                                                          } else if (Platform
                                                              .isIOS) {
                                                            downloadios(dio,
                                                                '${ApiConstant.pdfUrlEndpoint}/reports/$reportFileName');
                                                          }
                                                           },
                                                     style: ElevatedButton
                                                            .styleFrom(
                                                          primary: const Color(
                                                              0xff085196),

                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6.0)),
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),

                                                        ),
                                                        child: Wrap(
                                                          children: <Widget>[
                                                            SvgPicture.asset(
                                                                "assets/images/file-arrow-down-solid.svg",
                                                                width: 20,
                                                                height: 20,
                                                                color: Colors
                                                                    .white),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              'Download Current',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'GraphikMedium',
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                height: 1.4,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )))),
                                                      Expanded(child:
                                                      Container(
                                                          width: _screen.width * 0.45,

                                                          child:
                                                          Center(child:
                                                      ElevatedButton(
                                                        //  onPressed: _createPDF,
                                                        // onPressed: generateExcel,
                                                        onPressed: () async {
                                                          print(
                                                              "viewhistoryfile:$viewhistoryfile");
                                                          print(
                                                              "fileurl:$fileurl");
                                                          if (Platform
                                                              .isAndroid) {
                                                            Map<Permission,
                                                                    PermissionStatus>
                                                                statuses =
                                                                await [
                                                              Permission
                                                                  .manageExternalStorage,
                                                              //add more permission to request here.
                                                            ].request();

                                                            if (statuses[Permission
                                                                    .manageExternalStorage]!
                                                                .isGranted) {
                                                              var dir =
                                                                  await DownloadsPathProvider
                                                                      .downloadsDirectory;
                                                              if (dir != null) {
                                                                String
                                                                    savename =
                                                                    viewhistoryfile;
                                                                String
                                                                    savePath =
                                                                    '/storage/emulated/0/Downloads' +
                                                                        "/$savename";
                                                                print(savePath);
                                                                //output:  /storage/emulated/0/Download/banner.png

                                                                try {
                                                                  await Dio().download(
                                                                      '${fileurl}${viewhistoryfile}',
                                                                      savePath,
                                                                      onReceiveProgress:
                                                                          (received,
                                                                              total) {
                                                                    if (total !=
                                                                        -1) {
                                                                      setState(
                                                                          () {
                                                                        downloading =
                                                                            true;
                                                                        isdownload =
                                                                            true;
                                                                        _progress =
                                                                            "${((received / total) * 100).toStringAsFixed(0)}%";
                                                                        print((received / total * 100).toStringAsFixed(0) +
                                                                            "%");
                                                                      });
                                                                    }
                                                                  });

                                                                  _showHistoryAlertDialog(
                                                                      '${fileurl}${viewhistoryfile}',
                                                                      savename);
                                                                  print(
                                                                      "File is saved to download folder.");
                                                                } on DioError catch (e) {
                                                                  print(e
                                                                      .message);
                                                                }
                                                              }
                                                            } else {
                                                              print(
                                                                  "No permission to read and write.");
                                                            }
                                                          } else if (Platform
                                                              .isIOS) {
                                                            downloadhistoryios(
                                                                dio,
                                                                '${fileurl}${viewhistoryfile}');
                                                          }
                                                           },

                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary: const Color(
                                                              0xff085196),

                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6.0)),
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),

                                                        ),
                                                        child: Wrap(
                                                          children: <Widget>[
                                                            SvgPicture.asset(
                                                                "assets/images/file-arrow-down-solid.svg",
                                                                width: 20,
                                                                height: 20,
                                                                color: Colors
                                                                    .white),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              'Download History',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'GraphikMedium',
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                height: 1.4,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )))),
                                                    ],
                                                  )),
                                              Container(
                                                child: Text(
                                                  "Note : The Datatable below will scroll separately!",
                                                  style: const TextStyle(
                                                      color: Color(0xff111111),
                                                      fontSize: 10,
                                                      height: 1.2,
                                                      fontFamily:
                                                          'GraphikLight'),
                                                ),
                                              )
                                            ],
                                          )
                                        : ApiData.subMenuID == "192"
                                            ? Column(
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            top: 20,
                                                            bottom: 20,
                                                            right: 10),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),

                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,

                                                      children: [
                                                        Expanded(child:
                                                        Container(
                                                          width: _screen.width * 0.45,

                                                          child:
                                                          Center(child:
                                                        ElevatedButton(

                                                          onPressed: () async {
                                                            print(
                                                                "reportFileName:$reportFileName");
                                                            reportFileName =
                                                                reportFileName
                                                                    .replaceAll(
                                                                        ' ',
                                                                        '%20');
                                                            if (Platform
                                                                .isAndroid) {
                                                              Map<Permission,
                                                                      PermissionStatus>
                                                                  statuses =
                                                                  await [
                                                                Permission
                                                                    .manageExternalStorage,
                                                                //add more permission to request here.
                                                              ].request();

                                                              if (statuses[
                                                                      Permission
                                                                          .manageExternalStorage]!
                                                                  .isGranted) {
                                                                var dir =
                                                                    await DownloadsPathProvider
                                                                        .downloadsDirectory;
                                                                if (dir !=
                                                                    null) {
                                                                  String
                                                                      savename =
                                                                      reportFileName;
                                                                  String
                                                                      savePath =
                                                                      '/storage/emulated/0/Downloads' +
                                                                          "/$savename";
                                                                  print(
                                                                      savePath);
                                                                  //output:  /storage/emulated/0/Download/banner.png

                                                                  try {
                                                                    await Dio().download(
                                                                        '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                                        savePath,
                                                                        onReceiveProgress:
                                                                            (received,
                                                                                total) {
                                                                      if (total !=
                                                                          -1) {
                                                                        setState(
                                                                            () {
                                                                          downloading =
                                                                              true;
                                                                          isdownload =
                                                                              true;
                                                                          _progress =
                                                                              "${((received / total) * 100).toStringAsFixed(0)}%";
                                                                          print((received / total * 100).toStringAsFixed(0) +
                                                                              "%");
                                                                        });
                                                                      }
                                                                    });

                                                                    _showAlertDialog(
                                                                        '${ApiConstant.pdfUrlEndpoint}reports/$reportFileName',
                                                                        savename);
                                                                    print(
                                                                        "File is saved to download folder.");
                                                                  } on DioError catch (e) {
                                                                    print(e
                                                                        .message);
                                                                  }
                                                                }
                                                              } else {
                                                                print(
                                                                    "No permission to read and write.");
                                                              }
                                                            } else if (Platform
                                                                .isIOS) {
                                                              downloadios(dio,
                                                                  '${ApiConstant.pdfUrlEndpoint}/reports/$reportFileName');
                                                            }
                                                                  },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            primary:
                                                                const Color(
                                                                    0xff085196),
                                                             shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6.0)),
                                                            textStyle:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                         //   minimumSize:
                                                           //     const Size(
                                                            //        151.92, 36),
                                                          ),
                                                          child: Wrap(
                                                            children: <Widget>[
                                                              SvgPicture.asset(
                                                                  "assets/images/file-arrow-down-solid.svg",
                                                                  width: 20,
                                                                  height: 20,
                                                                  color: Colors
                                                                      .white),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                'Download Current Report',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'GraphikMedium',
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  height: 1.4,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )))),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "Note : The Datatable below will scroll separately!",
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xff111111),
                                                          fontSize: 10,
                                                          height: 1.2,
                                                          fontFamily:
                                                              'GraphikLight'),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Container(),

                SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff085196),
                          ),
                        )
                      : SingleChildScrollView(
                          primary: false,
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: width,
                                  height: ApiData.subMenuID == "115"
                                      ? 120
                                      : ApiData.subMenuID == "141"
                                          ? 270
                                          : ApiData.subMenuID == "192"
                                              ? 350
                                              : ApiData.subMenuID == "132"
                                                  ? 350
                                                  : ApiData.subMenuID == "133"
                                                      ? 340
                                                      : ApiData.subMenuID ==
                                                              "135"
                                                          ? 350
                                                          : ApiData.subMenuID ==
                                                                  "131"
                                                              ? 350
                                                              : height,
                                  padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
                                  alignment: Alignment.centerLeft,
                                  child: HorizontalDataTable(

                                    tableHeight: height,
                                    leftHandSideColumnWidth: 120,
                                    rightHandSideColumnWidth:
                                        ApiData.subMenuID == "115"
                                            ? 1200
                                            : ApiData.subMenuID == "132"
                                                ? 1300
                                                : 1300,
                                    isFixedHeader: true,
                                    //192=Import/Export/Current
                                    headerWidgets: ApiData.subMenuID == "192"
                                        ? _getTitleWidget()
                                        //132=Crude Processing
                                        : ApiData.subMenuID == "132"
                                            ? _getTitleWidgetCompanies()
                                            //133=Petroleum Products
                                            : ApiData.subMenuID == "133"
                                                ? _getTitleWidgetProducts()
                                                //135=Products wise
                                                : ApiData.subMenuID == "135"
                                                    ? _getTitleWidgetProducts()
                                                    //141=Consumption
                                                    : ApiData.subMenuID == "141"
                                                        ? _getTitleWidgetConsumption()
                                                        //131="Indigenous Crude Oil"
                                                        : ApiData.subMenuID ==
                                                                "131"
                                                            ? _getTitleWidgetCrudeOil()
                                                            : ApiData.subMenuID ==
                                                                    "115"
                                                                ? _getTitleWidgetPrice()
                                                                : _getTitleWidget(),
                                    leftSideItemBuilder:
                                        _generateFirstColumnRow,
                                    rightSideItemBuilder: ApiData.subMenuID ==
                                            "115"
                                        ? _generateRightHandSideColumnRowPrice
                                        : ApiData.subMenuID == "192"
                                            ? _generateRightHandSideColumnRowImportExport
                                            : ApiData.subMenuID == "131"
                                                ? _generateRightHandSideColumnRowCrude
                                                : ApiData.subMenuID == "141"
                                                    ? _generateRightHandSideColumnRowConsumption
                                                    : _generateRightHandSideColumnRow,
                                    //   _generateRightHandSideColumnRowImportExport,
                                    itemCount: tableContents.length,
                                    onScrollControllerReady:
                                        (vertical, horizontal) {
                                      verticalScrollController = vertical;
                                      horizontalScrollController = horizontal;
                                    },

                                    rowSeparatorWidget: const Divider(
                                      color: Colors.black54,
                                      height: 1.0,
                                      thickness: 0.0,
                                    ),
                                    leftHandSideColBackgroundColor:
                                        Color(0xFFFFFFFF),
                                    rightHandSideColBackgroundColor:
                                        Color(0xFFFFFFFF),
                                  )

                                  ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  _getNotesData(),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Last updated Date on : $updatedate",
                                          style: TextStyle(
                                              color: Color(0xff198754),
                                              fontFamily: 'GraphikMedium',
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                              height: 1.4,
                                              fontStyle: FontStyle.italic),
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 138, 136, 136),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                )
              ],
            ),
          )
        ]));
  }

  String _progress = "-";

  void showDownloadProgress(received, total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
        //  _onLoading();
        //showAlertDialog();
        // _submitDialog(context);
        //showmsg();
        isdownload = true;
      });
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  Future downloadhistoryxls(Dio dio, String url) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.headers);

      File file = File("/storage/emulated/0/Download/$viewhistoryfile.xls");
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();

      OpenFile.open(file.path, type: 'application/vnd.ms-excel');

    } catch (e) {
      print(e);
    }
  }


  Future downloadxlsfile(Dio dio, String url) async {
    try {
      File file = File(url);
      String fileName = file.path.split('/').last;
      print('file.path: ${fileName}');

      String fileext = fileName.split('.').last;

      var dir =
          await _getDownloadDirectory(); //await getApplicationDocumentsDirectory();
      print("path ${dir?.path ?? ""}");
      var filepath = "${dir?.path ?? ""}/$fileName";

      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.headers);

      if (fileext == "xls") {
        File file1 = File("/storage/emulated/0/Download/Report.xls");
        var raf = file1.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();
        OpenFile.open(file1.path, type: "com.microsoft.excel.xls");
        //  OpenFile.open(file1.path, type: 'application/vnd.ms-excel');
      } else if (fileext == "pdf") {
        File file1 = File("/storage/emulated/0/Download/Report.pdf");
        var raf = file1.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/pdf');
      } else if (fileext == "xlsx") {
        File file1 = File("/storage/emulated/0/Download/Report.xlsx");
        var raf = file1.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path,
            type:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      }

    } catch (e) {
      print(e);
    }
    setState(() {
      isdownload = false;
      _progress = "Completed";
    });
  }

  Future<void> downloadhistoryios(Dio dio, String url) async {
    File file = File(url);
    String fileName = file.path.split('/').last;
    print('file.path: ${fileName}');
    var dir =
        await _getDownloadDirectory(); //await getApplicationDocumentsDirectory();
    print("path ${dir?.path ?? ""}");
    var filepath = "${dir?.path ?? ""}/$fileName";
    try {
      Response response =
          await dio.download(url, filepath, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");
        setState(() {
          downloading = true;
          isdownload = true;
          _progress = "${((rec / total) * 100).toStringAsFixed(0)}%";
        });
      });
      // OpenFile.open(filepath, type: 'application/vnd.ms-excel');
      String fileext = fileName.split('.').last;

      if (fileext == "xls") {
        OpenFile.open(filepath, type: "com.microsoft.excel.xls");
      } else if (fileext == "PDF") {
        OpenFile.open(filepath, type: "com.adobe.PDF");
      } else if (fileext == "pdf") {
        OpenFile.open(filepath, type: "com.adobe.pdf");
      } else if (fileext == "xlsx") {
        OpenFile.open(filepath, type: "com.microsoft.excel.xls");
      } else {
        OpenFile.open(filepath, type: 'application/vnd.ms-excel');
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      isdownload = false;
      _progress = "Completed";
    });
    print("Download completed");
  }

  Future<void> downloadios(Dio dio, String url) async {
    File file = File(url);
    String fileName = file.path.split('/').last;
    print('file.path: ${fileName}');
    var dir =
        await _getDownloadDirectory(); //await getApplicationDocumentsDirectory();
    print("path ${dir?.path ?? ""}");
    var filepath = "${dir?.path ?? ""}/$fileName";
    try {
      Response response =
          await dio.download(url, filepath, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");
        setState(() {
          downloading = true;
          isdownload = true;
          _progress = "${((rec / total) * 100).toStringAsFixed(0)}%";
        });
      });
      // OpenFile.open(filepath, type: 'application/vnd.ms-excel');
      String fileext = fileName.split('.').last;

      if (fileext == "xls") {
        OpenFile.open(filepath, type: "com.microsoft.excel.xls");
      } else if (fileext == "pdf") {
        OpenFile.open(filepath, type: "com.adobe.pdf");
      } else if (fileext == "PDF") {
        OpenFile.open(filepath, type: "com.adobe.PDF");
      } else if (fileext == "xlsx") {
        OpenFile.open(filepath, type: "com.microsoft.excel.xls");
      } else {
        OpenFile.open(filepath, type: 'application/vnd.ms-excel');
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      isdownload = false;
      _progress = "Completed";
    });
    print("Download completed");
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }

    // iOS directory visible to user

    return await getApplicationDocumentsDirectory();
  }


  Widget _getNotesData() {
    double width = MediaQuery.of(context).size.width;
    return Container(
        width: 1200,
        //height: height,
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: tableColContents.length,
            itemBuilder: (context, i) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5,
                    ),

                    Container(
                        padding: EdgeInsets.only(
                          left: 7,
                          right: 5,
                        ),
                        width: width,
                        // color: setColor(i),
                        child: Text(
                          tableColContents[i].productTitle ?? "",
                          //overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff198754),
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    // ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Color.fromARGB(255, 138, 136, 136),
                    ),
                  ]);
            }));
  }

  List<Widget> _getTitleWidgetCrudeOil() {
    return [
      _getTitleItemWidget('INDIGENOUS CRUDE OIL PRODUCTION', 120),
      _getTitleItemWidget('APR', 100),
      _getTitleItemWidget('MAY', 100),
      _getTitleItemWidget('JUN', 100),
      _getTitleItemWidget('JUL', 100),
      _getTitleItemWidget('AUG', 100),
      _getTitleItemWidget('SEP', 100),
      _getTitleItemWidget('OCT', 100),
      _getTitleItemWidget('NOV', 100),
      _getTitleItemWidget('DEC', 100),
      _getTitleItemWidget('JAN', 100),
      _getTitleItemWidget('FEB', 100),
      _getTitleItemWidget('MAR', 100),
      _getTitleItemWidget('CUMULATIVE', 100),
    ];
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('IMPORT/EXPORT', 120),
      _getTitleItemWidget('APRIL', 100),
      _getTitleItemWidget('MAY', 100),
      _getTitleItemWidget('JUNE', 100),
      _getTitleItemWidget('JULY', 100),
      _getTitleItemWidget('AUGUST', 100),
      _getTitleItemWidget('SEPTEMBER', 100),
      _getTitleItemWidget('OCTOBER', 100),
      _getTitleItemWidget('NOVEMBER', 100),
      _getTitleItemWidget('DECEMBER', 100),
      _getTitleItemWidget('JANUARY', 100),
      _getTitleItemWidget('FEBRUARY', 100),
      _getTitleItemWidget('MARCH', 100),
      _getTitleItemWidget('TOTAL', 100),
    ];
  }

  List<Widget> _getTitleWidgetPrice() {
    return [
      _getTitleItemWidget('YEAR', 120),
      _getTitleItemWidget('APR', 100),
      _getTitleItemWidget('MAY', 100),
      _getTitleItemWidget('JUN', 100),
      _getTitleItemWidget('JUL', 100),
      _getTitleItemWidget('AUG', 100),
      _getTitleItemWidget('SEP', 100),
      _getTitleItemWidget('OCT', 100),
      _getTitleItemWidget('NOV', 100),
      _getTitleItemWidget('DEC', 100),
      _getTitleItemWidget('JAN', 100),
      _getTitleItemWidget('FEB', 100),
      _getTitleItemWidget('MAR', 100),
      Visibility(
        visible: false,
        child: _getTitleItemWidget('TOTAL', 100),
      )
    ];
  }

  List<Widget> _getTitleWidgetCompanies() {
    // else if(ApiData.subMenuID==2) {
    return [
      _getTitleItemWidget('OIL COMPANIES', 130),
      _getTitleItemWidget('APR', 100),
      _getTitleItemWidget('MAY', 100),
      _getTitleItemWidget('JUN', 100),
      _getTitleItemWidget('JUL', 100),
      _getTitleItemWidget('AUG', 100),
      _getTitleItemWidget('SEP', 100),
      _getTitleItemWidget('OCT', 100),
      _getTitleItemWidget('NOV', 100),
      _getTitleItemWidget('DEC', 100),
      _getTitleItemWidget('JAN', 100),
      _getTitleItemWidget('FEB', 100),
      _getTitleItemWidget('MAR', 100),
      _getTitleItemWidget('TOTAL', 100),
    ];
  }

  List<Widget> _getTitleWidgetProducts() {
    // else if(ApiData.subMenuID==2) {
    return [
      _getTitleItemWidget('PRODUCTS', 120),
      _getTitleItemWidget('APR', 100),
      _getTitleItemWidget('MAY', 100),
      _getTitleItemWidget('JUN', 100),
      _getTitleItemWidget('JUL', 100),
      _getTitleItemWidget('AUG', 100),
      _getTitleItemWidget('SEP', 100),
      _getTitleItemWidget('OCT', 100),
      _getTitleItemWidget('NOV', 100),
      _getTitleItemWidget('DEC', 100),
      _getTitleItemWidget('JAN', 100),
      _getTitleItemWidget('FEB', 100),
      _getTitleItemWidget('MAR', 100),
      _getTitleItemWidget('TOTAL', 100),
    ];
  }

  List<Widget> _getTitleWidgetConsumption() {
    // else if(ApiData.subMenuID==2) {
    return [
      _getTitleItemWidget('MONTH', 120),
      _getTitleItemWidget('APR', 100),
      _getTitleItemWidget('MAY', 100),
      _getTitleItemWidget('JUN', 100),
      _getTitleItemWidget('JUL', 100),
      _getTitleItemWidget('AUG', 100),
      _getTitleItemWidget('SEP', 100),
      _getTitleItemWidget('OCT', 100),
      _getTitleItemWidget('NOV', 100),
      _getTitleItemWidget('DEC', 100),
      _getTitleItemWidget('JAN', 100),
      _getTitleItemWidget('FEB', 100),
      _getTitleItemWidget('MAR', 100),
      _getTitleItemWidget('TOTAL', 100),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff085196),
        border: Border(
          right: BorderSide(width: 0.5, color: Colors.white),
        ),
      ),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.center,
      child: Center(
          child: Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'GraphikMedium',
                  fontSize: 13))),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return ApiData.subMenuID == "132"
        ? Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 130,
            height: 54,
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            alignment: Alignment.center,
            child: Center(
              child: tableContents[index].productTitle == "IMPORT^"
                  ? Text(
                      tableContents[index].productTitle ?? "",
                      style: TextStyle(
                          fontSize: 11.0,
                          color: Color(0xff198754),
                          fontFamily: 'GraphikBold'),
                    )
                  : tableContents[index].productTitle == "CRUDE OIL"
                      ? Text(
                          tableContents[index].productTitle ?? "",
                          style: TextStyle(
                              fontSize: 11.0,
                              color: Color(0xff198754),
                              fontFamily: 'GraphikBold'),
                        )
                      : tableContents[index].productTitle == "PRODUCTS"
                          ? Text(
                              tableContents[index].productTitle ?? "",
                              style: TextStyle(
                                  fontSize: 11.0,
                                  color: Color(0xff198754),
                                  fontFamily: 'GraphikBold'),
                            )
                          : tableContents[index].productTitle ==
                                  "PRODUCT IMPORT*"
                              ? Text(
                                  tableContents[index].productTitle ?? "",
                                  style: TextStyle(
                                      fontSize: 11.0,
                                      color: Color(0xff198754),
                                      fontFamily: 'GraphikBold'),
                                )
                              : tableContents[index].productTitle ==
                                      "TOTAL IMPORT"
                                  ? Text(
                                      tableContents[index].productTitle ?? "",
                                      style: TextStyle(
                                          fontSize: 11.0,
                                          color: Color(0xff198754),
                                          fontFamily: 'GraphikBold'),
                                    )
                                  : tableContents[index].productTitle ==
                                          "PRODUCT EXPORT @"
                                      ? Text(
                                          tableContents[index].productTitle ??
                                              "",
                                          style: TextStyle(
                                              fontSize: 11.0,
                                              color: Color(0xff198754),
                                              fontFamily: 'GraphikBold'),
                                        )
                                      : tableContents[index].productTitle ==
                                              "NET IMPORT"
                                          ? Text(
                                              tableContents[index]
                                                      .productTitle ??
                                                  "",
                                              style: TextStyle(
                                                  fontSize: 11.0,
                                                  color: Color(0xff198754),
                                                  fontFamily: 'GraphikBold'),
                                            )
                                          : tableContents[index].productTitle ==
                                                  "2022-23"
                                              ? Text(
                                                  tableContents[index]
                                                          .productTitle ??
                                                      "",
                                                  style: TextStyle(
                                                      fontSize: 11.0,
                                                      color: Color(0xff198754),
                                                      fontFamily:
                                                          'GraphikBold'),
                                                )
                                              : tableContents[index]
                                                          .productTitle ==
                                                      "PSU companies"
                                                  ? Text(
                                                      tableContents[index]
                                                              .productTitle ??
                                                          "",
                                                      style: TextStyle(
                                                          fontSize: 11.0,
                                                          color:
                                                              Color(0xff198754),
                                                          fontFamily:
                                                              'GraphikBold'),
                                                    )
                                                  : tableContents[index]
                                                              .productTitle ==
                                                          "PSU total (Crude Oil)"
                                                      ? Text(
                                                          tableContents[index]
                                                                  .productTitle ??
                                                              "",
                                                          style: TextStyle(
                                                              fontSize: 11.0,
                                                              color: Color(
                                                                  0xff198754),
                                                              fontFamily:
                                                                  'GraphikBold'),
                                                        )
                                                      : tableContents[index]
                                                                  .productTitle ==
                                                              "Total crude oil"
                                                          ? Text(
                                                              tableContents[
                                                                          index]
                                                                      .productTitle ??
                                                                  "",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      11.0,
                                                                  color: Color(
                                                                      0xff198754),
                                                                  fontFamily:
                                                                      'GraphikBold'),
                                                            )
                                                          : tableContents[index]
                                                                      .productTitle ==
                                                                  "Total ( Crude oil + Condensate)"
                                                              ? Text(
                                                                  tableContents[
                                                                              index]
                                                                          .productTitle ??
                                                                      "",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11.0,
                                                                      color: Color(
                                                                          0xff198754),
                                                                      fontFamily:
                                                                          'GraphikBold'),
                                                                )
                                                              : tableContents[index]
                                                                          .productTitle ==
                                                                      "Indian Oil Corporation Ltd.(IOCL)"
                                                                  ? Text(
                                                                      tableContents[index]
                                                                              .productTitle ??
                                                                          "",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11.0,
                                                                          color: Color(
                                                                              0xff198754),
                                                                          fontFamily:
                                                                              'GraphikBold'),
                                                                    )
                                                                  : tableContents[index]
                                                                              .productTitle ==
                                                                          "IOCL TOTAL"
                                                                      ? Text(
                                                                          tableContents[index].productTitle ??
                                                                              "",
                                                                          style: TextStyle(
                                                                              fontSize: 11.0,
                                                                              color: Color(0xff198754),
                                                                              fontFamily: 'GraphikBold'),
                                                                        )
                                                                      : tableContents[index].productTitle ==
                                                                              "Chennai Petroleum Corporation Ltd. (CPCL)"
                                                                          ? Text(
                                                                              tableContents[index].productTitle ?? "",
                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                            )
                                                                          : tableContents[index].productTitle == "CPCL-TOTAL"
                                                                              ? Text(
                                                                                  tableContents[index].productTitle ?? "",
                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                )
                                                                              : tableContents[index].productTitle == "Bharat Petroleum Corporation Ltd.  (BPCL)"
                                                                                  ? Text(
                                                                                      tableContents[index].productTitle ?? "",
                                                                                      style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                    )
                                                                                  : tableContents[index].productTitle == "BPCL-TOTAL"
                                                                                      ? Text(
                                                                                          tableContents[index].productTitle ?? "",
                                                                                          style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                        )
                                                                                      : tableContents[index].productTitle == "NRL-NUMALIGARH, ASSAM"
                                                                                          ? Text(
                                                                                              tableContents[index].productTitle ?? "",
                                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                            )
                                                                                          : tableContents[index].productTitle == "Oil & Natural Gas Corporation Ltd. (ONGC)"
                                                                                              ? Text(
                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                )
                                                                                              : tableContents[index].productTitle == "ONGC TOTAL"
                                                                                                  ? Text(
                                                                                                      tableContents[index].productTitle ?? "",
                                                                                                      style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                    )
                                                                                                  : tableContents[index].productTitle == "Hindustan Petroleum Corporation Ltd.  (HPCL)"
                                                                                                      ? Text(
                                                                                                          tableContents[index].productTitle ?? "",
                                                                                                          style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                        )
                                                                                                      : tableContents[index].productTitle == "HPCL-TOTAL"
                                                                                                          ? Text(
                                                                                                              tableContents[index].productTitle ?? "",
                                                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                            )
                                                                                                          : tableContents[index].productTitle == "Reliance Industries Ltd. (RIL)"
                                                                                                              ? Text(
                                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                )
                                                                                                              : tableContents[index].productTitle == "RIL TOTAL"
                                                                                                                  ? Text(
                                                                                                                      tableContents[index].productTitle ?? "",
                                                                                                                      style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                    )
                                                                                                                  : tableContents[index].productTitle == "NEL-VADINAR,GUJARAT"
                                                                                                                      ? Text(
                                                                                                                          tableContents[index].productTitle ?? "",
                                                                                                                          style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                        )
                                                                                                                      : tableContents[index].productTitle == "GRAND TOTAL"
                                                                                                                          ? Text(
                                                                                                                              tableContents[index].productTitle ?? "",
                                                                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                            )
                                                                                                                          : tableContents[index].productTitle == "TOTAL"
                                                                                                                              ? Text(
                                                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                                )
                                                                                                                              : tableContents[index].productTitle == "of which"
                                                                                                                                  ? Text(
                                                                                                                                      tableContents[index].productTitle ?? "",
                                                                                                                                      style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikMedium'),
                                                                                                                                    )
                                                                                                                                  : tableContents[index].productTitle == "Net Production"
                                                                                                                                      ? Text(
                                                                                                                                          tableContents[index].productTitle ?? "",
                                                                                                                                          style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                                        )
                                                                                                                                      : tableContents[index].productTitle == "LNG import"
                                                                                                                                          ? Text(
                                                                                                                                              tableContents[index].productTitle ?? "",
                                                                                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                                            )
                                                                                                                                          : tableContents[index].productTitle == "Total Consumption (Net Production + LNG import)"
                                                                                                                                              ? Text(
                                                                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                                                )
                                                                                                                                              : Text(
                                                                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                                                                  style: TextStyle(fontSize: 11, fontFamily: 'GraphikMedium'),
                                                                                                                                                ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 120,
            height: 54,
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            alignment: Alignment.center,
            child: Center(
              child: tableContents[index].productTitle == "IMPORT^"
                  ? Text(
                      tableContents[index].productTitle ?? "",
                      style: TextStyle(
                          fontSize: 11.0,
                          color: Color(0xff198754),
                          fontFamily: 'GraphikBold'),
                    )
                  : tableContents[index].productTitle == "CRUDE OIL"
                      ? Text(
                          tableContents[index].productTitle ?? "",
                          style: TextStyle(
                              fontSize: 11.0,
                              color: Color(0xff198754),
                              fontFamily: 'GraphikBold'),
                        )
                      : tableContents[index].productTitle == "PRODUCTS"
                          ? Text(
                              tableContents[index].productTitle ?? "",
                              style: TextStyle(
                                  fontSize: 11.0,
                                  color: Color(0xff198754),
                                  fontFamily: 'GraphikBold'),
                            )
                          : tableContents[index].productTitle ==
                                  "PRODUCT IMPORT*"
                              ? Text(
                                  tableContents[index].productTitle ?? "",
                                  style: TextStyle(
                                      fontSize: 11.0,
                                      color: Color(0xff198754),
                                      fontFamily: 'GraphikBold'),
                                )
                              : tableContents[index].productTitle ==
                                      "TOTAL IMPORT"
                                  ? Text(
                                      tableContents[index].productTitle ?? "",
                                      style: TextStyle(
                                          fontSize: 11.0,
                                          color: Color(0xff198754),
                                          fontFamily: 'GraphikBold'),
                                    )
                                  : tableContents[index].productTitle ==
                                          "PRODUCT EXPORT @"
                                      ? Text(
                                          tableContents[index].productTitle ??
                                              "",
                                          style: TextStyle(
                                              fontSize: 11.0,
                                              color: Color(0xff198754),
                                              fontFamily: 'GraphikBold'),
                                        )
                                      : tableContents[index].productTitle ==
                                              "NET IMPORT"
                                          ? Text(
                                              tableContents[index]
                                                      .productTitle ??
                                                  "",
                                              style: TextStyle(
                                                  fontSize: 11.0,
                                                  color: Color(0xff198754),
                                                  fontFamily: 'GraphikBold'),
                                            )
                                          : tableContents[index].productTitle ==
                                                  "2022-23"
                                              ? Text(
                                                  tableContents[index]
                                                          .productTitle ??
                                                      "",
                                                  style: TextStyle(
                                                      fontSize: 11.0,
                                                      color: Color(0xff198754),
                                                      fontFamily:
                                                          'GraphikBold'),
                                                )
                                              : tableContents[index]
                                                          .productTitle ==
                                                      "PSU companies"
                                                  ? Text(
                                                      tableContents[index]
                                                              .productTitle ??
                                                          "",
                                                      style: TextStyle(
                                                          fontSize: 11.0,
                                                          color:
                                                              Color(0xff198754),
                                                          fontFamily:
                                                              'GraphikBold'),
                                                    )
                                                  : tableContents[index]
                                                              .productTitle ==
                                                          "PSU total (Crude Oil)"
                                                      ? Text(
                                                          tableContents[index]
                                                                  .productTitle ??
                                                              "",
                                                          style: TextStyle(
                                                              fontSize: 11.0,
                                                              color: Color(
                                                                  0xff198754),
                                                              fontFamily:
                                                                  'GraphikBold'),
                                                        )
                                                      : tableContents[index]
                                                                  .productTitle ==
                                                              "Total crude oil"
                                                          ? Text(
                                                              tableContents[
                                                                          index]
                                                                      .productTitle ??
                                                                  "",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      11.0,
                                                                  color: Color(
                                                                      0xff198754),
                                                                  fontFamily:
                                                                      'GraphikBold'),
                                                            )
                                                          : tableContents[index]
                                                                      .productTitle ==
                                                                  "Total ( Crude oil + Condensate)"
                                                              ? Text(
                                                                  tableContents[
                                                                              index]
                                                                          .productTitle ??
                                                                      "",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11.0,
                                                                      color: Color(
                                                                          0xff198754),
                                                                      fontFamily:
                                                                          'GraphikBold'),
                                                                )
                                                              : tableContents[index]
                                                                          .productTitle ==
                                                                      "Indian Oil Corporation Ltd.(IOCL)"
                                                                  ? Text(
                                                                      tableContents[index]
                                                                              .productTitle ??
                                                                          "",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11.0,
                                                                          color: Color(
                                                                              0xff198754),
                                                                          fontFamily:
                                                                              'GraphikBold'),
                                                                    )
                                                                  : tableContents[index]
                                                                              .productTitle ==
                                                                          "IOCL TOTAL"
                                                                      ? Text(
                                                                          tableContents[index].productTitle ??
                                                                              "",
                                                                          style: TextStyle(
                                                                              fontSize: 11.0,
                                                                              color: Color(0xff198754),
                                                                              fontFamily: 'GraphikBold'),
                                                                        )
                                                                      : tableContents[index].productTitle ==
                                                                              "Chennai Petroleum Corporation Ltd. (CPCL)"
                                                                          ? Text(
                                                                              tableContents[index].productTitle ?? "",
                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                            )
                                                                          : tableContents[index].productTitle == "CPCL-TOTAL"
                                                                              ? Text(
                                                                                  tableContents[index].productTitle ?? "",
                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                )
                                                                              : tableContents[index].productTitle == "Bharat Petroleum Corporation Ltd.  (BPCL)"
                                                                                  ? Text(
                                                                                      tableContents[index].productTitle ?? "",
                                                                                      style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                    )
                                                                                  : tableContents[index].productTitle == "BPCL-TOTAL"
                                                                                      ? Text(
                                                                                          tableContents[index].productTitle ?? "",
                                                                                          style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                        )
                                                                                      : tableContents[index].productTitle == "NRL-NUMALIGARH, ASSAM"
                                                                                          ? Text(
                                                                                              tableContents[index].productTitle ?? "",
                                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                            )
                                                                                          : tableContents[index].productTitle == "Oil & Natural Gas Corporation Ltd. (ONGC)"
                                                                                              ? Text(
                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                )
                                                                                              : tableContents[index].productTitle == "ONGC TOTAL"
                                                                                                  ? Text(
                                                                                                      tableContents[index].productTitle ?? "",
                                                                                                      style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                    )
                                                                                                  : tableContents[index].productTitle == "Hindustan Petroleum Corporation Ltd.  (HPCL)"
                                                                                                      ? Text(
                                                                                                          tableContents[index].productTitle ?? "",
                                                                                                          style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                        )
                                                                                                      : tableContents[index].productTitle == "HPCL-TOTAL"
                                                                                                          ? Text(
                                                                                                              tableContents[index].productTitle ?? "",
                                                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                            )
                                                                                                          : tableContents[index].productTitle == "Reliance Industries Ltd. (RIL)"
                                                                                                              ? Text(
                                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                )
                                                                                                              : tableContents[index].productTitle == "RIL TOTAL"
                                                                                                                  ? Text(
                                                                                                                      tableContents[index].productTitle ?? "",
                                                                                                                      style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                    )
                                                                                                                  : tableContents[index].productTitle == "NEL-VADINAR,GUJARAT"
                                                                                                                      ? Text(
                                                                                                                          tableContents[index].productTitle ?? "",
                                                                                                                          style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                        )
                                                                                                                      : tableContents[index].productTitle == "GRAND TOTAL"
                                                                                                                          ? Text(
                                                                                                                              tableContents[index].productTitle ?? "",
                                                                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                            )
                                                                                                                          : tableContents[index].productTitle == "TOTAL"
                                                                                                                              ? Text(
                                                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                                )
                                                                                                                              : tableContents[index].productTitle == "of which"
                                                                                                                                  ? Text(
                                                                                                                                      tableContents[index].productTitle ?? "",
                                                                                                                                      style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikMedium'),
                                                                                                                                    )
                                                                                                                                  : tableContents[index].productTitle == "Net Production"
                                                                                                                                      ? Text(
                                                                                                                                          tableContents[index].productTitle ?? "",
                                                                                                                                          style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                                        )
                                                                                                                                      : tableContents[index].productTitle == "LNG import"
                                                                                                                                          ? Text(
                                                                                                                                              tableContents[index].productTitle ?? "",
                                                                                                                                              style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                                            )
                                                                                                                                          : tableContents[index].productTitle == "Total Consumption (Net Production + LNG import)"
                                                                                                                                              ? Text(
                                                                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                                                                  style: TextStyle(fontSize: 11.0, color: Color(0xff198754), fontFamily: 'GraphikBold'),
                                                                                                                                                )
                                                                                                                                              : Text(
                                                                                                                                                  tableContents[index].productTitle ?? "",
                                                                                                                                                  style: TextStyle(fontSize: 11, fontFamily: 'GraphikMedium'),
                                                                                                                                                ),
            ),
          );
  }

  Color setColor(int index) {
    return (index % 2 == 0) ? Colors.white : Color.fromARGB(255, 245, 245, 245);
  }

  Widget _generateRightHandSideColumnRowPrice(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
              //  left: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].april ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].may ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          // color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].june ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].july ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].august ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].september ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].october ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          // color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].november ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //   color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].december ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //   color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].january ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //   color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].february ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          // color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].march ?? "",
            style: TextStyle(
                fontSize: 12,
                color: Color(0xff000000),
                fontFamily: 'GraphikRegular'),
          )),
        ),
        Visibility(
          visible: false,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff000000),
                  fontFamily: 'GraphikRegular'),
            )),
          ),
        )
      ],
    );
  }

  Widget _generateRightHandSideColumnRowImportExport(
      BuildContext context, int index) {
    if (index == 1) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          )
        ],
      );
    } else if (index == 14) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          )
        ],
      );
    } else if (index == 15) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          )
        ],
      );
    } else if (index == 30) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff198754),
                  fontFamily: 'GraphikBold'),
            )),
          )
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          )
        ],
      );
    }
  }

  Widget _generateRightHandSideColumnRowCrude(BuildContext context, int index) {
    if (index == 3) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          )
        ],
      );
    } else if (index == 5) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          )
        ],
      );
    } else if (index == 7) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          )
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          )
        ],
      );
    }
  }

  Widget _generateRightHandSideColumnRowConsumption(
      BuildContext context, int index) {
    if (index == 0) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          )
        ],
      );
    } else if (index == 1) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          )
        ],
      );
    } else if (index == 2) {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(
                  fontSize: 11.0,
                  color: Color(0xff085196),
                  fontFamily: 'GraphikMedium'),
            )),
          )
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
                //  left: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].april ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].may ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].june ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].july ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].august ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].september ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].october ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].november ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].december ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].january ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //   color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].february ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            // color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].march ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 0.5, color: Colors.grey),
              ),
              color: setColor(index),
            ),
            width: 100,
            height: 54,
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            alignment: Alignment.centerLeft,
            //  color: setColor(index),
            child: Center(
                child: Text(
              tableContents[index].total ?? "",
              style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
            )),
          )
        ],
      );
    }
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
              //  left: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].april ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].may ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          // color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].june ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].july ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].august ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].september ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].october ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          // color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].november ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //   color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].december ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //   color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].january ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //   color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].february ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          // color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].march ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 0.5, color: Colors.grey),
            ),
            color: setColor(index),
          ),
          width: 100,
          height: 54,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          //  color: setColor(index),
          child: Center(
              child: Text(
            tableContents[index].total ?? "",
            style: TextStyle(fontSize: 12, fontFamily: 'GraphikRegular'),
          )),
        )
      ],
    );
  }

//
// Widget _getBodyWidget() {
//   return Container(
//    // height: MediaQuery.of(context).size.height,
//     child:
//     HorizontalDataTable(
//       // scrollPhysics: ScrollPhysics(),
//       // tableHeight: height,
//       leftHandSideColumnWidth: 120,
//       rightHandSideColumnWidth: 1300,
//       isFixedHeader: true,
//       headerWidgets: ApiData.subMenuID == "192"
//           ? _getTitleWidget()
//           : ApiData.subMenuID == "132"
//           ? _getTitleWidgetCompanies()
//           : ApiData.subMenuID == "133"
//           ? _getTitleWidgetProducts()
//           : ApiData.subMenuID == "135"
//           ? _getTitleWidgetProducts()
//       //141=Consumption
//           : ApiData.subMenuID == "141"
//           ? _getTitleWidgetConsumption()
//           : ApiData.subMenuID == "131"
//           ? _getTitleWidget()
//           : _getTitleWidgetPrice(),
//       leftSideItemBuilder: _generateFirstColumnRow,
//       rightSideItemBuilder: ApiData.subMenuID == "115"
//           ? _generateRightHandSideColumnRowPrice
//           : _generateRightHandSideColumnRow,
//       itemCount: tableContents.length,
//       // onScrollControllerReady:
//       //     (vertical, horizontal) {
//       //   verticalScrollController = vertical;
//       //   horizontalScrollController = horizontal;
//       // },
//
//       rowSeparatorWidget: const Divider(
//         color: Colors.black54,
//         height: 1.0,
//         thickness: 0.0,
//       ),
//       leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
//       rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
//     ),
//   );
//
// }

  Future<void> requestDownload(String _url, reportFileName) async {
    final dir =
        await getApplicationDocumentsDirectory(); //From path_provider package
    var _localPath = "/storage/emulated/0/Download/Report.xls";
    //   print("downloadpath:${dir.path}");
    final savedDir = Directory(_localPath);
    await savedDir.create(recursive: true).then((value) async {
      String? _taskid = await FlutterDownloader.enqueue(
        url: _url,
        fileName: reportFileName,
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: false,
      );
      print(_taskid);
    });
  }

  Future<void> _showAlertDialog(String url, String savename) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
          child: AlertDialog(
            title: const Text('File is saved to download folder.',
                style: TextStyle(fontSize: 15, fontFamily: 'GraphikMedium')),
            actions: <Widget>[
              TextButton(
                child: Text('View',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'GraphikMedium',
                        color: Color(0xff085196))),
                onPressed: () async {
                  Response response = await dio.get(
                    url,
                    onReceiveProgress: showDownloadProgress,
                    //Received data with List<int>
                    options: Options(
                        responseType: ResponseType.bytes,
                        followRedirects: false,
                        validateStatus: (status) {
                          return status! < 500;
                        }),
                  );
                  print(response.headers);
                  File file1 =
                      File("/storage/emulated/0/Downloads/${savename}");
                  var raf = file1.openSync(mode: FileMode.write);
                  // response.data is List<int> type
                  raf.writeFromSync(response.data);
                  await raf.close();
                  OpenFile.open(file1.path,
                      type:
                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
                },
              ),
              TextButton(
                child: Text('Cancel',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'GraphikMedium',
                        color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showHistoryAlertDialog(String url, String savename) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
          child: AlertDialog(
            title: const Text('File is saved to download folder.',
                style: TextStyle(fontSize: 15, fontFamily: 'GraphikMedium')),
            actions: <Widget>[
              TextButton(
                child: Text('View',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'GraphikMedium',
                        color: Color(0xff085196))),
                onPressed: () async {
                  Response response = await dio.get(
                    url,
                    onReceiveProgress: showDownloadProgress,
                    //Received data with List<int>
                    options: Options(
                        responseType: ResponseType.bytes,
                        followRedirects: false,
                        validateStatus: (status) {
                          return status! < 500;
                        }),
                  );
                  print(response.headers);
                  File file1 =
                      File("/storage/emulated/0/Downloads/${savename}");
                  var raf = file1.openSync(mode: FileMode.write);
                  // response.data is List<int> type
                  raf.writeFromSync(response.data);
                  await raf.close();
                  OpenFile.open(file1.path,
                      type:
                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
                },
              ),
              TextButton(
                child: Text('Cancel',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'GraphikMedium',
                        color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showHistorySourceAlertDialog(
      String url, String savename) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.white),
          child: AlertDialog(
            title: const Text('File is saved to download folder.',
                style: TextStyle(fontSize: 15, fontFamily: 'GraphikMedium')),
            actions: <Widget>[
              TextButton(
                child: Text('View',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'GraphikMedium',
                        color: Color(0xff085196))),
                onPressed: () async {
                  Response response = await dio.get(
                    url,
                    onReceiveProgress: showDownloadProgress,
                    //Received data with List<int>
                    options: Options(
                        responseType: ResponseType.bytes,
                        followRedirects: false,
                        validateStatus: (status) {
                          return status! < 500;
                        }),
                  );
                  print(response.headers);
                  File file1 =
                      File("/storage/emulated/0/Downloads/${savename}");
                  var raf = file1.openSync(mode: FileMode.write);
                  // response.data is List<int> type
                  raf.writeFromSync(response.data);
                  await raf.close();
                  OpenFile.open(file1.path,
                      type:
                          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
                },
              ),
              TextButton(
                child: Text('Cancel',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'GraphikMedium',
                        color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
