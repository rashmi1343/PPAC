import 'dart:convert';
import 'dart:io';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ppac/constant.dart';
import 'package:ppac/Response/GasPriceResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Home/HomeDashboard.dart';

class GasPriceListnew extends StatefulWidget {
  const GasPriceListnew({Key? key}) : super(key: key);

  @override
  GasPriceListnewState createState() => GasPriceListnewState();
}

class GasPriceListnewState extends State<GasPriceListnew> {
  String? htmlContent = "";
  String? menuname;
  bool ishtmlload = false;
  String gaspriceimagepath = '';

  int perPage = 5;
  int present = 0;

  TextEditingController editingController = TextEditingController();
  late BuildContext searchdialogContext;

  var dio = Dio();

  var isdownload = false;
  String _progress = "-";
  bool isLoading = true;
  bool isearchbarshow = false;
  double downloadPercentage = 0;

  List<GasPrice> arrgasprice = [];

  List<GasPrice> items = [];
  List<GasPrice> tempitems = [];

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

  Future<List<GasPrice>> fetchGasPriceData() async {
    try {
      Map data = {
        'slug': Selectedslugname.slugname,
        'method': 'getImportExportcontent',
      };
      //encode Map to JSON
      print('param_gas_price:$data');

      final prefs = await SharedPreferences.getInstance();
      menuname = prefs.getString("SharedmenuName");

      ApiData.menuName = menuname.toString();
      print("prefmenuname:${menuname!}");

      var body = utf8.encode(json.encode(data));

      var response = await http
          .post(Uri.parse(ApiConstant.url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + ApiData.token
              },
              body: body)
          .timeout(const Duration(seconds: 500));

      print("${response.statusCode}");

      print(response.body);
      if (response.statusCode == 200) {
        Map decoded = json.decode(response.body);
        print(decoded);
        perPage = 5;
        present = 0;
        arrgasprice = [];
        items = [];
        tempitems = [];

        for (var objgasprice in decoded["GasPrice"]) {
          arrgasprice.add(GasPrice(
              id: objgasprice["id"],
              title: objgasprice["title"],
              imagePath: objgasprice["image_path"],
              content: objgasprice["content"],
              createdAt: objgasprice["created_date"],
              updatedAt: objgasprice["updated_at"]));
        }

        if (arrgasprice.isNotEmpty && decoded["htmlcontent"] == "False") {
          // gasPriceList = gasPriceObj.gasPrice;

          print("Gas Price Data DATA:$arrgasprice");
          print("htmlcontent is false");
          htmlContent = "false";
          ishtmlload = false;
          setStr(htmlContent);
          setState(() {
            isLoading = false;
          });
        } else {
          print("htmlcontent is true");
          htmlContent = "true";
          ishtmlload = true;
          setStr(htmlContent);
          setState(() {
            isLoading = false;
          });
        }

        GasPriceContent.gasPriceTitle = decoded["Page Title"];

        if (arrgasprice.length < perPage) {
          perPage = arrgasprice.length;
        }
        items.addAll(arrgasprice.getRange(present, present + perPage));
        present = present + perPage;

        tempitems = items;

        print("items length:" + items.length.toString());

        if (items.length == 0) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Something went wrong.Please try again!!',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontFamily: 'GraphikMedium',
            ),
          ),
        ));
        throw Exception('Failed to load data');
      }

      return arrgasprice;
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  onSearch(String search) {
    setState(() {
      if (editingController.text.isEmpty) {
        items = tempitems;
        isearchbarshow = false;
      } else {
        isearchbarshow = true;
        items = arrgasprice
            .where((objgas) =>
                objgas.title.toLowerCase().contains(search.toLowerCase()) ||
                objgas.content.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
    });
  }

  void loadMore() {
    setState(() {
      if ((present + perPage) > arrgasprice.length) {
        items.addAll(arrgasprice.getRange(present, arrgasprice.length));
      } else {
        items.addAll(arrgasprice.getRange(present, present + perPage));
      }
      present = present + perPage;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchGasPriceData();
  }

  @override
  Widget build(BuildContext context) {
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
            title: isearchbarshow
                ? Container(
                    margin: const EdgeInsets.all(2.5),
                    padding: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xff085196),
                        style: BorderStyle.solid,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      autofocus: true,
                      controller: editingController,
                      style: const TextStyle(color: Color(0xff085196)),
                      cursorColor: Color(0xff085196),
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                      ),
                      onChanged: (text) {
                        print("text to search" + text.toString());
                        onSearch(text);
                      },
                    ))
                : Transform(
                    // you can forcefully translate values left side using Transform
                    transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                    child: Text(
                      GasPriceContent.gasPriceTitle,
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
            actions: Platform.isAndroid
                ? <Widget>[
                    GestureDetector(
                      onTap: () {
                        //showSearchbar();
                        setState(() {
                          if (isearchbarshow) {
                            isearchbarshow = false;
                            fetchGasPriceData();

                            print("1234" + items.length.toString());
                            editingController.clear();
                          } else {
                            isearchbarshow = true;
                            print("6789");
                          }
                        });
                      },
                      child: isearchbarshow
                          ? Container(

                              margin: const EdgeInsets.only(right: 5, left: 5),
                              height: 18,
                              width: 18,
                              child: SvgPicture.asset(
                                "assets/images/xmark-solid.svg",
                                color: const Color(0xff111111),
                              ),
                            )
                          : Container(

                              margin: const EdgeInsets.only(right: 20),
                              height: 18,
                              width: 18,
                              child: SvgPicture.asset(
                                "assets/images/magnifying-glass.svg",
                                color: const Color(0xff111111),
                              )),
                    )
                  ]
                : [
                    IconButton(
                      icon: isearchbarshow
                          ? const Icon(Icons.close,
                              color: Color(0xff085196), size: 20)
                          : SvgPicture.asset(
                              "assets/images/magnifying-glass.svg",
                              color: const Color(0xff085196),
                              height: 18,
                            ),
                      onPressed: () {
                        setState(() {
                          if (isearchbarshow) {
                            isearchbarshow = false;
                            items = tempitems;
                            present = 5;

                            print("1234");
                            editingController.clear();
                          } else {
                            isearchbarshow = true;
                            print("6789");
                          }
                        });
                      },
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
                              ApiData.menuName.isNotEmpty
                                  ? TextSpan(children: <TextSpan>[
                                      TextSpan(children: [
                                        TextSpan(
                                            text: ApiData.menuName,
                                            style: const TextStyle(
                                                color: Color(0xff111111),
                                                fontSize: 13,
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

                                      ])
                                    ])
                                  : TextSpan(
                                      text: ApiData.submenuName,
                                      style: const TextStyle(
                                          color: Color(0xff111111),
                                          fontSize: 13,
                                          fontFamily: 'GraphikLight'),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // navigate to desired screen
                                        }),
                              TextSpan(
                                  text: GasPriceContent.gasPriceTitle,
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
                            color: Color(0xff085196),
                          ))
                      : Platform.isAndroid
                          ? showGasPriceListView()
                          : isdownload
                              ? showDownloadProgressForiOS()
                              : showGasPriceListView()
                ],
              ),
            ),
          ))
    ]);
  }

  showDownloadProgressForiOS() {
    return Center(
      child: Container(

        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        alignment: Alignment.center,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 110,
          height: 110,
          alignment: Alignment.center,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Color(0xffF2F2F2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: downloadPercentage / 100,
                color: Color(0xff085196),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "$_progress downloaded",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xff085196),
                    fontSize: 14,
                    fontFamily: 'GraphikMedium'),
              )
            ],
          ),
        ),
      ),
    );
  }

  showGasPriceListView() {
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10),
        physics: const ScrollPhysics(),
        itemCount:
            (present <= arrgasprice.length) ? items.length + 1 : items.length,
        itemBuilder: (BuildContext context, int index) {
          return (index == items.length)
              ? isearchbarshow
                  ? Container()
                  : Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xff085196),
                          style: BorderStyle.solid,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        child: items.isNotEmpty
                            ? const Text(
                                'Load More',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontFamily: 'GraphikMedium',
                                ),
                              )
                            : const Text(
                                'No data available',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontFamily: 'GraphikMedium',
                                ),
                              ),
                        onPressed: () {
                          setState(() {
                            if ((present + perPage) > arrgasprice.length) {
                              items.addAll(arrgasprice.getRange(
                                  present, arrgasprice.length));
                              present = present + perPage;
                            } else {
                              items.addAll(arrgasprice.getRange(
                                  present, present + perPage));
                              present = present + perPage;
                            }
                          });
                        },
                      ),
                    )
              : Center(
                  child: Card(
                    elevation: 20,
                    shadowColor: Colors.black,
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      height: 130,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    width: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      items[index].createdAt.toString(),
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
                                height: 7,
                              ),
                              Text(
                                items[index].title,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: "GraphikMedium"), //Textstyle
                              ), //Text
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ApiData.pdfUrl = items[index].imagePath;
                                    print(ApiData.pdfUrl);
                                    if (Platform.isAndroid) {
                                      print("android permission");

                                      downloadxlsfile(
                                          dio, ApiData.pdfUrl.toString());
                                    } else if (Platform.isIOS) {
                                      downloadios(
                                          dio, ApiData.pdfUrl.toString());
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
                                    minimumSize: const Size(151.92, 36),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                          "assets/images/download-solid.svg",
                                          width: 20,
                                          height: 20,
                                          color: Colors.white),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
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
                          ),
                        ),
                      ),
                    ),
                  ),
                );
        });
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

        OpenFile.open(file1.path, type: 'application/vnd.ms-excel');
      } else if (fileext == "pdf") {
        File file1 = File("/storage/emulated/0/Download/Report.pdf");
        var raf = file1.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();

        OpenFile.open(file1.path, type: 'application/pdf');
      } else if (fileext == "PDF") {
        File file1 = File("/storage/emulated/0/Download/Report.PDF");
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

  Future<void> downloadios(Dio dio, String url) async {
    //  Dio dio = Dio();
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
          //  downloading = true;
          isdownload = true;
          _progress = "${((rec / total) * 100).toStringAsFixed(0)}%";
        });
      });
      OpenFile.open(filepath, type: 'application/vnd.ms-excel');


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


}
