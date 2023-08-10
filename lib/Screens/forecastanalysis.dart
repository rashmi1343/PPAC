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

class forcastanalysis extends StatefulWidget {
  @override
  forcastanalysisState createState() {
    return forcastanalysisState();
  }
}

class forcastanalysisState extends State<forcastanalysis> {
  List<forecastanalysismodel> arrforecastanalysis = [];
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
    super.initState();

    getforcastanalysisfromapi(ApiConstant.url);
  }

  Future<List<forecastanalysismodel>> getforcastanalysisfromapi(
      String url) async {
    try {
      Map data = {'method': 'getdetails', 'type': 'Forecast Analysis'};
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

            arrforecastanalysis = [];

            for (var objreport in decoded["Forecast Analysis"]) {
              arrforecastanalysis.add(forecastanalysismodel(
                  reporttitle: objreport['title1'],
                  reportfilename: objreport['ViewReport_RE'],
                  reportperiod: objreport['fname1']));
              arrforecastanalysis.add(forecastanalysismodel(
                  reporttitle: objreport['title2'],
                  reportfilename: objreport['ViewReport_OE'],
                  reportperiod: objreport['fname2']));
            }

            setState(() {
              isdataconnection = true;
              isLoading = false;
            });
          } else {
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

        return arrforecastanalysis;
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

  Future downloadxlsfileforecast(
      Dio dio, String url, forecastanalysismodel objanalysismodel) async {
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

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/vnd.ms-excel');
        objanalysismodel.isdownloadreport = false;
      } else if (fileext == "pdf") {
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/pdf');
        objanalysismodel.isdownloadreport = false;
      } else if (fileext == "xlsx") {
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path,
            type:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

        objanalysismodel.isdownloadreport = false;
      }

    } catch (e) {
      print(e);
    }
    setState(() {
      isdownload = false;
      _progress = "Completed";
    });
  }

  Future<void> downloadiosforecast(
      Dio dio, String url, forecastanalysismodel objforecastanalysis) async {

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

          isdownload = true;
          downloadPercentage = ((rec / total) * 100);
          _progress = "${((rec / total) * 100).toStringAsFixed(0)}%";
        });
      });

      if (fileext == "xls") {
        await OpenFile.open(filepath, type: "com.microsoft.excel.xls");
        objforecastanalysis.isdownloadreport = false;
      } else if (fileext == "pdf") {
        await OpenFile.open(filepath, type: "com.adobe.pdf");
        objforecastanalysis.isdownloadreport = false;
      } else if (fileext == "xlsx") {
        await OpenFile.open(filepath,
            type:
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        objforecastanalysis.isdownloadreport = false;
      } else {
        await OpenFile.open(filepath, type: 'application/vnd.ms-excel');
        objforecastanalysis.isdownloadreport = false;
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
              "Forecast and Analysis",
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
                                text: "Forecast & Analysis",
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
                        // height: Platform.isIOS ? 450 : 600,
                        height: Platform.isIOS
                            ? SizeConfig.safeBlockVertical * 75
                            : SizeConfig.safeBlockVertical * 78,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10),
                            physics: const ScrollPhysics(),
                            itemCount: arrforecastanalysis.length,
                            itemBuilder: (BuildContext context, int index) {
                              extemp = arrforecastanalysis[index]
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
                                    height: Platform.isIOS ? null : 160,
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
                                                      arrforecastanalysis[index]
                                                          .reporttitle
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
                                                arrforecastanalysis[index]
                                                    .reportperiod
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
                                                    // ApiData.pdfUrl = '${ApiConstant.pdfUrlEndpoint}rti/${rtiDatalist[index].imagePath}'

                                                    ApiData.pdfUrl =
                                                        arrforecastanalysis[
                                                                index]
                                                            .reportfilename!
                                                            .replaceAll(
                                                                ' ', '%20');

                                                    print(ApiData.pdfUrl);
                                                    // print(ApiData.pdfUrl);

                                                    if (Platform.isAndroid) {
                                                      print(
                                                          "android permission");
                                                      setState(() {
                                                        arrforecastanalysis[
                                                                    index]
                                                                .isdownloadreport =
                                                            true;
                                                      });
                                                      if (arrforecastanalysis[
                                                              index]
                                                          .reportfilename!
                                                          .isEmpty) {
                                                        setState(() {
                                                          arrforecastanalysis[
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
                                                        downloadxlsfileforecast(
                                                            dio,
                                                            ApiData.pdfUrl
                                                                .toString(),
                                                            arrforecastanalysis[
                                                                index]);
                                                      }
                                                    } else if (Platform.isIOS) {
                                                      setState(() {
                                                        arrforecastanalysis[
                                                                    index]
                                                                .isdownloadreport =
                                                            true;
                                                      });
                                                      if (arrforecastanalysis[
                                                              index]
                                                          .reportfilename!
                                                          .isEmpty) {
                                                        setState(() {
                                                          arrforecastanalysis[
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
                                                        downloadiosforecast(
                                                            dio,
                                                            ApiData.pdfUrl
                                                                .toString(),
                                                            arrforecastanalysis[
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
                                                      (arrforecastanalysis[
                                                                  index]
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
