import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant.dart';

class WebviewIOS extends StatefulWidget {
  String slugname;

  WebviewIOS({required this.slugname});

  @override
  _WebviewIOSState createState() => _WebviewIOSState();
}

class _WebviewIOSState extends State<WebviewIOS> {
  late InAppWebViewController _webViewController;
  String url = "";
  double progress = 0;
  var isdownload = false;
  var isWebviewdownloaded = false;
  String _progress = "-";
  var dio = Dio();
  int _stackToView = 0;

  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _stackToView,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(25.0),
                child: progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container()),
            Container(
              width: screenSize.width,
              height: 510.0,
              color: Colors.transparent,
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                  url: Uri.parse(Uri.encodeFull(
                      '${ApiConstant.baseurl}${widget.slugname}')),
                ),
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        // javaScriptEnabled: true,
                        transparentBackground: true,
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                        allowFileAccessFromFileURLs: true,
                        supportZoom: true,
                        preferredContentMode: UserPreferredContentMode.MOBILE,
                        useOnLoadResource: true)),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onLoadError: (controller, url, _, error) {
                  print('error: $error');
                },
                initialUserScripts: UnmodifiableListView([
                  UserScript(source: """
                window.addEventListener('DOMContentLoaded', function(event) {
                  var header = document.querySelector('.elementor-location-header'); // use here the correct CSS selector for your use case
                  if (header != null) {
                    header.remove(); // remove the HTML element. Instead, to simply hide the HTML element, use header.style.display = 'none';
                  }
                  var footer = document.querySelector('.elementor-location-footer'); // use here the correct CSS selector for your use case
                  if (footer != null) {
                    footer.remove(); // remove the HTML element. Instead, to simply hide the HTML element, use footer.style.display = 'none';
                  }
                });
                """, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START)
                ]),
                onLoadStart: (controller, url) {
                  setState(() {
                    isWebviewdownloaded = false;

                    this.url = url.toString();
                    if (ApiData.subMenuID == "134") {
                      _webViewController.evaluateJavascript(
                          source:
                              "document.getElementsByClassName('btn float-sm-end float-start btn_ppac01')[0].remove()"); // Download button in location refinery
                    }
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('right_buttons')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");

                    _webViewController.evaluateJavascript(
                        source:
                            "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");

                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('nav nav-tabs mobc gallery-tab border-0')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('nav nav-tabs gallery-tab border-0')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            'document.getElementsByTagName("mat-toolbar")[0].remove();');
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByTagName('right_buttons')[0].remove();"); //'document.getElementsByTagName("right_buttons")[0].remove();');

                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('data_b1')[0].style.display='none';");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('data_b1')[1].style.display='none';");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('go-top')[0].remove()");

                    _webViewController
                        .evaluateJavascript(
                            source:
                                "document.getElementsByClassName('right_buttons')[0].style.display='none';document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';document.getElementsByClassName(\"inner_banner\")[0].style.display='none';document.getElementsByClassName(\"bredcrum\")[0].style.display='none';document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';document.getElementsByClassName(\"header\")[0].style.display='none';document.querySelector('header').style.display = 'none';document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
                        .then((value) =>
                            debugPrint('Page finished loading Javascript'))
                        .catchError((onError) => debugPrint('$onError'));
                    _stackToView = 0;
                  });
                },
                onLoadStop: (controller, url) async {
                  setState(() {
                    isWebviewdownloaded = true;
                    if (ApiData.subMenuID == "134") {
                      _webViewController.evaluateJavascript(
                          source:
                              "document.getElementsByClassName('btn float-sm-end float-start btn_ppac01')[0].remove()");
                    }
                    _webViewController.evaluateJavascript(
                        source:
                            "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");

                    _webViewController.evaluateJavascript(
                        source:
                            "javascript:(function() { var head = document.getElementsByTagName('header')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");

                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('d-flex flex-wrap mt-4')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal cpd-tab')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('list-group list-group-horizontal')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('nav nav-tabs mobc gallery-tab border-0')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('nav nav-tabs gallery-tab border-0')[0].remove()");
                    _webViewController.evaluateJavascript(
                        source:
                            'document.getElementsByTagName("mat-toolbar")[0].remove();');
                    _webViewController.evaluateJavascript(
                        source:
                            'document.getElementsByTagName("right_buttons")[0].remove();');

                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('data_b1')[0].style.display='none';");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('data_b1')[1].style.display='none';");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('go-top')[0].remove()");

                    _webViewController
                        .evaluateJavascript(
                            source:
                                "document.getElementsByClassName(\"right_buttons\")[0].style.display='none';document.getElementsByClassName(\"owl-stage-outer\")[0].style.display='none';document.getElementsByClassName(\"inner_banner\")[0].style.display='none';document.getElementsByClassName(\"bredcrum\")[0].style.display='none';document.getElementsByClassName(\"partner-sec py-4 border-top\")[0].style.display='none';document.getElementsByClassName(\"header\")[0].style.display='none';document.querySelector('header').style.display = 'none';document.getElementsByClassName(\"partner-sec\")[0].style.display='none';")
                        .then((value) =>
                            debugPrint('Page finished loading Javascript'))
                        .catchError((onError) => debugPrint('$onError'));

                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('bredcrum')[0].style.display='none'");
                    _webViewController.evaluateJavascript(
                        source:
                            "document.getElementsByClassName('inner_banner')[0].style.display='none'");

                    this.url = url.toString();
                    print(this.url);
                  });
                  Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                      _stackToView = 1;
                    });
                  });
                },
                gestureRecognizers: Set()
                  ..add(Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer())),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final uri = navigationAction.request.url!;
                  // var uri = Uri.parse(url);
                  print('shouldOverrideUrlLoading 216:${uri.toString()}');

                  print('ApiData.subMenuID:${ApiData.subMenuID}');

                  final pageImages = uri.toString().contains(
                      RegExp(r'/uploads/page-images/', caseSensitive: false));
                  final uploadPages = uri.toString().contains(
                      RegExp(r'/uploads/pages/', caseSensitive: false));
                  final viewofficeapps = uri.toString().startsWith(RegExp(
                      r'https://view.officeapps.live.com/',
                      caseSensitive: false));
                  final File file = File(uri.toString());
                  final _fileextenion = extension(file.path);
                  print(file.path);
                  print(_fileextenion);

                  if (uri.toString().contains(
                      'https://ppac.gov.in/infrastructure/installed-refinery-capacity')) {
                    print('in install capacity method');
                    // return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '134' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '108' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '120' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '115' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '25' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '63' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '203' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '193' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '262' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '131' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '132' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '133' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '135' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '136' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((ApiData.subMenuID == '141' &&
                      !viewofficeapps &&
                      (_fileextenion == '.xls' ||
                          _fileextenion == '.pdf' ||
                          _fileextenion == '.xlsx'))) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if (uploadPages &&
                      (ApiData.subMenuID == '141' && !viewofficeapps) &&
                      (ApiData.subMenuID == '203' && !viewofficeapps)) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if (pageImages &&
                      (ApiData.subMenuID == '262' && !viewofficeapps)) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if (pageImages &&
                      (ApiData.subMenuID == '120' && !viewofficeapps) &&
                      (ApiData.subMenuID == '25' && !viewofficeapps)) {
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if ((uri
                              .toString()) // For international price of crude oil
                          .contains('${ApiConstant.baseurl}uploads/reports/') &&
                      ApiData.subMenuID != '193') {
                    print(uri);
                    _launchURL(uri);
                    return NavigationActionPolicy.CANCEL;
                  } else if (uri.toString().contains("mailto:")) {
                    if (await canLaunchUrl(uri)) {
                      launchUrl(Uri.parse("$uri?subject=" "&body=" ""));
                      return NavigationActionPolicy.CANCEL;
                    }
                  } else {}
                  return NavigationActionPolicy.ALLOW;
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    this.progress = progress / 100;
                    print(progress);
                  });
                },
              ),
            )
          ],
          // ]
        ),
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
      setState(() {
        _stackToView = 1;
      });
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

  launchURL2(url) async {
    final encodedUrl = Uri.encodeFull(url);

    print('encodedUrl: $encodedUrl');

    if (await canLaunch(encodedUrl)) {
      await launch(encodedUrl);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL(url) async {
    setState(() {
      _stackToView = 0;
    });
    print('Launch URL Called, Submenu id: ${ApiData.subMenuID}');

    final uploadPages = url
        .toString()
        .contains(RegExp(r'/uploads/pages/', caseSensitive: false));
    final uploadPagesImages = url
        .toString()
        .contains(RegExp(r'/uploads/page-images/', caseSensitive: false));
    final uploadPages2 = url.toString().contains(RegExp(
        r'https://view.officeapps.live.com/op/embed.aspx?',
        caseSensitive: false));
    if (await canLaunchUrl(url)) {
      print('Downloading in webios launchURL, ${ApiData.subMenuID}');
      if (!uploadPages2) {
        downloadios(dio, url.toString());
      } else if (url
          .toString()
          .contains('https://ppac.gov.in/uploads/reports/')) {
        await downloadios(dio, url.toString());
      } else if (url
          .toString()
          .contains('https://ppac.gov.in/uploads/pages/1669640423_Refy')) {
        downloadios(dio, url.toString());
      } else {
        throw 'launch url:${Uri.encodeFull(url.toString())}';
      }
    }
  }
}
