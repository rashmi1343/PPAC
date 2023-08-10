import 'package:flutter/material.dart';
import 'package:ppac/constant.dart';
import 'package:ppac/Screens/AboutPPAC.dart';

import 'package:ppac/Screens/DocumentViewPageNew.dart';
import 'package:ppac/Screens/SubMenuPage.dart';

import '../Home/HomeDashboard.dart';
import '../Router/route_constants.dart';
import '../Splash/SplashScreen.dart';

class CustomRouter {
  static Route<dynamic> generatedRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashroute:
        return MaterialPageRoute(builder: (_) => SplashScreenPage());

      case homeMenuRoute:
        return MaterialPageRoute(builder: (_) => const HomeDashboard());

      case subMenuRoute:
        return MaterialPageRoute(
            builder: (_) => SubMenuPage(
                  submenuname: ApiData.submenuName,
                  menuname: ApiData.menuName,
                ));

      case docRoute:
        return MaterialPageRoute(
            builder: (_) => DocumentViewPageNew(
                  menuname: ApiData.menuName,
                  submenuname: ApiData.submenuName,
                ));

      default:
        return MaterialPageRoute(
            builder: (_) => AboutPPAC(
                  menuname: ApiData.menuName,
                ));
    }
  }
}
