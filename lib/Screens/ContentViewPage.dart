import 'dart:io';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../SizeConfig.dart';
import '../constant.dart';


import 'package:dio/dio.dart';

import 'package:open_file_safe/open_file_safe.dart';


import 'package:html/parser.dart' show parse;

extension FileNameExtension on File {
  String getFileName() {
    String fileName = path
        .split('/')
        .last;
    return fileName;
  }
}


class ContentViewPage extends StatefulWidget {
  String baseUrl = '';
  String viewhistoryfile = '';
  String pageContent = '';

  ContentViewPage({
    required this.baseUrl,
    required this.viewhistoryfile,
    required this.pageContent,
  });

  @override
  _ContentViewPageState createState() => _ContentViewPageState();
}

class _ContentViewPageState extends State<ContentViewPage> {
  List<String> htmlStr = [];
  String parsedString = '';
  String parsedRetailString = '';
  List<String> parsedList = [];
  List<String> parsedPetrolList = [];
  List<String> parsedDieselList = [];
  List<String> splitList = [];

  var extemp = '';

  List<String?> downloadlink = [];
  List<String?> downloadRetaillink = [];

  var dio = Dio();
  bool downloading = false;
  String _progress = "-";
  var isdownload = false;
  String savename = '';

  List<String> StringArrayTitle = [
    "Price Build up and state RSP of Petrol - As per IOC",
    "Price Build up and state RSP of Petrol - As per BPC",
    "Price Build up and state RSP of Petrol - As per HPC",
    "Price Build up and state RSP of Diesel - As per IOC",
    "Price Build up and state RSP of Diesel - As per BPC",
    "Price Build up and state RSP of Diesel - As per HPC"
  ];

