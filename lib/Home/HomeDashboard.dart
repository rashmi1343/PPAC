import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:dio/dio.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ppac/Gallery/GalleryPage.dart';
import 'package:ppac/Gallery/SubMediaGallery.dart';

import 'package:ppac/Response/GalleryResponse.dart';
import 'package:ppac/Response/ImportantNewsResponse.dart';
import 'package:ppac/Screens/WhatsNew.dart';
import 'package:ppac/Widgets/RtiDataListnew.dart';
import 'package:ppac/constant.dart';
import 'package:ppac/Gallery/AllMediaGallery.dart';
import 'package:ppac/ImportantNews/importantnews.dart';
import 'package:ppac/Model/DashboardModel.dart';
import 'package:ppac/Model/ppactrackermodel.dart';
import 'package:ppac/Screens/AboutPPAC.dart';
import 'package:html/parser.dart';

import 'package:ppac/Screens/ppacnewspage.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../API/Services.dart';
import '../ConnectionUtil.dart';
import '../Model/HomeDashboardReportModel.dart';
import '../Model/MainMenuModel.dart';
import '../Screens/ExciseDutyScreen.dart';
import '../Screens/SubMenuPage.dart';
import '../SizeConfig.dart';
import '../Widgets/ScrollingText.dart';
import 'SnapshotOfIndiaWidget.dart';
import 'gridcells.dart';

extension FileNameExtension on File {
  String getFileNamenew() {
    String fileName = path.split('/').last;
    return fileName;
  }
}

const defaultbackground = Colors.white;
const tapcolor = Colors.green;

