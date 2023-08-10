
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../API/Services.dart';
import '../Home/HomeDashboard.dart';

import '../constant.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;

  late AnimationController animationController;
  Animation? animation;



  var aboutStr = '';
  var splitted;

  final guestemail = "guest@ppac.gov.in";
  final guestpassword = "123456@ppac";


  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation!.addListener(() => this.setState(() {}));
    animationController.forward();
  }

  loginApi() async {
    try {
      await Services.instance.loginApi(guestemail, guestpassword).then((value) => savetokenstart(value));
    } catch (e) {
      print(e);
      setState(() {
        _isprocessing = 2;
      });
    }
  }

  void savetokenstart(String token) {
    if (token.isNotEmpty) {
      Prefs.setString("token", token);
      print("Token Get in Get Started: ${Prefs.getString("token")}");

      ApiData.token = Prefs.getString("token").toString();
      setState(() {
        _isprocessing = 0;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              fullscreenDialog: true, builder: (context) => HomeDashboard()));
    } else {
      print("token not available" + "can not move");
    }
  }

  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
  }

  int _isprocessing = 0;

  late Size screen;

  @override
  Widget build(BuildContext context) {

     screen =  MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        Container(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/splash_background.jpg',
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          color: Colors.transparent,
          width: double.infinity,
          margin: EdgeInsets.only(top: 40, left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            //Center Row contents horizontally,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/ppac_logo_full_size.png",
                height: animation!.value * 60,
                width: animation!.value * 240,
              ),
              SizedBox(
                width: 5,
              ),
              Image.asset(
                "assets/images/g20.png",
                height: animation!.value * 60,
                width: animation!.value * 95,
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [StepText(), getcontentwidget(), getactionwidget()],
        ),
      ]),
    );
  }

  Widget getcontentwidget() => Expanded(
        child: Container(
            margin:
                const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0),
            alignment: Alignment.centerLeft,

            padding: Platform.isIOS?const EdgeInsets.only(left: 10, bottom: 20, right: 10):const EdgeInsets.only(left: 22, bottom: 20, right: 20),
            child: Center(
                child: Column(
              children: [
                midText(),
                midtextrest(),
                midtextrestone(),
                midtextresttwo(),
                midtextrestthree(),
                midtextfour(),
                midtextfive(),
                midtextSix()
              ],
            ))),
      );

  Widget getactionwidget() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: animation!.value * 53,
          margin: const EdgeInsets.symmetric(horizontal: 27, vertical: 25),
          // Platform.isIOS
          // ? const EdgeInsets.symmetric(
          //     horizontal: 20, vertical: 25)
          // : const EdgeInsets.symmetric(
          //     horizontal: 20, vertical: 80),
          width: animation!.value * 322,
          child: ElevatedButton(
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xff085196)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          side: const BorderSide(color: Color(0xff085196))))),
              onPressed: () {
                setState(() {
                  StartProcessing();
                });
              },
              child: setUpInitials()
              /*const Text(
                    'Get Started',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'GraphikSemiBold'),
                  )*/

              ),
        ),
      );

  Widget StepText() => Container(
        margin: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 0),
        child: Row(children: [
          Container(
            margin: Platform.isAndroid
                ? const EdgeInsets.only(top: 180)
                : const EdgeInsets.only(top: 150),
            alignment: Alignment.centerLeft,
            padding:
            Platform.isIOS?
            const EdgeInsets.only(left: 10, bottom: 20):
            const EdgeInsets.only(left: 22, bottom: 20),
            child: const Text(
              "About\nPetroleum Planning\n& Analysis Cell",
              style: TextStyle(
                  fontFamily: 'GraphikBold',
                  fontSize: 30,
                  color: Color(0xff111111)),
              textAlign: TextAlign.justify,
            ),
          )
        ]),
      );

  Widget midText() => Container(
          child: Row(
        children: [
          RichText(
            text: TextSpan(
              text: "We monitor and analyse",
              style: const TextStyle(
                  color: Color(0xff111111),
                  fontSize: 22,
                  fontFamily: 'GraphikRegular',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ));




  Widget midtextrest() => Container(
          child: Row(
        children: [
          RichText(
            text: TextSpan(
              text: "trends in",
              style: const TextStyle(
                  color: Color(0xff111111),
                  fontSize: 22,
                  fontFamily: 'GraphikRegular',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          RichText(
            text: TextSpan(
              text: "prices of crude",
              style: const TextStyle(
                  color: Color(0xff007A35),
                  fontSize: 24,
                  fontFamily: 'GraphikBold',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          RichText(
            text: TextSpan(
              text: "oil,",
              style: const TextStyle(
                  color: Color(0xff007A35),
                  fontSize: 24,
                  fontFamily: 'GraphikBold',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ));

  Widget midtextrestone() => Container(
          child: Row(
        children: [
          Expanded(child:
          Container(

            child:

            RichText(
            text: TextSpan(
              text: "petroleum products",
              style: const TextStyle(
                  color: Color(0xff007A35),
                  fontSize: 24,
                  fontFamily: 'GraphikBold',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
          )) ],
      ));

  Widget midtextresttwo() => Container(
          child: Row(
        children: [
          RichText(
            text: TextSpan(
              text: "and",
              style: const TextStyle(
                  color: Color(0xff111111),
                  fontSize: 22,
                  fontFamily: 'GraphikRegular',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),

          SizedBox(
            width: 5,
          ),
          RichText(
            text: TextSpan(
              text: "natural gas",
              style: const TextStyle(
                  color: Color(0xff007A35),
                  fontSize: 24,
                  fontFamily: 'GraphikBold',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          RichText(
            text: TextSpan(
              text: "and their",
              style: const TextStyle(
                  color: Color(0xff111111),
                  fontSize: 22,
                  fontFamily: 'GraphikRegular',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ));

  Widget midtextrestthree() => Container(
        child: Row(
          children: [
        Expanded(child:
        Container(
        width: screen.width * 0.45,
          child:

          RichText(
              text: TextSpan(
                text: "impact on the oil companies",
                style: const TextStyle(
                    color: Color(0xff111111),
                    fontSize: 22,
                    fontFamily: 'GraphikRegular',
                    height: 1.3,
                    letterSpacing: 0.5),
              ),
            ),
        )) ],
        ),
      );

  Widget midtextfour() => Container(
          child: Row(

        children: [
          Expanded(child:
          Container(
          width: screen.width * 0.45,
            child:
          RichText(
            text: TextSpan(
              text: "and consumers, and prepare",
              style: const TextStyle(
                  color: Color(0xff111111),
                  fontSize: 22,
                  fontFamily: 'GraphikRegular',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
          ))],
      ));

  Widget midtextfive() => Container(
          child: Row(
        children: [
          Expanded(child:
          Container(
          width: screen.width * 0.45,
            child:

            RichText(
            text: TextSpan(
              text: "appropriate technical inputs",
              style: const TextStyle(
                  color: Color(0xff111111),
                  fontSize: 22,
                  fontFamily: 'GraphikRegular',
                  height: 1.3,
                  letterSpacing: 0.5),
            ),
          ),
          ))],
      ));

  Widget midtextSix() => Container(
        child: Row(
          children: [
        Expanded(child:
        Container(
        width: screen.width * 0.45,
          child:
          RichText(
              text: TextSpan(
                text: "for policy making.",
                style: const TextStyle(
                    color: Color(0xff111111),
                    fontSize: 22,
                    fontFamily: 'GraphikRegular',
                    height: 1.3,
                    letterSpacing: 0.5),
              ),
            ),
        ))],
        ),
      );

  void StartProcessing() {
    setState(() {
      _isprocessing = 1;
      loginApi();
    });


  }

  Widget setUpInitials() {
    if (_isprocessing == 0) {
      return new Text(
        'Get Started',
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'GraphikSemiBold'),
      );
    } else if (_isprocessing == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else if (_isprocessing == 2) {
      return new Text(
        'Please Try Again',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'GraphikSemiBold'),
      );
    } else {
      return new Text(
        'Get Started',
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'GraphikSemiBold'),
      );
    }
  }
}
