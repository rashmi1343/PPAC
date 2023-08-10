import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:splash_screen_view/SplashScreenView.dart';


import 'GetStartedNew.dart';



class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AnimationSplash();
}

class AnimationSplash extends State<SplashScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/splash_background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SplashScreenView(
          backgroundColor: Colors.transparent,
          navigateRoute: AnimatedSplashScreen(),
          duration: 6000,
          imageSize: 200,
          pageRouteTransition: PageRouteTransition.CupertinoPageRoute,
          imageSrc: "assets/images/ppac_logo.png",
          speed: 40,
          text:
          "Petroleum Planning & Analysis Cell \n (Ministry of Petroleum & Natural Gas)",
          textType: TextType.TyperAnimatedText,
          textStyle: TextStyle(
            height: 1.5,
              fontFamily: 'GraphikMedium',
              fontSize: 15,
              color: Color(0xff085196)),
        ),
      ],
    ));
  }
}
