import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'Response/CentralResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstant {
  static String baseurl = "https://ppac.gov.in/";
   static String url = "https://ppac.gov.in/ApiController";


  static String pdfUrlEndpoint = "https://ppac.gov.in/uploads/";
  static String downloadEndpoint = "https://ppac.gov.in/";

  static Future<void> launchURL(String? redirecturl) async {
    if (Platform.isIOS) {
      final parseurl = Uri.parse(redirecturl.toString());
      if (await canLaunchUrl(parseurl)) {
        await launchUrl(parseurl);
      } else {
        throw 'Could not launch $redirecturl';
      }
    } else if (Platform.isAndroid) {
      if (await canLaunch(redirecturl.toString())) {
        await launch(redirecturl.toString());
      } else {
        throw 'Could not launch $url';
      }
    }
  }

}

class MESSAGES {
  static const String INTERNET_ERROR = "No Internet Connection";
  static const String INTERNET_ERROR_RETRY =
      "No Internet Connection.\nPlease Retry";
}

class TABULARPAGECONTENT {
  static String pagetitle = " ";
  static String pagecontent = " ";
  static String pageslug = "";
  static String department = "";
  static String tabs = "";
  static String historyfilename = "";
  static String baseurl = "";
  static String pagename = "";
  static String gaspriceimagepath = "";
  static String metadescriptions = "";
  static String downloadsourcefile = "";
}

class RtiContent {
  static var rtititle = '';
}

class GasPriceContent {
  static var gasPriceTitle = '';
}

class ImportantNewsContent {
  static var impNewsTitle = '';
}

class MainMenuHeadingName {
  static String name = "";
}

class Selectedslugname {
  static String slugname = " ";
}

class COLORS {
// App Colors //

// ignore: constant_identifier_names

  static const Color APP_THEME_RED_COLOR = Color(0xFFAB0E1E);

  static const Color APP_THEME_DARK_RED_COLOR = Color(0xFF8D0C18);

  static const Color APP_THEME_DARK_BLACK_COLOR = Color(0xFF000000);

  static const Color APP_THEME_LIGHT_BLACK_COLOR = Color(0xFF243444);

  static const Color APP_THEME_DARK_GRAY_COLOR = Color(0xFF76848F);

  static const Color APP_THEME_GRAY_COLOR = Color(0xFFA3AAAE);

  static const Color APP_THEME_LIGHT_GRAY_COLOR = Color(0xFFD0D3D4);
}

extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';

  String get allInCaps => toUpperCase();
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class ApiData {

  static var subMenuID = '';
  static var menuID = '';
  static var menuName = '';
  static var submenuName = '';
  static String pdfUrl = '';
  static String token = '';

  static List<CentralTab> centralTab = [];
  static void Reset() {
    menuName = '';
    submenuName = '';
  }

  static int gridclickcount = 0;
  static int iscomingfromhome = 0;
}

class Prefs {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  //sets
  static Future<bool> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  static Future<bool> setInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  static Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

  //gets
  static bool? getBool(String key) => _prefs.getBool(key);

  static double? getDouble(String key) => _prefs.getDouble(key);

  static int? getInt(String key) => _prefs.getInt(key);

  static String? getString(String key) => _prefs.getString(key);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  //deletes..
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();
}
