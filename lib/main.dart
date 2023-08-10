import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'Router/custom_router.dart';
import 'Router/route_constants.dart';
import 'Splash/SplashScreen.dart';
import 'constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 3000;

  await Prefs.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPAC',
      home: SplashScreenPage(),
      debugShowCheckedModeBanner: false,
      supportedLocales: [
        Locale("en", "US"),
      ],
      debugShowMaterialGrid: false,
      onGenerateRoute: CustomRouter.generatedRoute,
      initialRoute: splashroute,
    );
  }
}