enum Colour { defaultbackrgound, tapcolor }

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  _HomeDashboardPageState createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboard>
    with SingleTickerProviderStateMixin {
  // double getSize(BuildContext context) {
  //   double deviceHeight = MediaQuery.of(context).size.height;
  //   if (deviceHeight > 1000) return deviceHeight * 0.16;
  //   if (deviceHeight > 800) return deviceHeight * 0.18;
  //   if (deviceHeight > 600) return ScreenSize.Normal;
  //   return ScreenSize.Small;
  // }

  late AnimationController animationController;
  Animation? animation;

  StreamSubscription? connection;
  List<DashboardModel> gridCells = [];

  List<ppactrackermodel> arrppactracker = [];
  List<Widget> widppactracker = [];
  List<Widget> widimpnews = [];
  List<Widget> widgallery = [];

  List<reportstudiesmodel> arrreportstudies = [];
  List<forecastanalysismodel> arrforecastanalysis = [];

  List<MediaGallery>? mediaGalleryList = [];

  List<MediaGallery>? arrmediagallery = [];

  List<Report> reportDataArr = [];
  List<ImpNews> impnewlist = [];

  bool isdataconnection = true;

  int currentPos = 0;

  // bool isLoading = true;
  var Internetstatus = "Unknown";
  List<Menu> menu = [];
  List<Menu> drawermenu = [];
  bool isLoading = true;

  var dio = Dio();
  String savename = '';
  var isdownload = false;
  String _progress = "-";
  double downloadPercentage = 0;

//  List<Menu> drawermenu = [];
  bool loading = false;
  bool permissionGranted = true;
  var allTodos = [];
  int pageIndex = 0;
  int pageIndeximpnew = 0;
  int pageIndexgallery = 0;
  bool storagePer = false;
  BuildContext? dcontext;

  int _selectedIndex = 0;

  void checkPermissions() async {
    var storagestatus = await Permission.storage.status;
    var managestoragestatus = await Permission.manageExternalStorage.status;

    if (!storagestatus.isPermanentlyDenied &&
        !managestoragestatus.isPermanentlyDenied) {
      _showAlert(context);
    }

    setState(() {
      storagePer = true;
    });
  }

  Future<List<MediaGallery>?> getAllMediaGalleryData() async {
    try {
      Map allgallerydata = {"method": "getdetails", "type": "Media Gallery"};

      print('allgallerydata:$allgallerydata');

      var body = utf8.encode(json.encode(allgallerydata));

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
          List<dynamic> data = jsonDecode(response.body)['Media Gallery Hm'];

          if (data.length > 0) {
            mediaGalleryList =
                data.map((item) => MediaGallery.fromJson(item)).toList();
            print("mediaGalleryList:$mediaGalleryList");
            int cntgallery = 0;
            mediaGalleryList?.forEach((element) {
              widgallery.add(creategalleryslider(element));
              arrmediagallery?.add(element);
            });
            widgallery.add(viewallimagesgallery());
            setState(() {
              isLoading = true;
              getReportData();
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

        return mediaGalleryList;
      } else {
        throw Exception('Failed to load Media Gallery');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<List<ImpNews>> fetchImportantNewsData() async {
    try {
      Map impNewsdata = {"method": "getdetails", "type": "impnews"};

      print('impNews:$impNewsdata');

      var body = utf8.encode(json.encode(impNewsdata));

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
          List<dynamic> data = jsonDecode(response.body)['ImpNews'];

          if (data.length > 0) {
            impnewlist = data.map((item) => ImpNews.fromJson(item)).toList();
            print("Important News:$impnewlist");

            for (var element in impnewlist) {
              print("News element:${element.title}");
              widimpnews.add(createnewsmarquee(element, element.title));
            }

            setState(() {
              isLoading = true;
              getAllMediaGalleryData();
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

        return impnewlist;
      } else {
        throw Exception('Failed to load important news');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<List<ppactrackermodel>> getppactracker(url) async {
    try {
      Map data = {'method': 'getdetails', 'type': 'tracker'};
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

        arrppactracker = [];
        int cnt = 0;
        var data = [];

        var data2 = [];
        var data3 = [];


        var strtitle = [];
        var strdata = [];

        for (var objtracker in decoded["Tracker"]) {
          var contentdata = objtracker["content"];

          var document = parse(contentdata);

          data = document.getElementsByTagName('h5');

          data.forEach((element) {
            print(element.text);

            var strtxt = element.text.toString();

            var splitedtitle = strtxt.split('\n');

            strtitle.add(strtxt);
            if (splitedtitle.length == 1) {
              print("p 1" + splitedtitle[0]);
            } else {
              print("p 1" + splitedtitle[0]);
              print("p 2" + splitedtitle[1]);
            }

            cnt++;
          });

          data2 = document.getElementsByTagName('h6');

          data2.forEach((element) {
            print("percentage" + element.text);

            var splittedperiod = element.text.toString().split('\n');

            strdata.add(element.text);
            if (splittedperiod.length == 1) {
              print("text 1" + splittedperiod[0]);
            } else {
              print("text 1 " + splittedperiod[0]);
              print("text 2 " + splittedperiod[1]);
            }
          });

          data3 = document.getElementsByClassName('perid');
        }

        print("cnt length" + cnt.toString());

        for (int i = 0; i < cnt; i++) {
          arrppactracker.add(ppactrackermodel(
              title: data[i].text,
              units: data2[i].text,
              period: data3[i].text));
        }

        setState(() {
          isdataconnection = true;
          isLoading = false;
        });
        return arrppactracker;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Widget createnewsmarquee(ImpNews objimpnews, String? title) {

    print("filepath"+objimpnews.imagePath.toString());

    return  ScrollingText(textStyle: TextStyle(fontFamily: 'GraphikMedium'), arrimpnews: impnewlist);
  }

  Widget createnews(ImpNews objimpnews) {
    return Container(
      alignment: Alignment.center,
      height: 550,
      width: 300,
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: const Color(0xffF3F3F3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xffB4B4B4),
            blurRadius: 1.0,
          ),
        ],
        color: const Color(0xffffffff),
      ),
      child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  child: Text(
                objimpnews.createdAt.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xff085196),
                    fontFamily: 'GraphikMedium'),
              )),
              const SizedBox(
                height: 5,
              ),
              Flexible(
                  child: Text(
                objimpnews.title.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff111111),
                    fontFamily: 'GraphikMedium'),
              )),
              const SizedBox(
                height: 5,
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    ApiData.pdfUrl =
                        objimpnews.imagePath!.replaceAll(' ', '%20');

                    print(ApiData.pdfUrl);
                    if (Platform.isAndroid) {
                      print("android permission");
                      setState(() {
                        objimpnews.isdownload = true;
                      });
                      if (objimpnews.imagePath!.isEmpty) {
                        setState(() {
                          objimpnews.isdownload = false;
                        });
                        Fluttertoast.showToast(
                            msg: "No file to download",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color(0xffAB0E1E),
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        downloadxlsfileimpnews(
                            dio, ApiData.pdfUrl.toString(), objimpnews);
                      }
                    } else if (Platform.isIOS) {
                      setState(() {
                        objimpnews.isdownload = true;
                      });
                      if (objimpnews.imagePath!.isEmpty) {
                        setState(() {
                          objimpnews.isdownload = false;
                        });
                        Fluttertoast.showToast(
                            msg: "No file to download",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color(0xffAB0E1E),
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {
                        downloadiosimpnews(
                            dio, ApiData.pdfUrl.toString(), objimpnews);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff085196),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    minimumSize: const Size(151.92, 36),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/images/download-solid.svg",
                          width: 20, height: 20, color: Colors.white),
                      SizedBox(
                        width: 5,
                      ),
                      (objimpnews.isdownload)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ))
                          : Text(
                              'Download',
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
                ),
              ),
            ],
          )),
    );
  }

  Widget viewallimagesgallery() {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 1, color: const Color(0xffF3F3F3)),
        color: Colors.grey.withOpacity(0.2),
      ),
      height: 550,
      width: 300,
      child: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
            child: Text(
              "View All",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'GraphikMedium'),
            ),
            onPressed: () {}),
      ),
    );
  }

  Widget creategalleryslider(MediaGallery objgallery) {
    return InkWell(
        onTap: () {
          ApiData.iscomingfromhome = 1;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SubMediaGallery(
                  title: objgallery.catTitle.toString(),
                  id: objgallery.id.toString())));
        },
        child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 1, color: const Color(0xffF3F3F3)),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border:
                        Border.all(width: 1, color: const Color(0xffF3F3F3)),
                  ),
                  child: Hero(
                    tag: objgallery,
                    child: CachedNetworkImage(
                      imageUrl: objgallery.imagePath.toString(),
                      memCacheHeight: 150,
                      memCacheWidth: 200,
                      height: 120,
                      width: 150,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => SizedBox(
                        child: Image.asset(
                          'assets/images/no_image.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  objgallery.catTitle.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11.0,
                      color: Color(0xff000000),
                      fontFamily: 'GraphikMedium'),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
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

  Future downloadxlsfilereport(
      Dio dio, String url, reportstudiesmodel objreportmodel) async {
    try {
      File file = File(url);
      savename = file.getFileNamenew();
      String savePath = '/storage/emulated/0/Downloads' + "/$savename";
      print(savePath);

      String fileext = savename.split('.').last;

      var dir =
          await _getDownloadDirectory(); //await getApplicationDocumentsDirectory();
      print("path ${dir?.path ?? ""}");

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
        objreportmodel.isdownloadreport = false;
      } else if (fileext == "pdf") {
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);

        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/pdf');
        objreportmodel.isdownloadreport = false;
      } else if (fileext == "xlsx") {
        File file1 = File("/storage/emulated/0/Downloads/${savename}");
        var raf = file1.openSync(mode: FileMode.write);

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

  Future downloadxlsfileforecast(
      Dio dio, String url, forecastanalysismodel objanalysismodel) async {
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

  Future<void> downloadiosreportstudies(
      Dio dio, String url, reportstudiesmodel objreportstudies) async {
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
          //  downloading = true;
          isdownload = true;
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

  startTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('first_time');

    if (firstTime != null && !firstTime) {
      // Not first time

      print("Second time launching");
    } else {
      // First time
      prefs.setBool('first_time', false);
      return checkPermissions();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print("index:" + _selectedIndex.toString());
    });
    if (_selectedIndex == 1) {
      ApiData.gridclickcount = 0;

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ppacnewspage()));

      _selectedIndex = 0;
    } else if (_selectedIndex == 2) {
      ApiData.gridclickcount = 0;

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => WhatsNewView()));

      _selectedIndex = 0;
    }
  }

  Widget getbottombar() {
    return BottomNavigationBar(
        backgroundColor: Color(0xff085196),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Color(0xff085196)),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_alert_outlined),
            label: ' PPAC News',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_alert),
              label: 'What’s New',
              backgroundColor: Color(0xff085196)),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        iconSize: 25,
        onTap: _onItemTapped,
        elevation: 5);
  }

  late PageController pageController;

  @override
  void initState() {
    super.initState();

    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connectionStatus.connectionChange.listen(connectionChanged);

    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation!.addListener(() => this.setState(() {}));
    animationController.forward();

    scrollController = ScrollController();

    pageController = PageController(initialPage: 0, viewportFraction: 0.8);

    startTime(); //Luanching for first time condition

    ApiData.menuName = "";
    ApiData.submenuName = "";
  }

  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
  }

  getReportData() async {
    await Services.instance
        .fetchHomeDashboardReportData()
        .then((data) => reportDataArr = data);
    print('reportDataArr: $reportDataArr');

    getppactracker(ApiConstant.url);
    return reportDataArr;
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
        Map decoded = json.decode(response.body);

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
        return arrforecastanalysis;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
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
          isLoading = true;
          getforcastanalysisfromapi(ApiConstant.url);
        });
        return arrreportstudies;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<List<Menu>> fetchMainMenuData(String url) async {
    Map data = {
      'parent_id': '0',
      'menugrp_id': '1',
      'method': 'getAllMenus',
    };
    //encode Map to JSON
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
          drawermenu = [];
          menu = [];

          for (var objMenuTitle in decoded["Menu"]) {
            var menuTitle = objMenuTitle['name'];
            print("File Title:$menuTitle");

            if (objMenuTitle['n_id'] != "78") {
              menu.add(Menu(
                nId: objMenuTitle['n_id'],
                parentId: objMenuTitle['parent_id'],
                name: objMenuTitle['name'],
                slug: objMenuTitle['slug'],
                targetBlank: objMenuTitle['target_blank'],
                position: objMenuTitle['position'],
                language: objMenuTitle['language'],
                status: objMenuTitle['status'],
                createdAt: objMenuTitle['created_at'],
                createdBy: objMenuTitle['created_by'],
                updatedAt: objMenuTitle['updated_at'],
                updatedBy: objMenuTitle['updated_by'],
                relId: objMenuTitle['rel_id'],
                menuId: objMenuTitle['menu_id'],
                groupId: objMenuTitle['group_id'],
              ));
            }
            drawermenu.add(Menu(
              nId: objMenuTitle['n_id'],
              parentId: objMenuTitle['parent_id'],
              name: objMenuTitle['name'],
              slug: objMenuTitle['slug'],
              targetBlank: objMenuTitle['target_blank'],
              position: objMenuTitle['position'],
              language: objMenuTitle['language'],
              status: objMenuTitle['status'],
              createdAt: objMenuTitle['created_at'],
              createdBy: objMenuTitle['created_by'],
              updatedAt: objMenuTitle['updated_at'],
              updatedBy: objMenuTitle['updated_by'],
              relId: objMenuTitle['rel_id'],
              menuId: objMenuTitle['menu_id'],
              groupId: objMenuTitle['group_id'],
            ));
          }

          setState(() {
            isdataconnection = true;
            isLoading = true;

            fetchImportantNewsData();
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
    } else {
      throw Exception('Failed to load');
    }
    return menu;
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected TO The Internet";
        fetchMainMenuData(ApiConstant.url);
        isdataconnection = true;

        print('Data connection is available.');
      } else if (!isdataconnection) {
        Internetstatus = "No Data Connection";
        isdataconnection = false;
        print('You are disconnected from the internet.');

        loading = false;
      }
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text(
              'Confirm Exit',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff111111),
                  fontFamily: 'GraphikBold'),
            ),
            content: const Text(
              'Are you sure you want to exit?',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff111111),
                  fontFamily: 'GraphikSemiBold'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'No',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontFamily: 'GraphikMedium'),
                ),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff085196),
                      fontFamily: 'GraphikMedium'),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  late ScrollController scrollController;

  var imp = 0;
  int selectedIndex = -1;
  int selectedIndextracker = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final height = MediaQuery.of(context).size.height;
    print("height:$height");
    Size size = WidgetsBinding.instance.window.physicalSize;
    double ratio = WidgetsBinding.instance.window.devicePixelRatio;
    double deviceHeight = size.height;
    print("deviceHeight:$deviceHeight");
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));

    return isdataconnection
        ? Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/splash_background.jpg',
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              WillPopScope(
                onWillPop: _onWillPop,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    toolbarHeight: 90,
                    centerTitle: false,
                    titleSpacing: 5.0,
                    elevation: 1,
                    title: Transform(
                      // you can forcefully translate values left side using Transform
                      transform: Matrix4.translationValues(-5.0, 0.0, 0.0),
                      child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/PPAC_LOGO_NEW.png",
                              height: animation!.value * 60,
                              width: animation!.value * 200,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              "assets/images/g20.png",
                              height: animation!.value * 60,
                              width: animation!.value * 75,
                            ),
                          ],
                        ),
                      ),
                    ),
                    backgroundColor: const Color(0xffFFFFFF),
                    shadowColor: const Color(0xff00000A),
                    leading: Builder(
                      builder: (context) => Container(
                        margin: const EdgeInsets.only(left: 8),
                        height: 30,
                        width: 30,
                        child: IconButton(
                          alignment: Alignment.centerLeft,
                          icon: Image.asset(
                            "assets/images/menu_icon.png",
                            height: 30,
                            width: 30,
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                    ),
                  ),
                  drawer: Drawer(
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.zero,
                            height: 120.0,
                            child: DrawerHeader(
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/PPAC_LOGO_NEW.png",
                                    height: 55,
                                    width: 270,
                                  ),
                                ],
                              ),
                            )),
                        Expanded(child: DrawerWidget(elementlist: drawermenu)),
                        Container(
                          padding: EdgeInsets.zero,
                          height: Platform.isIOS ? 90.0 : 115,
                          child: DrawerHeader(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/g20.png",
                                  height: 85,
                                  width: 150,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                          color: Color(0xff085196),
                        ))
                      : SingleChildScrollView(
                          child: Container(
                            // height: 1500,
                            margin: EdgeInsets.only(
                                left: 5, top: 5, right: 5, bottom: 0),
                            child: Center(
                              child: Column(
                                children: [
                                  ExpansionTileCard(
                                    baseColor: Colors.cyan[50],
                                    expandedColor: Colors.red[50],
                                    title: Text("Mann ki Baat",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: const Color(0xff085196),
                                            fontFamily: 'GraphikBold')),
                                    children: <Widget>[
                                      Divider(
                                        thickness: 1.0,
                                        height: 1.0,
                                      ),
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 8.0,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: ApiConstant
                                                      .downloadEndpoint +
                                                  "uploads/banner/1679977110_d824485709e27cbd4519.jpg",
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                margin: EdgeInsets.all(10),
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                        "Important News",
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: const Color(
                                                                0xff085196),
                                                            fontFamily:
                                                                'GraphikBold')))),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              margin:
                                                  EdgeInsets.only(right: 15),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (_) {
                                                    return ImportantNews();
                                                  }));
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
                                                      const Size(100.92, 36),
                                                ),
                                                child: Wrap(
                                                  children: <Widget>[
                                                    const Text(
                                                      'View All',
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
                                        SizedBox(height: 10),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 5,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          height: 30,
                                          // width: 332,
                                          width: double.infinity,
                                          child: PageView(
                                            children: widimpnews,
                                            onPageChanged: (index) {
                                              setState(() {
                                                pageIndex = index;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 20),
                                  LayoutBuilder(
                                      builder: (context, constraints) {
                                    return GridView.builder(
                                      physics: const ScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: menu.length,
                                      scrollDirection: Axis.vertical,
                                      padding: const EdgeInsets.only(
                                          top: 15, left: 1, right: 1),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 1,
                                        mainAxisExtent: 95,
                                        crossAxisCount: 4,
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          child:
                                              HomeGridCell(menu[index], index),
                                          onTap: () =>
                                              gridClicked(index, menu[index]),
                                        );
                                      },
                                    );
                                  }),
                                  SizedBox(height: 20),
                                  Container(
                                      margin: EdgeInsets.all(10),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text("PPAC Tracker",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color:
                                                      const Color(0xff085196),
                                                  fontFamily: 'GraphikBold')))),
                                  SizedBox(height: 10),
                                  Container(
                                      margin:
                                          EdgeInsets.only(left: 5, right: 5),
                                      height:
                                      height * .16,
                                      width: double.infinity,
                                      child: PageView.builder(
                                          controller: pageController,
                                          itemCount: arrppactracker.length,
                                          onPageChanged: (index) {
                                            setState(() {
                                              selectedIndex = index;
                                              selectedIndextracker = index;
                                            });
                                          },
                                          itemBuilder: (_, pageIndex) {
                                            var splittedtitle =
                                                arrppactracker[pageIndex]
                                                    .title
                                                    .toString()
                                                    .split("\n");
                                            var splittedperiod =
                                                arrppactracker[pageIndex]
                                                    .units
                                                    .toString()
                                                    .split("\n");

                                            return GridView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              primary: true,
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisSpacing: 4,
                                                      mainAxisSpacing: 5,
                                                      childAspectRatio: 2.3,
                                                      crossAxisCount: 1),
                                              itemCount: arrppactracker.length,
                                              itemBuilder: (context, index) =>
                                                  GestureDetector(
                                                      //You need to make my child interactive

                                                      onTap: () => {
                                                            setState(() {
                                                              selectedIndex =
                                                                  pageIndex;

                                                              print(
                                                                  'Selected tracker : ${selectedIndex}');
                                                            })
                                                          },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            7)),
                                                                //  borderRadius: BorderRadius.circular(10),
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: const Color(
                                                                        0xffF3F3F3)),
                                                                color: selectedIndex ==
                                                                        pageIndex
                                                                    ? const Color(
                                                                        0xff007a35)
                                                                    : const Color(0xffD4D4D4)),
                                                        margin: EdgeInsets.only(
                                                            right: 20),
                                                        height: selectedIndex ==
                                                                pageIndex
                                                            ? 510
                                                            : 510,
                                                        width: selectedIndex ==
                                                                pageIndex
                                                            ? 310
                                                            : 310,
                                                        // constraints:
                                                        //     const BoxConstraints(
                                                        //   maxHeight:
                                                        //       double.infinity,
                                                        // ),
                                                        child: Column(

                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            SizedBox(height: 12,),




                                                            selectedIndex == 0
                                                                ? Flexible( 
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 1
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 2
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 3
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 4
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 5
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 6
                                                                ? Flexible(
                                                                child:
                                                                Container(

                                                                    child:


                                                                    Image
                                                                        .asset(
                                                                      'assets/images/ic_petrol_white_png.png',
                                                                        color: Colors.white,
                                                                    )

                                                                ))
                                                                : selectedIndex == 7
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/gas-pump.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 8
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/gas-pump.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 9
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/LPG.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 10
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                :selectedIndex == 11
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 12
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : selectedIndex == 13
                                                                ? Flexible(
                                                                child:
                                                                Container(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/images/cng.svg',
                                                                      color: const Color(
                                                                          0xffffffff),
                                                                    )))
                                                                : Flexible(
                                                                child: SvgPicture
                                                                    .asset(
                                                                  'assets/images/cng.svg',
                                                                  color: const Color(
                                                                      0xff000000),
                                                                )),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            selectedIndex ==
                                                                    pageIndex
                                                                ? Flexible(
                                                                    child: Text(
                                                                    maxLines: 2,
                                                                    splittedtitle[
                                                                        0],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,

                                                                        color: const Color(
                                                                            0xffffffff),
                                                                        fontFamily:
                                                                            'GraphikMedium'),
                                                                  ))
                                                                : Flexible(
                                                                    child: Text(
                                                                    splittedtitle[
                                                                        0],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: const Color(
                                                                            0xff085196),
                                                                        fontFamily:
                                                                            'GraphikMedium'),
                                                                  )),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            selectedIndex ==
                                                                    pageIndex
                                                                ? Flexible(
                                                                    child: Text(
                                                                    splittedperiod[
                                                                        0],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: const Color(
                                                                            0xffffffff),
                                                                        fontFamily:
                                                                            'GraphikMedium'),
                                                                  ))
                                                                : Flexible(
                                                                    child: Text(
                                                                    splittedperiod[
                                                                        0],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: Color(
                                                                            0xff111111),
                                                                        fontFamily:
                                                                            'GraphikMedium'),
                                                                  )),
                                                            const SizedBox(
                                                              height: 3,
                                                            ),
                                                            selectedIndex ==
                                                                    pageIndex
                                                                ? Flexible(
                                                                    child: Text(
                                                                    arrppactracker[
                                                                            pageIndex]
                                                                        .period,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: const Color(
                                                                            0xffffffff),
                                                                        fontFamily:
                                                                            'GraphikMedium'),
                                                                  ))
                                                                : Flexible(
                                                                    child: Text(
                                                                    arrppactracker[
                                                                            pageIndex]
                                                                        .period,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: Color(
                                                                            0xfffa4d0b),
                                                                        fontFamily:
                                                                            'GraphikMedium'),
                                                                  ))
                                                          ],
                                                        ),
                                                      )),
                                            );
                                          })),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 15,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: arrppactracker.length,
                                      itemBuilder: (_, index) {
                                        return GestureDetector(
                                            onTap: () {
                                              pageController.animateToPage(
                                                  index,
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeInOut);
                                            },
                                            child: AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 100),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: selectedIndextracker ==
                                                          index
                                                      ? const Color(0xff085196)
                                                      : Colors.grey),
                                              margin: EdgeInsets.all(5),
                                              width: 10,
                                              height: 10,
                                            ));
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Container(
                                    height: 280,
                                    width: MediaQuery.of(context).size.width,
                                    child: SnapshotOfIndiaWidget(
                                      reportDataArr: reportDataArr,
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  Container(
                                      margin: EdgeInsets.all(10),
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text("Gallery",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color:
                                                      const Color(0xff085196),
                                                  fontFamily: 'GraphikBold')))),
                                  Container(
                                    margin: EdgeInsets.only(left: 5, right: 5),
                                    height: 600,
                                    width: double.infinity,
                                    child: Container(
                                      height: 700,
                                      child: Column(
                                        children: [
                                          Expanded(
                                              child: GridView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: arrmediagallery?.length,
                                            scrollDirection: Axis.vertical,
                                            padding: const EdgeInsets.all(5),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing: 1,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: 2,
                                              mainAxisExtent: 130,
                                              crossAxisCount: 2,
                                            ),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return GestureDetector(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: const Color(
                                                              0xffF3F3F3)),
                                                      color: Colors.white,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(2),
                                                        border: Border.all(
                                                            width: 1,
                                                            color: const Color(
                                                                0xffF3F3F3)),
                                                        image: DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: NetworkImage(
                                                              arrmediagallery![
                                                                      index]
                                                                  .imagePath
                                                                  .toString()),
                                                        ),
                                                      )),
                                                      //  ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                      return GalleryPage(
                                                          imageUrl:
                                                              arrmediagallery![
                                                                      index]
                                                                  .imagePath
                                                                  .toString(),
                                                          imageTitle:
                                                              arrmediagallery![
                                                                      index]
                                                                  .catTitle
                                                                  .toString());
                                                    }));
                                                  });
                                            },
                                          )),
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (_) {
                                                  return AllMediaGallery();
                                                }));
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
                                                    const Size(100.92, 36),
                                              ),
                                              child: Wrap(
                                                children: <Widget>[
                                                  const Text(
                                                    'View All',
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
                                          )
                                        ],
                                      ),
                                    ),
                                  ),

                                  //  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                  bottomNavigationBar: getbottombar(),
                ),
              )
            ],
          )
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

  gridClicked(int index, Menu data) async {
    print('gridClicked : $index, ${data.menuId}');
    ApiData.menuName = data.name;
    ApiData.subMenuID = data.menuId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("SharedmenuName");
    ApiData.submenuName = '';
    prefs.setString('SharedmenuName', ApiData.menuName);
    print("stored_menuname:${ApiData.menuName}");

    Selectedslugname.slugname = data.slug;

    //78=RTI
    if (data.nId == "78") {
      Platform.isIOS
          ? Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RtiDataListnew()))
          : Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: RtiDataListnew(),
                  inheritTheme: true,
                  ctx: context),
            );
    }
    //229=ABOUT US
    else if (data.nId == "229") {
      Platform.isIOS
          ? Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AboutPPAC(
                    menuname: ApiData.menuName,
                  )))
          : Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: AboutPPAC(
                    menuname: ApiData.menuName,
                  ),
                  inheritTheme: true,
                  ctx: context),
            );
    } else {
      Platform.isIOS
          ? Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SubMenuPage(
                    menuname: ApiData.menuName,
                    submenuname: ApiData.submenuName,
                  )))
          : Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: SubMenuPage(
                    menuname: ApiData.menuName,
                    submenuname: ApiData.submenuName,
                  ),
                  inheritTheme: true,
                  ctx: context),
            );
    }
  }

  Future _showAlert(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        title: const Text(
          "Permission Required",
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'GraphikBold',
            color: Color(0xffAB0E1E),
          ),
        ),
        content: Container(
          padding: EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
          child: const Text(
            "Please allow permission to view or download files.",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'GraphikRegular',
              color: Color(0xff243444),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await Permission.storage.request();
              await Permission.manageExternalStorage.request();
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'GraphikRegular',
                  color: Color(0xff243444),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerWidget extends StatefulWidget {
  late BuildContext context;
  late final List<Menu> elementlist;

  DrawerWidget({required this.elementlist});

  @override
  State<StatefulWidget> createState() => _DrawerState();
}

class _DrawerState extends State<DrawerWidget> {
  setDrawerIcon(String icon) {
    return SvgPicture.asset(
      "assets/images/$icon.svg",
      width: 22,
      height: 22,
      color: const Color(0xff085196),
    );
  }

  setDrawerTitle(Menu element) {
    return Transform.translate(
      offset: const Offset(-20, 0),
      child: Text(
        element.name,
        style: const TextStyle(
          color: Color(0xff111111),
          fontSize: 14,
          fontFamily: 'GraphikMedium',
        ),
      ),
    );
  }

  Future<void> drawerItemOnTapMethod(int index, Menu element) async {
    print('gridClicked : $index, ${element.menuId}');
    ApiData.menuName = element.name;
    ApiData.subMenuID = element.menuId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("SharedmenuName");
    ApiData.submenuName = '';
    prefs.setString('SharedmenuName', ApiData.menuName);
    print("stored_menuname:${ApiData.menuName}");

    Selectedslugname.slugname = element.slug;

    if (element.name == "RTI") {
      Platform.isIOS
          ? Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RtiDataListnew()))
          : Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  // child: RtiDataList(),
                  child: RtiDataListnew(),
                  inheritTheme: true,
                  ctx: context),
            );
    } else {
      Platform.isIOS
          ? Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SubMenuPage(
                    menuname: ApiData.menuName,
                    submenuname: ApiData.submenuName,
                  )))
          : Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: SubMenuPage(
                    menuname: ApiData.menuName,
                    submenuname: ApiData.submenuName,
                  ),
                  inheritTheme: true,
                  ctx: context),
            );
    }
  }

  List<Widget> _getChildren(final List<Menu> elementlist) {
    List<Widget> children = [];
    elementlist.toList().asMap().forEach((index, element) {
      try {
        switch (index) {
          case 0:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("circle-info"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
          case 1:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("coins"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
          case 2:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("export"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
          case 3:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("production"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
          case 4:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("consumpation"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
          case 5:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("fire-flame-simple"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
          case 6:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("gas-pump"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
          case 7:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("file-chart-column"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
          default:
            children.add(
              Container(
                height: 50,
                child: ListTile(
                  leading: setDrawerIcon("gavel-light"),
                  title: setDrawerTitle(element),
                  onTap: () async {
                    await drawerItemOnTapMethod(index, element);
                  },
                ),
              ),
            );
            break;
        }
      } catch (err) {
        print('Caught error: $err');
      }
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: _getChildren(widget.elementlist),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    print("init drawer called");
  }
}
