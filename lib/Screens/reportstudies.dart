import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ppac/SizeConfig.dart';
import 'package:ppac/constant.dart';
import 'package:ppac/Model/ppactrackermodel.dart';
import 'package:ppac/Screens/ContentViewPage.dart';

import '../Home/HomeDashboard.dart';

class reportstudies extends StatefulWidget {
  @override
  reportstudiesState createState() {
    return reportstudiesState();
  }
}

class reportstudiesState extends State<reportstudies> {
  List<reportstudiesmodel> arrreportstudies = [];
  bool isdataconnection = true;
  bool isLoading = true;
  var dio = Dio();
  String savename = '';
  var isdownload = false;
  String _progress = "-";
  double downloadPercentage = 0;
  var extemp = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getreportstudiesfromapi(ApiConstant.url);
  }

  Future<List<reportstudiesmodel>> getreportstudiesfromapi(String url) async {
    try {
      Map data = {'method': 'getdetails', 'type': 'Report Studies'};
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

        Map decoded = json.decode(response.body);

        print("decoded:$decoded");

        arrreportstudies = [];

        for (var objreport in decoded["Report Studies"]) {
          arrreportstudies.add(reportstudiesmodel(
              reporttitle: objreport['title'],
              reportfilename: objreport['PDF'],
              reportperiod: objreport['created_date']));
        }

        setState(() {
          isdataconnection = true;
          isLoading = false;
        });
        return arrreportstudies;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }
    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print("0");
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
        print("_progress:$_progress");

        isdownload = true;
      });
      print((received / total * 100).toStringAsFixed(0) + "%");
    } else {
      print("1");
      setState(() {
        isdownload = false;
      });
    }
  }

  Future downloadxlsfilereport(
      Dio dio, String url, reportstudiesmodel objreportmodel) async {
    try {
      File file = File(url);
      savename = file.getFileName();
      String savePath = '/storage/emulated/0/Downloads' + "/$savename";
      print(savePath);

      String fileext = savename.split('.').last;

      var dir =
          await _getDownloadDirectory(); //await getApplicationDocumentsDirectory();
      print("path ${dir?.path ?? ""}");
      var filepath = "${dir?.path ?? ""}/$savename";

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
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/vnd.ms-excel');
        objreportmodel.isdownloadreport = false;
      } else if (fileext == "pdf") {
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/pdf');
        objreportmodel.isdownloadreport = false;
      } else if (fileext == "xlsx") {
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path,
            type:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

        objreportmodel.isdownloadreport = false;
      }

    } catch (e) {
      print(e);
    }
    setState(() {
      isdownload = false;
      _progress = "Completed";
    });
  }

  Future<void> downloadiosreportstudies(
      Dio dio, String url, reportstudiesmodel objreportstudies) async {
    //  Dio dio = Dio();
    File file = File(url);
    String fileName = file.path.split('/').last;
    String fileext = fileName.split('.').last;
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
          //  downloading = true;
          isdownload = true;
          _progress = "${((rec / total) * 100).toStringAsFixed(0)}%";
        });
      });

      // OpenFile.open(filepath, type: 'application/vnd.ms-excel');

      if (fileext == "xls") {
        await OpenFile.open(filepath, type: "com.microsoft.excel.xls");
        objreportstudies.isdownloadreport = false;
      } else if (fileext == "pdf") {
        await OpenFile.open(filepath, type: "com.adobe.pdf");
        objreportstudies.isdownloadreport = false;
      } else if (fileext == "xlsx") {
        await OpenFile.open(filepath,
            type:
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        objreportstudies.isdownloadreport = false;
      } else {
        await OpenFile.open(filepath, type: 'application/vnd.ms-excel');
        objreportstudies.isdownloadreport = false;
      }


      setState(() {
        isdownload = false;
        _progress = "Completed";
      });
    } catch (e) {
      print(e);
    }

    print("Download completed");
  }

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
              "Report & Studies",
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
                            TextSpan(
                                text: "Report & Studies",
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
                        //   height: Platform.isIOS ? 450 : 600,
                        height: Platform.isIOS
                            ? SizeConfig.safeBlockVertical * 75
                            : SizeConfig.safeBlockVertical * 78,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10),
                            physics: const ScrollPhysics(),
                            itemCount: arrreportstudies.length,
                            itemBuilder: (BuildContext context, int index) {
                              extemp = arrreportstudies[index]
                                  .reportfilename
                                  .toString()
                                  .split(".")
                                  .last;

                              print(extemp);

                              return Center(
                                child: Card(
                                  elevation: 20,
                                  shadowColor: Colors.black,
                                  color: Colors.white,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: Platform.isIOS ? null : 180,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0, top: 10.0),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  extemp == "xls" ||
                                                          extemp == "xlsx"
                                                      ? SvgPicture.asset(
                                                          "assets/images/file-excel.svg",
                                                          width: 42,
                                                          height: 42,
                                                          //  color: Color(0xffffffff),
                                                        )
                                                      : extemp == "pdf"
                                                          ? SvgPicture.asset(
                                                              "assets/images/file-pdf.svg",
                                                              width: 42,
                                                              height: 42,
                                                              //  color: Color(0xffffffff),
                                                            )
                                                          : const SizedBox(
                                                              width: 10,
                                                            ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Text(
                                                      arrreportstudies[index]
                                                          .reportperiod
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
                                                height: 15,
                                              ),
                                              Text(
                                                arrreportstudies[index]
                                                    .reporttitle
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        "GraphikMedium"), //Textstyle
                                              ), //Text
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: ElevatedButton(
                                                  onPressed: () {

                                                    ApiData.pdfUrl =
                                                        arrreportstudies[index]
                                                            .reportfilename!
                                                            .replaceAll(
                                                                ' ', '%20');

                                                    print(ApiData.pdfUrl);

                                                    if (Platform.isAndroid) {
                                                      print(
                                                          "android permission");
                                                      setState(() {
                                                        arrreportstudies[index]
                                                                .isdownloadreport =
                                                            true;
                                                      });
                                                      if (arrreportstudies[
                                                              index]
                                                          .reportfilename!
                                                          .isEmpty) {
                                                        setState(() {
                                                          arrreportstudies[
                                                                      index]
                                                                  .isdownloadreport ==
                                                              false;
                                                        });
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "No file to download",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Color(
                                                                    0xffAB0E1E),
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      } else {
                                                        downloadxlsfilereport(
                                                            dio,
                                                            ApiData.pdfUrl
                                                                .toString(),
                                                            arrreportstudies[
                                                                index]);
                                                      }
                                                    } else if (Platform.isIOS) {
                                                      setState(() {
                                                        arrreportstudies[index]
                                                                .isdownloadreport =
                                                            true;
                                                      });
                                                      if (arrreportstudies[
                                                              index]
                                                          .reportfilename!
                                                          .isEmpty) {
                                                        setState(() {
                                                          arrreportstudies[
                                                                      index]
                                                                  .isdownloadreport =
                                                              false;
                                                        });
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "No file to download",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .CENTER,
                                                            timeInSecForIosWeb:
                                                                1,
                                                            backgroundColor:
                                                                Color(
                                                                    0xffAB0E1E),
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0);
                                                      } else {
                                                        downloadiosreportstudies(
                                                            dio,
                                                            ApiData.pdfUrl
                                                                .toString(),
                                                            arrreportstudies[
                                                                index]);
                                                      }
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
                                                      SvgPicture.asset(
                                                          "assets/images/download-solid.svg",
                                                          width: 20,
                                                          height: 20,
                                                          color: Colors.white),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      (arrreportstudies[index]
                                                              .isdownloadreport)
                                                          ? const SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                                strokeWidth: 2,
                                                              ))
                                                          : Text(
                                                              'Download',
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
