import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ppac/Home/HomeDashboard.dart';
import 'package:ppac/Screens/ExciseDutyScreen.dart';
import 'package:ppac/SizeConfig.dart';
import 'package:ppac/constant.dart';

import '../Response/ImportantNewsResponse.dart';

class ScrollingText extends StatefulWidget {
  // final String text;
  final TextStyle textStyle;
  final Axis scrollAxis;
  final double ratioOfBlankToScreen;
  final List<ImpNews> arrimpnews;

  ScrollingText({
    // required this.text,
    required this.textStyle,
    required this.arrimpnews,
    this.scrollAxis: Axis.horizontal,
    this.ratioOfBlankToScreen: 0.25,
  }) : assert(
          arrimpnews != null,
        );

  @override
  State<StatefulWidget> createState() {
    return ScrollingTextState();
  }
}

class ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late ScrollController scrollController;
  late double screenWidth;
  late double screenHeight;
  double position = 0.0;
  late Timer timer;
  final double _moveDistance = 3.0;
  final int _timerRest = 100;
  GlobalKey _key = GlobalKey();
  var dio = Dio();
  String savename = '';
  var isdownload = false;
  String _progress = "-";

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      startTimer();
    });
  }

  void startTimer() {
    if (_key.currentContext != null) {
      double widgetWidth =
          _key.currentContext!.findRenderObject()!.paintBounds.size.width;
      double widgetHeight =
          _key.currentContext!.findRenderObject()!.paintBounds.size.height;

      timer = Timer.periodic(Duration(milliseconds: _timerRest), (timer) {
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        double pixels = scrollController.position.pixels;
        if (pixels + _moveDistance >= maxScrollExtent) {
          if (widget.scrollAxis == Axis.horizontal) {
            position = (maxScrollExtent -
                        screenWidth * widget.ratioOfBlankToScreen +
                        widgetWidth) /
                    2 -
                widgetWidth +
                pixels -
                maxScrollExtent;
          } else {
            position = (maxScrollExtent -
                        screenHeight * widget.ratioOfBlankToScreen +
                        widgetHeight) /
                    2 -
                widgetHeight +
                pixels -
                maxScrollExtent;
          }
          scrollController.jumpTo(position);
        }
        position += _moveDistance;
        scrollController.animateTo(position,
            duration: Duration(milliseconds: _timerRest), curve: Curves.linear);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  Widget getBothEndsChild(String str) {
    if (widget.scrollAxis == Axis.vertical) {
      //  String newString = widget.text.split("").join("\n");
      return Container(
          width: screenWidth,
          child: Text(
            // widget.text,
            str + "    |    ",
            style: widget.textStyle,

            textAlign: TextAlign.center,
          ));
    }
    return Container(
        width: screenWidth,
        child: Text(
          // widget.text,
          str + "    |    ",
          style: widget.textStyle,
        ));
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }

  var cnt=0;
  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
          onTap: () => {

            print('gesture detected'+cnt.toString()),

           if(widget.arrimpnews[cnt-1].id! == '459')
             {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) {
                     return ExciseDutyScreen(
                       slugname:
                       'prices/excise-duty-on-export-of-petrol-diesel-atf-and-special-additional-excise-duty-saed-on-domestic-crude-oil-production',
                     );
                   },
                 ),
               )
             }
           else{
          ApiData.pdfUrl =
          widget.arrimpnews[cnt-1].imagePath!.replaceAll(' ', '%20'),

    print(ApiData.pdfUrl),
    if (Platform.isAndroid) {
      print("android permission"),
      setState(() {
    widget.arrimpnews[cnt-1].isdownload = true;
      }),
      if (widget.arrimpnews[cnt-1].imagePath!.isEmpty) {
        setState(() {
    widget.arrimpnews[cnt-1].isdownload = false;
        }),
        Fluttertoast.showToast(
            msg: "No file to download",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xffAB0E1E),
            textColor: Colors.white,
            fontSize: 16.0),
      } else {
        downloadxlsfileimpnews(
            dio, ApiData.pdfUrl.toString(), widget.arrimpnews[cnt]),
      }
    } else if (Platform.isIOS) {
      setState(() {
    widget.arrimpnews[cnt-1].isdownload = true;
      }),
      if (widget.arrimpnews[cnt-1].imagePath!.isEmpty) {
        setState(() {
    widget.arrimpnews[cnt-1].isdownload = false;
        }),
        Fluttertoast.showToast(
            msg: "No file to download",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xffAB0E1E),
            textColor: Colors.white,
            fontSize: 16.0),
      } else {
        downloadiosimpnews(
            dio, ApiData.pdfUrl.toString(),  widget.arrimpnews[cnt-1]),
      }
    }
           }
          },
    child:
      ListView.builder(
      key: _key,
     controller: scrollController,
      scrollDirection: widget.scrollAxis,
      itemBuilder: (context, index) {
        print("index" + index.toString());
        cnt =index;
        var singleChildScrollView = SingleChildScrollView(
          child: Row(
            children: getCenterChild(widget.arrimpnews[index].title.toString(),
                widget.arrimpnews[index]),

          ),
        );
        return singleChildScrollView;
          // GestureDetector(
          //   behavior: HitTestBehavior.translucent,
          //   onTap: () {
          //     widget.arrimpnews[index].id! == '459'
          //         ? Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) {
          //                 return ExciseDutyScreen(
          //                   slugname:
          //                       'prices/excise-duty-on-export-of-petrol-diesel-atf-and-special-additional-excise-duty-saed-on-domestic-crude-oil-production',
          //                 );
          //               },
          //             ),
          //           )
          //         : downloadxlsfileimpnews(
          //             dio, ApiData.pdfUrl.toString(), widget.arrimpnews[index]);
          //   },
          //   child: singleChildScrollView);
      },
      itemCount: widget.arrimpnews.length,
    ));
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }
    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  Future downloadxlsfileimpnews(Dio dio, String url, ImpNews objimpnews) async {
    try {
      File file = File(url);
      savename = file.getFileNamenew();
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
        objimpnews.isdownload = false;
      } else if (fileext == "pdf") {
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/pdf');
        objimpnews.isdownload = false;
      } else if (fileext == "xlsx") {
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path,
            type:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        objimpnews.isdownload = false;
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      isdownload = false;
      _progress = "Completed";
    });
  }

  Future<void> downloadiosimpnews(
      Dio dio, String url, ImpNews objimpnews) async {
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
      if (fileext == "xls") {
        await OpenFile.open(filepath, type: "com.microsoft.excel.xls");
        objimpnews.isdownload = false;
      } else if (fileext == "pdf") {
        await OpenFile.open(filepath, type: "com.adobe.pdf");
        objimpnews.isdownload = false;
      } else if (fileext == "xlsx") {
        await OpenFile.open(filepath,
            type:
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        objimpnews.isdownload = false;
      } else {
        await OpenFile.open(filepath, type: 'application/vnd.ms-excel');
        objimpnews.isdownload = false;
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

  List<Widget> getCenterChild(String str, ImpNews arrimpnew) {
    List<Widget> list = [];
    if (widget.scrollAxis == Axis.horizontal) {
      list.add(Container(
        alignment: Alignment.centerRight,
        child: Text(
          // widget.text,
          str + "      |      ",
          style: widget.textStyle,
        ),
      ));
    } else {
      list.add(Container(height: screenHeight));
    }
    return list;
  }
}