  void showDownloadProgress(received, total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";

        isdownload = true;
      });
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
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

  List<String> _parseHtmlString(String pageContent) {
    var document = parse(pageContent);
    parsedString = parse(document.body!.text).documentElement!.text;
    print("parsedString:$parsedString");
    var parsedtitle = document.getElementsByTagName("li");
    print("parsedtitle:$parsedtitle");
    parsedtitle.forEach((element) {
      setState(() {
        parsedList.add(element.text.toString());
        print("parsedList:$parsedList");
        print("parsedList length:${parsedList.length}");
        var hrefs = document
            .getElementsByTagName('a')
            .where((e) => e.attributes.containsKey('href'))
            .map((e) => e.attributes['href']);


        var hrefs1 = document
            .getElementsByTagName('a')
            .where((e) => e.attributes.containsKey('data-url'))
            .map((e) => e.attributes['data-url']);


        downloadlink = List.from(hrefs)
          ..addAll(hrefs1);

        print("downloadlink:$downloadlink");
      });
    });

    print("parsedlistlength" + parsedList.length.toString());

    return parsedList;
  }

  List<String> _parseRetailHtmlString(String pageContent) {
    var document = parse(pageContent);
    parsedRetailString = parse(document.body!.text).documentElement!.text;

    print("parsedRetailString:$parsedRetailString");

    var parsedPetroltitle = document.getElementsByTagName("li");
    print("parsedPetroltitle:$parsedPetroltitle");
    parsedPetroltitle.forEach((element) {
      parsedPetrolList.add(element.text.toString());
      print("parsedPetrolList:$parsedPetrolList");
      print("parsedPetrolList length:${parsedPetrolList.length}");


      final hrefs = document
          .getElementsByTagName('a')
          .where((e) => e.attributes.containsKey('href'))
          .map((e) => e.attributes['href'])
          .toList();
      print(hrefs);
      downloadRetaillink = hrefs;
      print("downloadRetaillink:$downloadRetaillink");
    });

    return parsedPetrolList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(ApiData.subMenuID);
    _parseHtmlString(widget.pageContent);
    _parseRetailHtmlString(widget.pageContent);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Stack(children: <Widget>[
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
        backgroundColor: Colors.transparent,

        body: Column(
          children: [

//193=Historical Report
            ApiData.subMenuID == "193"


                ?
            Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 10),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: parsedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus> statuses =
                          await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print("File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                // added condition for if download path contains url or not
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?
                                await Dio().download(

                                    '${downloadlink[index]!}',
                                    // as direct link coming from api

                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) +
                                              "%");
                                        });
                                      }
                                    }) : await Dio().download(

                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    // as direct link coming from api

                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) +
                                              "%");
                                        });
                                      }
                                    });


                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);
                                print(
                                    "File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          print(downloadlink);
                          downloadlink[index]!
                              .contains(ApiConstant.downloadEndpoint)
                              ? downloadios(dio, downloadlink[index]!)
                              : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}'); // Statewise PMUY Data

                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 10),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1, color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //203=Production
                : ApiData.subMenuID == "203"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: parsedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus> statuses =
                          await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?
                                await Dio().download(
                                    '${downloadlink[index]!}',

                                    savePath, onReceiveProgress:
                                    (received, total) {
                                  if (total != -1) {
                                    setState(() {
                                      downloading = true;
                                      isdownload = true;
                                      _progress =
                                      "${((received / total) * 100)
                                          .toStringAsFixed(0)}%";
                                      print((received / total * 100)
                                          .toStringAsFixed(0) +
                                          "%");
                                    });
                                  }
                                }) :
                                await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

                                    savePath, onReceiveProgress:
                                    (received, total) {
                                  if (total != -1) {
                                    setState(() {
                                      downloading = true;
                                      isdownload = true;
                                      _progress =
                                      "${((received / total) * 100)
                                          .toStringAsFixed(0)}%";
                                      print((received / total * 100)
                                          .toStringAsFixed(0) +
                                          "%");
                                    });
                                  }
                                });

                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);


                                print(
                                    "File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint)
                              ? downloadios(dio, downloadlink[index]!)
                              : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //136=State wise
                : ApiData.subMenuID == "136"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: parsedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus>
                          statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file =
                              File(downloadlink[index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?
                                await Dio().download(
                                    '${downloadlink[index]!}',

                                    savePath, onReceiveProgress:
                                    (received, total) {
                                  if (total != -1) {
                                    setState(() {
                                      downloading = true;
                                      isdownload = true;
                                      _progress =
                                      "${((received / total) * 100)
                                          .toStringAsFixed(0)}%";
                                      print((received /
                                          total *
                                          100)
                                          .toStringAsFixed(
                                          0) +
                                          "%");
                                    });
                                  }
                                }) : await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

                                    savePath, onReceiveProgress:
                                    (received, total) {
                                  if (total != -1) {
                                    setState(() {
                                      downloading = true;
                                      isdownload = true;
                                      _progress =
                                      "${((received / total) * 100)
                                          .toStringAsFixed(0)}%";
                                      print((received /
                                          total *
                                          100)
                                          .toStringAsFixed(
                                          0) +
                                          "%");
                                    });
                                  }
                                });


                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
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
                        } else {
                          print(
                            '${ApiConstant
                                .downloadEndpoint}/${downloadlink[index]!}',
                          );
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint)
                              ? downloadios(
                              dio, downloadlink[index]!)
                              : downloadios(dio,

                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}'); // Statewise PMUY Data
                        }
                      },
                      child: Container(
                        height: 80,
                        padding:
                        EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                          FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily:
                                          'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //57=Pipeline Structure
                : ApiData.subMenuID == "57"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: parsedList.length,
                  itemBuilder:
                      (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus>
                          statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir =
                            await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file =
                              File(downloadlink[index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?
                                await Dio().download(
                                    '${downloadlink[index]!}',

                                    savePath,
                                    onReceiveProgress:
                                        (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received /
                                              total *
                                              100)
                                              .toStringAsFixed(
                                              0) +
                                              "%");
                                        });
                                      }
                                    }) : await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

                                    savePath,
                                    onReceiveProgress:
                                        (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received /
                                              total *
                                              100)
                                              .toStringAsFixed(
                                              0) +
                                              "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
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
                        } else {
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant
                                  .downloadEndpoint)
                              ? downloadios(
                              dio, downloadlink[index]!)
                              : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(
                            left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                          FontWeight.normal,
                                          color:
                                          Color(0xffffffff),
                                          fontFamily:
                                          'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //147=City Gas Distribution Network
                : ApiData.subMenuID == "147"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: parsedList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder:
                      (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission,
                              PermissionStatus>
                          statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[
                          Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir =
                            await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(
                                  downloadlink[index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename =
                                  file.getFileName();
                              String savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?
                                await Dio().download(
                                    '${downloadlink[index]!}',

                                    savePath,
                                    onReceiveProgress:
                                        (received,
                                        total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received /
                                              total *
                                              100)
                                              .toStringAsFixed(
                                              0) +
                                              "%");
                                        });
                                      }
                                    }) : await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

                                    savePath,
                                    onReceiveProgress:
                                        (received,
                                        total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received /
                                              total *
                                              100)
                                              .toStringAsFixed(
                                              0) +
                                              "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
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
                        } else {
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant
                                  .downloadEndpoint)
                              ? downloadios(dio,
                              downloadlink[index]!)
                              : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(
                            left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: const Color(
                                  0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding:
                            const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color:
                                  Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign:
                                      TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                          FontWeight
                                              .normal,
                                          color: Color(
                                              0xffffffff),
                                          fontFamily:
                                          'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //137=LPG Distributors
                : ApiData.subMenuID == "137"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: parsedList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (BuildContext context,
                      int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission,
                              PermissionStatus>
                          statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[
                          Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir =
                            await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(
                                  downloadlink[
                                  index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename =
                                  file.getFileName();
                              String savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?
                                await Dio().download(
                                    '${downloadlink[index]!}',

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
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received /
                                              total *
                                              100)
                                              .toStringAsFixed(
                                              0) +
                                              "%");
                                        });
                                      }
                                    }) : await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

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
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received /
                                              total *
                                              100)
                                              .toStringAsFixed(
                                              0) +
                                              "%");
                                        });
                                      }
                                    });


                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
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
                        } else {
                          print(downloadRetaillink);
                          downloadlink[index]!
                              .contains(ApiConstant
                              .downloadEndpoint)
                              ? downloadios(
                              dio,
                              downloadlink[
                              index]!)
                              : downloadios(dio,

                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}'); // LPG Distributors
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10, right: 10),
                        height: 80,
                        margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20),
                        alignment: Alignment.center,
                        constraints:
                        const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(
                              10),
                          border: Border.all(
                              width: 1,
                              color: const Color(
                                  0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color:
                              Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color:
                          const Color(0xff085196),
                        ),
                        child: Padding(
                            padding:
                            const EdgeInsets.all(
                                5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(
                                      0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign
                                          .center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                          FontWeight
                                              .normal,
                                          color: Color(
                                              0xffffffff),
                                          fontFamily:
                                          'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //138=SKO/LDO Dealership
                : ApiData.subMenuID == "138"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: parsedList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder:
                      (BuildContext context,
                      int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission,
                              PermissionStatus>
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
                              File file = File(
                                  downloadlink[
                                  index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename = file
                                  .getFileName();
                              String savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?

                                await Dio().download(
                                    '${downloadlink[index]!}',

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
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received /
                                              total *
                                              100)
                                              .toStringAsFixed(0) +
                                              "%");
                                        });
                                      }
                                    }) : await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

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
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received /
                                              total *
                                              100)
                                              .toStringAsFixed(0) +
                                              "%");
                                        });
                                      }
                                    });


                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
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
                        } else {
                          print(
                              downloadRetaillink);
                          downloadRetaillink[
                          index]!
                              .contains(
                              ApiConstant
                                  .downloadEndpoint)
                              ? downloadios(
                              dio,
                              downloadRetaillink[
                              index]!)
                              : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadRetaillink[index]!}');

                          // Statewise PMUY Data
                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(
                            left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20),
                        alignment:
                        Alignment.center,
                        constraints:
                        const BoxConstraints(
                          maxHeight:
                          double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius
                              .circular(10),
                          border: Border.all(
                              width: 1,
                              color: const Color(
                                  0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(
                                  0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(
                              0xff085196),
                        ),
                        child: Padding(
                            padding:
                            const EdgeInsets
                                .all(5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(
                                      0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[
                                      index],
                                      textAlign:
                                      TextAlign
                                          .center,
                                      style: const TextStyle(
                                          fontSize:
                                          14,
                                          fontWeight:
                                          FontWeight
                                              .normal,
                                          color: Color(
                                              0xffffffff),
                                          fontFamily:
                                          'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //139=Retail Outlets
                : ApiData.subMenuID == "139"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount:
                  parsedList.length,
                  itemBuilder:
                      (BuildContext context,
                      int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform
                            .isAndroid) {
                          Map<
                              Permission,
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
                            if (dir != null) {
                              File file = File(
                                  downloadlink[
                                  index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename = file
                                  .getFileName();
                              String
                              savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?

                                await Dio().download(
                                    '${downloadlink[index]!}',

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
                                              "${((received / total) * 100)
                                                  .toStringAsFixed(0)}%";
                                              print((received / total * 100)
                                                  .toStringAsFixed(0) +
                                                  "%");
                                            });
                                      }
                                    }) : await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

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
                                              "${((received / total) * 100)
                                                  .toStringAsFixed(0)}%";
                                              print((received / total * 100)
                                                  .toStringAsFixed(0) +
                                                  "%");
                                            });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
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
                        } else {
                          print(
                              downloadRetaillink);

                          downloadRetaillink[
                          index]!
                              .contains(
                              ApiConstant
                                  .downloadEndpoint)
                              ? downloadios(
                              dio,
                              downloadRetaillink[
                              index]!)
                              : downloadios(
                              dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadRetaillink[index]!}'); // Statewise Retail Outlets

                        }
                      },
                      child: Container(
                        height: 80,
                        padding:
                        EdgeInsets.only(
                            left: 10,
                            right: 10),
                        margin:
                        EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20),
                        alignment:
                        Alignment.center,
                        constraints:
                        const BoxConstraints(
                          maxHeight:
                          double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius
                              .circular(
                              10),
                          border: Border.all(
                              width: 1,
                              color: const Color(
                                  0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(
                                  0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(
                              0xff085196),
                        ),
                        child: Padding(
                            padding:
                            const EdgeInsets
                                .all(5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .center,
                              children: <
                                  Widget>[
                                SvgPicture
                                    .asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(
                                      0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child:
                                    Text(
                                      parsedList[
                                      index],
                                      textAlign:
                                      TextAlign
                                          .center,
                                      style: const TextStyle(
                                          fontSize:
                                          14,
                                          fontWeight:
                                          FontWeight
                                              .normal,
                                          color: Color(
                                              0xffffffff),
                                          fontFamily:
                                          'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //128=Fiscal Subsidy on Public Distribution System (PDS) Kerosene and Domestic LPG (Rs. Crore)
                : ApiData.subMenuID == "128"
//129=Subsidies/ Under Recoveries to Oil Marketing Companies (OMCs) on Sale of Sensitive  Petroleum Products (Rs. Crore)
                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount:
                  parsedList.length,
                  itemBuilder:
                      (BuildContext
                  context,
                      int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform
                            .isAndroid) {
                          Map<
                              Permission,
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
                              File file = File(
                                  downloadlink[
                                  index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename = file
                                  .getFileName();
                              String
                              savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(
                                  savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?

                                await Dio().download(
                                    '${downloadlink[index]!}',

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
                                              "${((received / total) * 100)
                                                  .toStringAsFixed(0)}%";
                                              print((received / total * 100)
                                                  .toStringAsFixed(0) +
                                                  "%");
                                            });
                                      }
                                    }) :

                                await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

                                    savePath,
                                    onReceiveProgress:
                                        (received, total) {
                                      if (total !=
                                          -1) {
                                        setState(
                                                () {
                                              downloading =
                                              true;
                                              isdownload =
                                              true;
                                              _progress =
                                              "${((received / total) * 100)
                                                  .toStringAsFixed(0)}%";
                                              print((received / total * 100)
                                                  .toStringAsFixed(0) +
                                                  "%");
                                            });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
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
                        } else {
                          // Petroleum prices and under recoveries
                          print(
                              downloadlink);
                          downloadlink[
                          index]!
                              .contains(ApiConstant
                              .downloadEndpoint)
                              ? downloadios(
                              dio,
                              downloadlink[
                              index]!)
                              : downloadios(
                              dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child: Container(
                        height: 120,
                        padding: EdgeInsets
                            .only(
                            left: 10,
                            right:
                            10),
                        margin: EdgeInsets
                            .only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom:
                            20),
                        alignment:
                        Alignment
                            .center,
                        constraints:
                        const BoxConstraints(
                          maxHeight: double
                              .infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius
                              .circular(
                              10),
                          border: Border.all(
                              width: 1,
                              color: const Color(
                                  0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(
                                  0xffB4B4B4),
                              blurRadius:
                              5.0,
                            ),
                          ],
                          color: const Color(
                              0xff085196),
                        ),
                        child: Padding(
                            padding:
                            const EdgeInsets
                                .all(5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .center,
                              children: <
                                  Widget>[
                                SvgPicture
                                    .asset(
                                  "assets/images/file-excel.svg",
                                  width:
                                  42,
                                  height:
                                  42,
                                  color: Color(
                                      0xffffffff),
                                ),
                                const SizedBox(
                                  width:
                                  12,
                                ),
                                Flexible(
                                    child:
                                    Text(
                                      parsedList[
                                      index],
                                      textAlign:
                                      TextAlign.center,
                                      style: const TextStyle(
                                          fontSize:
                                          14,
                                          fontWeight:
                                          FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
                : ApiData.subMenuID == "129"
//130=Subsidy on Sale of Administered Price Mechanism (APM) Natural Gas in North East Region
                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount:
                  parsedList
                      .length,
                  itemBuilder:
                      (BuildContext
                  context,
                      int index) {
                    return GestureDetector(
                      onTap:
                          () async {
                        if (Platform
                            .isAndroid) {
                          Map<
                              Permission,
                              PermissionStatus>
                          statuses =
                          await [
                            Permission
                                .manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[
                          Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir =
                            await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir !=
                                null) {
                              File
                              file =
                              File(downloadlink[index]!);

                              print(
                                  "File Name:${file.getFileName()}");
                              savename =
                                  file.getFileName();
                              String
                              savePath =
                                  '/storage/emulated/0/Downloads' +
                                      "/$savename";
                              print(
                                  savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ?
                                await Dio().download(
                                    '${downloadlink[index]!}',

                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total !=
                                          -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    }) : await Dio().download(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',

                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total !=
                                          -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);
                                // _showAlertDialog(
                                //     '${ApiConstant.downloadEndpoint}${downloadlink[index]!}',
                                //     savename);
                                print(
                                    "File is saved to download folder.");
                              } on DioError catch (e) {
                                print(
                                    e.message);
                              }
                            }
                          } else {
                            print(
                                "No permission to read and write.");
                          }
                        } else {
                          // Petroleum prices and under recoveries
                          print(
                              downloadlink);
                          downloadlink[index]!.contains(ApiConstant
                              .downloadEndpoint)
                              ? downloadios(
                              dio,
                              downloadlink[
                              index]!)
                              : downloadios(
                              dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child:
                      Container(
                        height: 120,
                        padding: EdgeInsets
                            .only(
                            left:
                            10,
                            right:
                            10),
                        margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom:
                            20),
                        alignment:
                        Alignment
                            .center,
                        constraints:
                        const BoxConstraints(
                          maxHeight:
                          double
                              .infinity,
                        ),

                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(
                              10),
                          border: Border.all(
                              width:
                              1,
                              color: const Color(
                                  0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(
                                  0xffB4B4B4),
                              blurRadius:
                              5.0,
                            ),
                          ],
                          color: const Color(
                              0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: <
                                  Widget>[
                                SvgPicture
                                    .asset(
                                  "assets/images/file-excel.svg",
                                  width:
                                  42,
                                  height:
                                  42,
                                  color:
                                  Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width:
                                  12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign:
                                      TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
                : ApiData.subMenuID == "130"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width:
              double.infinity,
              margin:
              EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20),
              child: ListView
                  .builder(
                  shrinkWrap:
                  true,
                  itemCount:
                  parsedList
                      .length,
                  itemBuilder:
                      (BuildContext
                  context,
                      int index) {
                    return GestureDetector(
                      onTap:
                          () async {
                        if (Platform
                            .isAndroid) {
                          Map<Permission, PermissionStatus>
                          statuses =
                          await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print("File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath = '/storage/emulated/0/Downloads' +
                                  "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint) ?
                                await Dio().download(
                                    '${downloadlink[index]!}', savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    }) :
                                await Dio().download('${ApiConstant
                                    .downloadEndpoint}/${downloadlink[index]!}',
                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);
                                print("File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          // Petroleum prices and under recoveries
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint)
                              ? downloadios(dio, downloadlink[index]!)
                              : downloadios(dio, '${ApiConstant
                              .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child:
                      Container(
                        height:
                        120,
                        padding: EdgeInsets.only(
                            left: 10,
                            right: 10),
                        margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: 20),
                        alignment:
                        Alignment.center,
                        constraints:
                        const BoxConstraints(
                          maxHeight:
                          double.infinity,
                        ),
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10),
                          border:
                          Border.all(width: 1, color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color:
                          const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
                : ApiData.subMenuID ==
                "124"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double
                  .infinity,
              margin: EdgeInsets
                  .only(
                  left:
                  20,
                  right:
                  20,
                  top: 20,
                  bottom:
                  20),
              child: ListView
                  .builder(
                  shrinkWrap:
                  true,
                  itemCount:
                  parsedList
                      .length,
                  itemBuilder:
                      (BuildContext context,
                      int index) {
                    extemp = downloadlink[index]
                        .toString()
                        .split(".")
                        .last;

                    print(extemp);

                    return GestureDetector(
                      onTap:
                          () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus> statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print("File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath = '/storage/emulated/0/Downloads' +
                                  "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint) ?
                                await Dio().download(
                                    '${downloadlink[index]!}', savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    }) : await Dio().download('${ApiConstant
                                    .downloadEndpoint}/${downloadlink[index]!}',
                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);

                                // _showAlertDialog('${ApiConstant.downloadEndpoint}${downloadlink[index]!}', savename);
                                print("File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          // Petroleum prices and under recoveries
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint) ? downloadios(
                              dio, downloadlink[index]!) : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child:
                      Container(
                        height: 80,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1, color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                extemp == "xls" || extemp == "xlsx"
                                    ? SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                )
                                    : extemp == "pdf"
                                    ? SvgPicture.asset(
                                  "assets/images/file-pdf.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                )
                                    :
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
                : ApiData.subMenuID ==
                "127"
                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double
                  .infinity,
              margin: EdgeInsets.only(
                  left:
                  20,
                  right:
                  20,
                  top: 20,
                  bottom:
                  20),
              child:
              ListView(
                physics: ScrollPhysics(),
                children: [

                  Text(
                    "Price Build up and State RSP of Petrol/Diesel",
                    textAlign:
                    TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color(0xff000000),
                        fontFamily: 'GraphikMedium'),
                  ),
                  Container(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: StringArrayTitle.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () async {
                              if (Platform.isAndroid) {
                                launchURL2(downloadRetaillink[index]);
                              } else {
                                // downloadios(dio, downloadRetaillink[index].toString());
                                launchURL2(downloadRetaillink[index]);
                              }
                            },
                            child: Container(
                              height: 80,
                              margin: EdgeInsets.only(
                                  left: 20, right: 20, top: 20, bottom: 20),
                              padding: EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                maxHeight: double.infinity,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    width: 1, color: const Color(0xffF3F3F3)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xffB4B4B4),
                                    blurRadius: 5.0,
                                  ),
                                ],
                                color: const Color(0xff085196),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: <Widget>[
                                      SvgPicture.asset(
                                        "assets/images/file-excel.svg",
                                        width: 42,
                                        height: 42,
                                        color: Color(0xffffffff),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Flexible(
                                          child: Text(
                                            StringArrayTitle[index].toString(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Color(0xffffffff),
                                                fontFamily: 'GraphikMedium'),
                                          )),
                                    ],
                                  )),
                            ),
                          );
                        }),
                  )
                ],
              ),
            )
            //120=Petroleum Prices and Under recoveries
                : ApiData.subMenuID ==
                "120"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double
                  .infinity,
              margin: EdgeInsets.only(
                  left:
                  20,
                  right:
                  20,
                  top:
                  20,
                  bottom:
                  20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: parsedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    extemp = downloadlink[index]
                        .toString()
                        .split(".")
                        .last;

                    print(extemp);

                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus> statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print("File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath = '/storage/emulated/0/Downloads' +
                                  "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint) ?
                                await Dio().download(
                                    '${downloadlink[index]!}', savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    }) : await Dio().download('${ApiConstant
                                    .downloadEndpoint}/${downloadlink[index]!}',
                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    });

                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);

                                print("File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          // Petroleum prices and under recoveries
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint) ? downloadios(
                              dio, downloadlink[index]!) : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1, color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                extemp == "xls" || extemp == "xlsx"
                                    ? SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                )
                                    : extemp == "pdf"
                                    ? SvgPicture.asset(
                                  "assets/images/file-pdf.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                )
                                    :

                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      "  ${parsedList[index]}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //224=State-wise PMUY data
                : ApiData.subMenuID ==
                "224"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width:
              double.infinity,
              margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: parsedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus> statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print("File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath = '/storage/emulated/0/Downloads' +
                                  "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint) ?

                                await Dio().download(
                                    '${downloadlink[index]!}', savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    }) : await Dio().download('${ApiConstant
                                    .downloadEndpoint}/${downloadlink[index]!}',
                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress =
                                          "${((received / total) * 100)
                                              .toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);

                                print("File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          // Petroleum prices and under recoveries
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint) ? downloadios(
                              dio, downloadlink[index]!) : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1, color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //248=Active Domestic Customers of LPG
                : ApiData.subMenuID ==
                "248"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: parsedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus> statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print("File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath = '/storage/emulated/0/Downloads' +
                                  "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint) ?
                                await Dio().download(
                                    '${downloadlink[index]!}', savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress = "${((received / total) *
                                              100).toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    }) : await Dio().download('${ApiConstant
                                    .downloadEndpoint}/${downloadlink[index]!}',
                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress = "${((received / total) *
                                              100).toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);

                                // _showAlertDialog('${ApiConstant.downloadEndpoint}${downloadlink[index]!}', savename);
                                print("File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          // Petroleum prices and under recoveries
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint) ? downloadios(
                              dio, downloadlink[index]!) : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                          // Statewise PMUY Data
                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        // padding: const EdgeInsets.only(
                        //     left: 10, top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1, color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //262=LNG Imports
                : ApiData.subMenuID == "262"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: parsedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    extemp = downloadlink[index]
                        .toString()
                        .split(".")
                        .last;

                    print(extemp);
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus> statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print("File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath = '/storage/emulated/0/Downloads' +
                                  "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint) ?

                                await Dio().download(
                                    '${downloadlink[index]!}', savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress = "${((received / total) *
                                              100).toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    }) : await Dio().download('${ApiConstant
                                    .downloadEndpoint}/${downloadlink[index]!}',
                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress = "${((received / total) *
                                              100).toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);

                                // _showAlertDialog('${ApiConstant.downloadEndpoint}${downloadlink[index]!}', savename);
                                print("File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          // Petroleum prices and under recoveries
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint) ? downloadios(
                              dio, downloadlink[index]!) : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child: Container(
                        height: 80,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1, color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                extemp == "xls" || extemp == "xlsx"
                                    ? SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                )
                                    : extemp == "pdf"
                                    ? SvgPicture.asset(
                                  "assets/images/file-pdf.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                )
                                    :

                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      "  ${parsedList[index]}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
            //25=Natural Gas->LNG Imports
                : ApiData.subMenuID == "25"

                ? Container(
              height: Platform.isIOS
                  ? SizeConfig.safeBlockVertical * 65
                  : SizeConfig.safeBlockVertical * 65,
              width: double.infinity,
              margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: parsedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          Map<Permission, PermissionStatus> statuses = await [
                            Permission.manageExternalStorage,
                            //add more permission to request here.
                          ].request();

                          if (statuses[Permission.manageExternalStorage]!
                              .isGranted) {
                            var dir = await DownloadsPathProvider
                                .downloadsDirectory;
                            if (dir != null) {
                              File file = File(downloadlink[index]!);

                              print("File Name:${file.getFileName()}");
                              savename = file.getFileName();
                              String savePath = '/storage/emulated/0/Downloads' +
                                  "/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint) ?

                                await Dio().download(
                                    '${downloadlink[index]!}', savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress = "${((received / total) *
                                              100).toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    }) : await Dio().download('${ApiConstant
                                    .downloadEndpoint}/${downloadlink[index]!}',
                                    savePath,
                                    onReceiveProgress: (received, total) {
                                      if (total != -1) {
                                        setState(() {
                                          downloading = true;
                                          isdownload = true;
                                          _progress = "${((received / total) *
                                              100).toStringAsFixed(0)}%";
                                          print((received / total * 100)
                                              .toStringAsFixed(0) + "%");
                                        });
                                      }
                                    });
                                downloadlink[index]!.contains(
                                    ApiConstant.downloadEndpoint)
                                    ? _showAlertDialog(
                                    '${downloadlink[index]!}',
                                    savename)
                                    : _showAlertDialog(
                                    '${ApiConstant
                                        .downloadEndpoint}/${downloadlink[index]!}',
                                    savename);

                                print("File is saved to download folder.");
                              } on DioError catch (e) {
                                print(e.message);
                              }
                            }
                          } else {
                            print("No permission to read and write.");
                          }
                        } else {
                          // Petroleum prices and under recoveries
                          print(downloadlink);
                          downloadlink[index]!.contains(
                              ApiConstant.downloadEndpoint) ? downloadios(
                              dio, downloadlink[index]!) : downloadios(dio,
                              '${ApiConstant
                                  .downloadEndpoint}/${downloadlink[index]!}');
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 80,
                        margin: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 20),
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(
                          maxHeight: double.infinity,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1, color: const Color(0xffF3F3F3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xffB4B4B4),
                              blurRadius: 5.0,
                            ),
                          ],
                          color: const Color(0xff085196),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/file-excel.svg",
                                  width: 42,
                                  height: 42,
                                  color: Color(0xffffffff),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                    child: Text(
                                      parsedList[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xffffffff),
                                          fontFamily: 'GraphikMedium'),
                                    )),
                              ],
                            )),
                      ),
                    );
                  }),
            )
                : Container()
          ],
        ),
      )
    ]);
  }

  Future<void> downloadios(Dio dio, String url) async {
    print('Download url $url');
    File file = File(url);
    String fileName = file.path
        .split('/')
        .last;

    String fileext = fileName
        .split('.')
        .last;

    print('file.path: ${fileName}');
    var dir = await _getDownloadDirectory();
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
      } else if (fileext == "pdf") {
        await OpenFile.open(filepath, type: "com.adobe.pdf");
      } else if (fileext == "xlsx") {
        await OpenFile.open(filepath,
            type:
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      } else {
        await OpenFile.open(filepath, type: 'application/vnd.ms-excel');
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

  launchURL2(String? downloadRetaillink) async {
    final encodedUrl = Uri.encodeFull(downloadRetaillink!);

    print('encodedUrl: $encodedUrl');

    if (await canLaunch(encodedUrl)) {
      await launch(encodedUrl);
    } else {
      throw 'Could not launch $downloadRetaillink';
    }
  }
}


