import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:ppac/Gallery/SubMediaGallery.dart';
import 'package:ppac/Response/GalleryByIdResponse.dart';
import 'package:ppac/constant.dart';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;
  final String imageTitle;
  final String catTitle;
  final String title;
  final String imageid;

  const FullScreenImage(
      {required this.imageUrl,
      required this.imageTitle,
      required this.catTitle,
      required this.title,
      required this.imageid});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  Future<bool> _onWillPop() async {
    print("back called");
    ApiData.gridclickcount = 1;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            SubMediaGallery(title: widget.title, id: widget.imageid)));

    return true;
  }

  int? imageCount;
  String catTitle = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Platform.isAndroid ? _onWillPop : null,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: GestureDetector(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Platform.isAndroid
                          ? Container(
                              margin: EdgeInsets.only(right: 30),
                              child: InkWell(
                                onTap: () async {
                                  Map<Permission, PermissionStatus> statuses =
                                      await [
                                    Permission.manageExternalStorage,
                                  ].request();

                                  if (statuses[
                                          Permission.manageExternalStorage]!
                                      .isGranted) {
                                    var dir = await DownloadsPathProvider
                                        .downloadsDirectory;
                                    if (dir != null) {
                                      File file = File(widget.imageUrl);

                                      print("File Name:${file.getFileName()}");
                                      String savename = file.getFileName();
                                      String savePath = "${dir.path}/$savename";
                                      print(savePath);
                                      //output:  /storage/emulated/0/Download/banner.png

                                      try {
                                        await Dio()
                                            .download(widget.imageUrl, savePath,
                                                onReceiveProgress:
                                                    (received, total) {
                                          if (total != -1) {
                                            print((received / total * 100)
                                                    .toStringAsFixed(0) +
                                                "%");
                                          }
                                        });
                                        print(
                                            "Image is saved to download folder.");
                                      } on DioError catch (e) {
                                        print(e.message);
                                      }
                                      Fluttertoast.showToast(
                                          msg:
                                              "Image is saved to download folder.",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Color(0xff085196),
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                  } else {
                                    print("No permission to read and write.");
                                  }
                                },
                                // Image tapped
                                splashColor: Colors.white10,
                                // Splash color over image
                                child: SvgPicture.asset(
                                    "assets/images/download-solid.svg",
                                    width: 22,
                                    height: 22,
                                    color: Colors.white),
                              ),
                            )
                          : Container(),
                      Container(
                        margin: Platform.isAndroid
                            ? EdgeInsets.only(right: 30)
                            : EdgeInsets.only(right: 10),
                        child: Platform.isAndroid
                            ? InkWell(
                                onTap: () async {
                                  ApiData.gridclickcount = 0;
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => SubMediaGallery(
                                          title: widget.title,
                                          id: widget.imageid)));
                                },
                                // Image tapped
                                splashColor: Colors.white10,
                                // Splash color over image
                                child: SvgPicture.asset(
                                    "assets/images/xmark-solid.svg",
                                    width: 22,
                                    height: 22,
                                    color: Colors.white),
                              )
                            : IconButton(
                                icon: Icon(Icons.close,
                                    size: 22, color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      // border: Border.all(width: 1, color: const Color(0xffF3F3F3)),
                    ),
                    child: FittedBox(
                      child: Platform.isAndroid
                          ? InteractiveViewer(
                              panEnabled: true,
                              boundaryMargin: EdgeInsets.all(50),
                              minScale: 1,
                              maxScale: 2.5,
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: widget.imageUrl.toString(),
                              ),
                            )
                          : SizedBox(
                              height: 350,
                              width: MediaQuery.of(context).size.width,
                              child: InteractiveViewer(
                                panEnabled: true,
                                // Set it to false

                                boundaryMargin: EdgeInsets.all(50),

                                minScale: 1,

                                maxScale: 2.5,

                                child: Hero(
                                  tag: widget.imageUrl.toString(),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.imageUrl.toString(),
                                    memCacheHeight: 150,
                                    memCacheWidth: 200,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      // height: 100,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => SizedBox(
                                      child: Image.asset(
                                        'assets/images/no_image.png',
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                widget.imageTitle == ''
                    ? Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        child: Text(
                          widget.catTitle,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xffffffff),
                              fontFamily: 'GraphikMedium'),
                        ))
                    : Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(10),
                        child: Text(
                          widget.imageTitle,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xffffffff),
                              fontFamily: 'GraphikMedium'),
                        ),
                      )
              ],
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
