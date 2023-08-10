import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ppac/constant.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class WebHtml extends StatefulWidget {
  String slugname;

  WebHtml({required this.slugname});

  @override
  WebHtmlState createState() {
    return WebHtmlState();
  }
}

class WebHtmlState extends State<WebHtml> {
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
    print("subMenuID in webhtml:${ApiData.subMenuID}");
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }

  @override
  void dispose() {
    _connectivitySubscription!.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result);
        break;
      default:
        setState(() => _connectionStatus = result);
        break;
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result!);
  }

  final _key = UniqueKey();
  int _stackToView = 1;
  int indexPosition = 1;
  late ConnectivityResult _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  int _page = 1;
  bool showLoader = true;

  beginLoading(String value) {
    setState(() {
      indexPosition = 1;
      loadingPercentage = 0;
    });
  }

  completeLoading(String value) {
    setState(() {
      indexPosition = 0;
      loadingPercentage = 100;
    });
  }

  //return false disables default functionality
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.2),
      body: IndexedStack(
        key:_key ,
        index: indexPosition,
        children: <Widget>[
          Container(
            height: 600,
            child: WebView(
              backgroundColor: Colors.white.withOpacity(0.2),
              initialUrl: '${ApiConstant.baseurl}${widget.slugname}',
              javascriptMode: JavascriptMode.unrestricted,
              zoomEnabled: ApiData.subMenuID == "134" ? true : false,
              onWebViewCreated: (WebViewController webViewController) {
                setState(() {
                  _webViewController = webViewController;
                  //  _controller.complete(webViewController);
                });
              },
              onProgress: (int progress) {
                print("WebView is loading (progress : $progress%)");

                if (progress > 10) {
                  //remove the element with class name

                  ApiData.subMenuID == "134"
                      ? _webViewController.runJavascript(
                          "document.getElementsByClassName('btn float-sm-end float-start btn_ppac01')[0].remove()")
                      : Container();

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
                  _webViewController.runJavascript(
                      "document.getElementsByClassName('bredcrum')[0].style.display='none'");
                  _webViewController.runJavascript(
                      "document.getElementsByClassName('inner_banner')[0].style.display='none'");

                  _webViewController.runJavascript(
                      "document.getElementsByClassName('data_b1')[0].style.display='none';");
                  _webViewController.runJavascript(
                      "document.getElementsByClassName('data_b1')[1].style.display='none';");

                  _webViewController
                      .runJavascript(
                          "document.getElementsByClassName(\"right_buttons\")[0].style.display='none';document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';document.getElementsByClassName(\"inner_banner\")[0].style.display='none';document.getElementsByClassName(\"bredcrum\")[0].style.display='none';document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';document.getElementsByClassName(\"header\")[0].style.display='none';document.querySelector('header').style.display = 'none';document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
                      .then((value) =>
                          debugPrint('Page finished loading Javascript'))
                      .catchError((onError) => debugPrint('$onError'));
                  setState(() {
                    loadingPercentage = progress;
                  });
                }
              },
              onPageStarted: beginLoading,
              onPageFinished: (String url) {
                print('Page finished loading: $url');
                _webViewController.runJavascript(
                    "document.getElementsByClassName('go-top')[0].remove()");
                _webViewController.runJavascript(
                    "document.getElementsByClassName('bredcrum')[0].style.display='none'");
                _webViewController.runJavascript(
                    "document.getElementsByClassName('inner_banner')[0].style.display='none'");

                if (Platform.isIOS) {
                  _webViewController.runJavascript(
                      "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()");
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
                      .runJavascript(
                          "document.getElementsByClassName(\"right_buttons\")[0].style.display='none';document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';document.getElementsByClassName(\"inner_banner\")[0].style.display='none';document.getElementsByClassName(\"bredcrum\")[0].style.display='none';document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';document.getElementsByClassName(\"header\")[0].style.display='none';document.querySelector('header').style.display = 'none';document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
                      .then((value) =>
                          debugPrint('Page finished loading Javascript'))
                      .catchError((onError) => debugPrint('$onError'));
                }
                if (_connectionStatus != ConnectivityResult.none) {
                  completeLoading(url);
                }
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer()),
                Factory<HorizontalDragGestureRecognizer>(
                    () => HorizontalDragGestureRecognizer()),
                Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              },
              navigationDelegate: (NavigationRequest request) {
                print('request.url: ${request.url}');
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
                } else if (request.url
                    .contains("${ApiConstant.baseurl}organization-chart")) {
                  _launchURL(request.url);
                  return NavigationDecision.prevent;
                } else if (request.url
                    .contains("${ApiConstant.baseurl}uploads/")) {
                  _launchURL(request.url);
                  return NavigationDecision.prevent;
                } else if (request.url
                    .contains("https://www.bharatpetroleum.in/index.aspx")) {
                  launchURL2(request.url);
                  return NavigationDecision.prevent;
                } else if (request.url
                    .contains("https://www.iocl.com/petrol-diesel-price")) {
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

  Future<void> downloadios(Dio dio, String url) async {
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
        OpenFile.open(filepath, type: "com.microsoft.excel.xls");
      } else if (fileext == "pdf") {
        OpenFile.open(filepath, type: "com.adobe.pdf");
      } else if (fileext == "xlsx") {
        OpenFile.open(filepath, type: "com.microsoft.excel.xlsx");
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
    print("Download completed in webhtml");
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

        _webViewController.runJavascript(
            "document.getElementsByClassName('data_b1')[0].style.display='none';");
        _webViewController.runJavascript(
            "document.getElementsByClassName('data_b1')[1].style.display='none';");

        _webViewController
            .runJavascript(
                "document.getElementsByClassName(\"right_buttons\")[0].style.display='none';document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';document.getElementsByClassName(\"inner_banner\")[0].style.display='none';document.getElementsByClassName(\"bredcrum\")[0].style.display='none';document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';document.getElementsByClassName(\"header\")[0].style.display='none';document.querySelector('header').style.display = 'none';document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
            .then((value) => debugPrint('Page finished loading Javascript'))
            .catchError((onError) => debugPrint('$onError'));
      } else if (Platform.isIOS) {
        if (ApiData.subMenuID != '120' &&
            ApiData.subMenuID != '131' &&
            ApiData.subMenuID != '132' &&
            ApiData.subMenuID != '133' &&
            ApiData.subMenuID != '135' &&
            ApiData.subMenuID != '141' &&
            ApiData.subMenuID != '108' &&
            ApiData.subMenuID != '115') {
          print('Downloading in webhtml, ${ApiData.subMenuID}');
          downloadios(dio, url.toString());
        }
      }
    } else {
      throw 'Could not launch $url';
    }
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
