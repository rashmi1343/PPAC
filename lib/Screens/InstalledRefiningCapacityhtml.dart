import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ppac/constant.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';



import '../Home/HomeDashboard.dart';

class InstalledRefiningCapacityHtml extends StatefulWidget {
  String slugname;

  InstalledRefiningCapacityHtml({required this.slugname});

  @override
  InstalledRefiningCapacityHtmlState createState() {
    return InstalledRefiningCapacityHtmlState();
  }
}

class InstalledRefiningCapacityHtmlState
    extends State<InstalledRefiningCapacityHtml> {

  bool isLoading = true;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  var loadingPercentage = 0;
  late WebViewController _webViewController;
  var isdownload = false;
  String _progress = "-";
  var dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  final _key = UniqueKey();
  int _stackToView = 1;
  int index = 0;
  MediaQueryData? queryData;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print("size:$size");

    queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData!.devicePixelRatio;
    print("devicePixelRatio:$devicePixelRatio");
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
              transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
              child: Text(
                // 'Petroleum',
                "Installed Refinery Capacity",
                softWrap: true,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontFamily: 'GraphikBold',
                  fontSize: 17,
                  color: Color(0xff243444),
                ),
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
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
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Expanded(child: _stackedContainers()),
                ],
              ),
            ),
          ))
    ]);
  }

  Future<void> downloadios(Dio dio, String url) async {
    print('Download url $url');
    File file = File(url);
    String fileName = file.path.split('/').last;

    String fileext = fileName.split('.').last;

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

  _launchURL(url) async {
    if (await canLaunch(url)) {
      if (Platform.isAndroid) {
        await launch(url);

        _webViewController.loadUrl(
            "javascript:var footer = document.querySelector('footer').style.display = 'none'; " +
                "var header = document.querySelector('header').style.display = 'none'; ");

        _webViewController.runJavascript(
            "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
        _webViewController.runJavascript(
            "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
        _webViewController.runJavascript(
            "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");
        _webViewController.runJavascript(
            "document.getElementsByClassName('nav nav-tabs mobc gallery-tab border-0')[0].remove()");
        _webViewController.runJavascript(
            "document.getElementsByClassName('nav nav-tabs gallery-tab border-0')[0].remove()");

        // _webViewController.runJavascript(
        //     "document.getElementsByClassName('d-sm-flex my-5 align-items-center pan01')[0].style.display='none';");
        _webViewController.runJavascript(
            "document.getElementsByClassName('data_b1')[0].style.display='none';");
        _webViewController.runJavascript(
            "document.getElementsByClassName('data_b1')[1].style.display='none';");
        // _webViewController.runJavascript(
        //     "document.getElementsByClassName('rigt_s text-md-end')[0].style.display='display';");

        _webViewController
            .runJavascript("document.getElementsByClassName(\"right_buttons\")[0].style.display='none';" +
                "document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';" +
                "document.getElementsByClassName(\"inner_banner\")[0].style.display='none';" +
                "document.getElementsByClassName(\"bredcrum\")[0].style.display='none';" +
                "document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';" +
                "document.getElementsByClassName(\"header\")[0].style.display='none';" +
                "document.querySelector('header').style.display = 'none';" +
                "document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
            .then((value) => debugPrint('Page finished loading Javascript'))
            .catchError((onError) => debugPrint('$onError'));
      } else if (Platform.isIOS) {
        if (ApiData.subMenuID != '193') {
          downloadios(dio, url.toString());
        }
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _stackedContainers() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double devicePixelRatio = queryData!.devicePixelRatio;
    return Container(
      height: 554,
      child: IndexedStack(
        index: _stackToView,
        children: <Widget>[
          Container(
            height: screenHeight - keyboardHeight,
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 2),
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
                                text: "Infrastructure",
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
                                text: "Installed Refinery Capacity",
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
                SizedBox(
                  height: 10,
                ),

                Expanded(
                  child: Container(
                    height: devicePixelRatio,
                    child: WebView(
                      initialUrl: '${ApiConstant.baseurl}${widget.slugname}',
                      javascriptMode: JavascriptMode.unrestricted,
                      zoomEnabled: false,
                      onWebViewCreated: (WebViewController webViewController) {
                        setState(() {
                          _webViewController = webViewController;
                          _controller.complete(webViewController);
                        });
                      },
                      onProgress: (int progress) {
                        print("WebView is loading (progress : $progress%)");
                        setState(() {
                          loadingPercentage = progress;
                        });


                        if (progress > 10) {


                          _webViewController.loadUrl(
                              "javascript:var footer = document.querySelector('footer').style.display = 'none'; " +
                                  "var header = document.querySelector('header').style.display = 'none'; ");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('bredcrum')[0].style.display='none'");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('inner_banner')[0].style.display='none'");

                          _webViewController.runJavascript(
                              "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('nav nav-tabs mobc gallery-tab border-0')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('nav nav-tabs gallery-tab border-0')[0].remove()");

                           _webViewController.runJavascript(
                              "document.getElementsByClassName('data_b1')[0].style.display='none';");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('data_b1')[1].style.display='none';");

                          _webViewController
                              .runJavascript("document.getElementsByClassName(\"right_buttons\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"inner_banner\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"bredcrum\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"header\")[0].style.display='none';" +
                                  "document.querySelector('header').style.display = 'none';" +
                                  "document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
                              .then((value) => debugPrint(
                                  'Page finished loading Javascript'))
                              .catchError((onError) => debugPrint('$onError'));
                        }
                      },
                      onPageStarted: (String url) {
                        print('Page started loading: $url');
                        setState(() {
                          loadingPercentage = 0;
                        });
                      },
                      onPageFinished: (String url) {
                        print('Page finished loading: $url');

                        _webViewController.runJavascript(
                            "document.getElementsByClassName('go-top')[0].remove()");
                        _webViewController.runJavascript(
                            "document.getElementsByClassName('bredcrum')[0].style.display='none'");
                        _webViewController.runJavascript(
                            "document.getElementsByClassName('inner_banner')[0].style.display='none'");

                        if (Platform.isIOS) {
                          _webViewController.runJavascript("javascript:(function() { " +
                              "var head = document.getElementsByTagName('header')[0];" +
                              "head.parentNode.removeChild(head);" +
                              "var footer = document.getElementsByTagName('footer')[0];" +
                              "footer.parentNode.removeChild(footer);" +
                              "})()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('nav nav-tabs mobc gallery-tab border-0')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('d-sm-flex my-5 align-items-center pan01')[0].remove()");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('bredcrum')[0].style.display='none'");
                          _webViewController.runJavascript(
                              "document.getElementsByClassName('inner_banner')[0].style.display='none'");

                          _webViewController
                              .runJavascript("document.getElementsByClassName(\"right_buttons\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"inner_banner\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"bredcrum\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';" +
                                  "document.getElementsByClassName(\"header\")[0].style.display='none';" +
                                  "document.querySelector('header').style.display = 'none';" +
                                  "document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
                              .then((value) => debugPrint(
                                  'Page finished loading Javascript'))
                              .catchError((onError) => debugPrint('$onError'));
                        }

                        setState(() {
                          _stackToView = 0;
                          isLoading = false;
                        });
                      },
                      gestureRecognizers: <
                          Factory<OneSequenceGestureRecognizer>>{
                        Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer()),
                        Factory<HorizontalDragGestureRecognizer>(
                            () => HorizontalDragGestureRecognizer()),
                        Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer()),
                        Factory<ScaleGestureRecognizer>(
                            () => ScaleGestureRecognizer()),
                      },
                      navigationDelegate: (NavigationRequest request) {
                        if (request.url.contains("mailto:")) {
                          canLaunchUrl(Uri(scheme: 'mailto', path: ''))
                              .then((bool result) {
                            launchUrl(
                              Uri(scheme: 'mailto', path: ''),
                              mode: LaunchMode.externalApplication,
                            );
                          });
                          return NavigationDecision.prevent;
                        } else if (request.url.contains(
                            "${ApiConstant.baseurl}infrastructure/location-of-refineries")) {
                          _launchURL(request.url);
                          return NavigationDecision.prevent;
                        } else if (request.url.contains(
                            "${ApiConstant.baseurl}organization-chart")) {
                          _launchURL(request.url);
                          return NavigationDecision.prevent;
                        } else if (request.url
                            .contains("${ApiConstant.baseurl}uploads/")) {
                          _launchURL(request.url);
                          return NavigationDecision.prevent;
                        } else if (request.url.contains(
                            "https://www.bharatpetroleum.in/index.aspx")) {
                          launchURL2(request.url);
                          return NavigationDecision.prevent;
                        } else if (request.url.contains(
                            "https://www.iocl.com/petrol-diesel-price")) {
                          launchURL2(request.url);
                          return NavigationDecision.prevent;
                        } else if (request.url
                            .contains("http://www.hpretail.in/pricebuildup")) {
                          launchURL2(request.url);
                          return NavigationDecision.prevent;
                        }

                        return NavigationDecision.navigate;
                      },
                      gestureNavigationEnabled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loadingPercentage < 100)
            Center(
              child: Container(
                width: 110,
                height: 110,
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
                      value: loadingPercentage / 100.0,
                      color: Color(0xff085196),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "  Loading...\nPlease wait..",
                      style: TextStyle(
                          color: Color(0xff085196),
                          fontSize: 14,
                          fontFamily: 'GraphikMedium'),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

launchURL2(url) async {
  final encodedUrl = Uri.encodeFull(url);

  print('encodedUrl: $encodedUrl');

  if (await canLaunch(encodedUrl)) {
    await launch(encodedUrl);
  } else {
    throw 'Could not launch $url';
  }
}

void showToast() {
  Fluttertoast.showToast(
    msg: 'Something went wrong!',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Color(0xff085196),
    textColor: Colors.white,
  );
}


