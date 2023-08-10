import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:convert';

import 'package:ppac/constant.dart';

import 'package:http/http.dart' as http;

import '../Home/HomeDashboard.dart';

import '../Response/AllMediaGalleyResponse.dart';

import '../SizeConfig.dart';
import 'SubMediaGallery.dart';



class SubMediaImages {
  List<String> image;

  final String title;

  SubMediaImages(this.image, this.title);
}

class AllMediaGallery extends StatefulWidget {
  @override
  AllMediaGalleryState createState() => AllMediaGalleryState();
}

class AllMediaGalleryState extends State<AllMediaGallery> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAllMediaGalleryData();
  }

  List<AllMediaGalleryList>? mediaGalleryList = [];

  Future<List<AllMediaGalleryList>?> getAllMediaGalleryData() async {
    try {
      Map allgallerydata = {"method": "getdetails", "type": "Gallery Category"};

      print('allgallerydata:$allgallerydata');

      var body = utf8.encode(json.encode(allgallerydata));

      var response = await http
          .post(Uri.parse(ApiConstant.url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${ApiData.token}",
          },
          body: body)
          .timeout(const Duration(seconds: 500));

      print("${response.statusCode}");

      print(response.body);

      if (response.statusCode == 200) {
        try {
          List<dynamic> data = jsonDecode(response.body)['Media Gallery'];

          if (data.length > 0) {
            mediaGalleryList =
                data.map((item) => AllMediaGalleryList.fromJson(item)).toList();
            print("mediaGalleryList:$mediaGalleryList");
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Something went wrong.Please try again!!',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'GraphikRegular',
                      fontSize: 15),
                ),
                backgroundColor: Color(0xff085196),
              ));
            });
          }
        } on Exception catch (e) {
          print("unable to load data");
          setState(() {
            isLoading = false;

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Something went wrong.Please try again!!',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'GraphikRegular',
                    fontSize: 15),
              ),
              backgroundColor: Color(0xff085196),
            ));
          });
        }

        return mediaGalleryList;
      } else {
        throw Exception('Failed to load Media Gallery');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<bool> _onWillPop() async {
    print("back called");
    ApiData.gridclickcount = 1;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HomeDashboard()));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
      WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white.withOpacity(0.2),
          appBar: AppBar(
            toolbarHeight: 99,
            centerTitle: true,
            titleSpacing: 0.0,
            elevation: 1,
            title: Transform(

              transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
              child: Text(
                "Media Gallery",
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
            actions: <Widget>[
              Row(
                children: [
                  Container(

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
                    ApiData.gridclickcount = 1;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HomeDashboard()));
                  },
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                      margin:
                      const EdgeInsets.only(left: 15, right: 15, top: 2),
                      width: double.infinity,
                      height: 50,

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
                                  text: "Media Gallery",
                                  style: const TextStyle(
                                      color: Color(0xff111111),
                                      fontSize: 14,
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
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(

                      "Photo Category",
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontFamily: 'GraphikBold',
                        fontSize: 17,
                        color: Color(0xff243444),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  isLoading
                      ? Container(
                      margin: EdgeInsets.only(top: 200),
                      child: const CircularProgressIndicator(
                          color: Color(0xff085196)))
                      : LayoutBuilder(builder: (context, constraints) {
                    return GridView.builder(
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: mediaGalleryList!.length,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.all(5),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 18,
                        childAspectRatio: 2,
                        mainAxisExtent: 180,
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      width: 1,
                                      color: const Color(0xffF3F3F3)),
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(2),
                                          border: Border.all(
                                              width: 1,
                                              color: const Color(
                                                  0xffF3F3F3)),
                                        ),

                                        child: Hero(
                                          tag: mediaGalleryList![index],
                                          child: CachedNetworkImage(
                                            imageUrl:
                                            mediaGalleryList![index]
                                                .thumbnailImage
                                                .toString(),
                                            memCacheHeight: 150,
                                            memCacheWidth: 200,
                                            height: 120,
                                            width: 150,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                SizedBox(
                                                  child: Image.asset(
                                                    'assets/images/no_image.png',
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        mediaGalleryList![index]
                                            .catTitle
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 11.0,
                                            color: Color(0xff000000),
                                            fontFamily: 'GraphikMedium'),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type:
                                      PageTransitionType.rightToLeft,
                                      child: SubMediaGallery(
                                          title: mediaGalleryList![index]
                                              .catTitle
                                              .toString(),
                                          id: mediaGalleryList![index]
                                              .id
                                              .toString()),
                                      inheritTheme: true,
                                      ctx: context));
                            });
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      )
    ]);
  }
}
