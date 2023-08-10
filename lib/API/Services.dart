import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ppac/constant.dart';
import 'package:ppac/Model/AboutModel.dart';

import '../Model/HomeDashboardReportModel.dart';

import '../Response/LoginResponse.dart';

import 'package:device_info/device_info.dart';

class Services {
  static Services? _instance;

  Services._();

  static Services get instance => _instance ??= Services._();

  String url = ApiConstant.url;

  String identifier = '';
  String deviceName = '';
  String deviceVersion = '';
  static String pagecontentId = " ";
  static int htmlContent = 0;
  final showLog = true; // false;

  showLogs(String data) {
    if (showLog) {
      if (kDebugMode) {
        print(data);
      }
    }
  }

  Future<String> fetchAboutData() async {
    try {
      Map data = {
        'method': 'getContents',
      };

      var body = utf8.encode(json.encode(data));

      print("data:$data");
      var response = await http
          .post(Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${ApiData.token}",
              },
              body: body)
          .timeout(const Duration(seconds: 500));
      showLogs("${response.statusCode}");
      showLogs(response.body);
      if (response.statusCode == 200) {
        final aboutData = aboutModelFromJson(response.body);
        return aboutData.content.isNotEmpty
            ? aboutData.content[0].pageContents
            : '';
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<List<Report>> fetchHomeDashboardReportData() async {
    try {
      Map data = {
        "method": "getdetails",
        "type": "Report",
      };

      var body = utf8.encode(json.encode(data));

      print("data:$data");
      var response = await http
          .post(Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${Prefs.getString("token").toString()}"
              },
              body: body)
          .timeout(const Duration(seconds: 500));
      showLogs("${response.statusCode}");
      showLogs(response.body);
      if (response.statusCode == 200) {
        final reportList = homeDashboardReportModelFromJson(response.body);
        return reportList.report ?? [];
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<String> loginApi(String email, String password) async {
    String token = '';
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.androidId;
        Prefs.setString("deviceid", identifier);
        print("identifier " + identifier);
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor;
        Prefs.setString("deviceid", identifier);

        print("identifier" + identifier);
      }

      Map data = {
        "method": "login",
        "email": email,
        "password": password,
        "deviceid": identifier
      };
      //encode Map to JSON

      var body = utf8.encode(json.encode(data));

      print("data:$data");
      var response = await http
          .post(Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${ApiData.token}",
              },
              body: body)
          .timeout(const Duration(seconds: 500));
      showLogs("${response.statusCode}");
      showLogs(response.body);
      if (response.statusCode == 200) {
        final loginResponse = loginResponseFromJson(response.body);
        token = loginResponse.token.toString();
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    } on PlatformException {
      print('Failed to get platform version');
    }
    return token;
  }
}
