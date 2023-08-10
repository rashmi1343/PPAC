import 'dart:io';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';


import 'package:page_transition/page_transition.dart';

import 'dart:convert';

import 'package:ppac/Gallery/AllMediaGallery.dart';
import '../constant.dart';
import '../Home/HomeDashboard.dart';
import '../Response/GalleryByIdResponse.dart';
import 'package:http/http.dart' as http;

import 'FullScreenImage.dart';

extension FileNameExtension on File {
  String getFileName() {
    String fileName = path.split('/').last;
    return fileName;
  }
}

class SubMediaImages {
  List<String> image;

  final String title;

  SubMediaImages(this.image, this.title);
}

class SubMediaGallery extends StatefulWidget {
  String title;
  String id;

  SubMediaGallery({
    required this.title,
    required this.id,
  });

  @override
  SubMediaGalleryState createState() => SubMediaGalleryState();
}

class SubMediaGalleryState extends State<SubMediaGallery> {
  bool isLoading = true;
  String savename = '';
  String catTitle = '';

  @override
  void initState() {
    super.initState();

    getSubGalleryData();
  }

  List<Gallery>? subGalleryList = [];

  Future<List<Gallery>?> getSubGalleryData() async {
    try {
      Map subgallerydata = {"method": "gallery", "id": widget.id};

      print('allgallerydata:$subgallerydata');

      var body = utf8.encode(json.encode(subgallerydata));

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
          List<dynamic> data = jsonDecode(response.body)['Gallery'];

          if (data.length > 0) {
            subGalleryList =
                data.map((item) => Gallery.fromJson(item)).toList();
            print("subGalleryList:$subGalleryList");

            for (int i = 0; i < subGalleryList!.length; i++) {
              catTitle = '_$i';

              print("catTitle:$catTitle");
            }
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

        return subGalleryList;
      } else {
        throw Exception('Failed to load Sub Media Gallery');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  Future<bool> _onWillPop() async {
    print("back called");
    ApiData.gridclickcount = 1;
    if(ApiData.iscomingfromhome==1) {
      ApiData.iscomingfromhome = 0;
      Navigator.push(
          context,
          MaterialPageRoute(
              fullscreenDialog: true, builder: (context) => HomeDashboard()));
    }else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AllMediaGallery()));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
              // you can forcefully translate values left side using Transform
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
                  // Image.asset(
                  //   'assets/images/menuicon.png',
                  // ),
                  onPressed: () {
                    ApiData.gridclickcount = 1;
                    if(ApiData.iscomingfromhome==1) {
                      ApiData.iscomingfromhome = 0;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              fullscreenDialog: true, builder: (context) => HomeDashboard()));
                    }else {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => AllMediaGallery()));
                    }
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
                          const EdgeInsets.only(left: 15, right: 15, top: 4),
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
                                  text: "Media Gallery",
                                  style: const TextStyle(
                                      color: Color(0xff111111),
                                      fontSize: 13,
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
                                  text: widget.title,
                                  style: const TextStyle(
                                      color: Color(0xff111111),
                                      fontSize: 11.8,
                                      height: 1.2,
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
                    margin: EdgeInsets.only(left: 15,right: 4),
                    child: Text(
                      widget.title,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontFamily: 'GraphikMedium',
                        fontSize: 13.5,
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
                            itemCount: subGalleryList!.length,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(15),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 1,
                              mainAxisSpacing: 18,
                              childAspectRatio: 2,
                              mainAxisExtent: 160,
                              crossAxisCount: 2,
                            ),
                            itemBuilder: (BuildContext context, int index) {

                              var imagetitileindex=index+1;
                              return GestureDetector(
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Container(

                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  child: Hero(
                                                    tag: subGalleryList![index],
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          subGalleryList![index]
                                                              .thumbnailImage
                                                              .toString(),
                                                      memCacheHeight: 150,
                                                      memCacheWidth: 200,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit
                                                                .fitHeight,
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              SizedBox(
                                                        child: Image.asset(
                                                          'assets/images/no_image.png',
                                                          fit: BoxFit.fitHeight,
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    ApiData.gridclickcount = 0;
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                      return FullScreenImage(

                                          imageUrl: subGalleryList![index]
                                              .thumbnailImage
                                              .toString(),
                                          catTitle: subGalleryList![index]
                                              .catTitle!+"_"+ imagetitileindex.toString(),
                                          imageTitle: subGalleryList![index]
                                              .imageTitle
                                              .toString(),
                                          imageid: widget.id,
                                          title: widget.title);
                                    }));
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
