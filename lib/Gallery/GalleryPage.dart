import 'dart:io';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ppac/Gallery/SubMediaGallery.dart';
import 'package:ppac/Home/HomeDashboard.dart';

import '../constant.dart';




class GalleryPage extends StatelessWidget {
  final String imageUrl;
  final String imageTitle;

  const GalleryPage({required this.imageUrl, required this.imageTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                              File file = File(imageUrl);

                              print("File Name:${file.getFileName()}");
                              String savename = file.getFileName();
                              String savePath = "${dir.path}/$savename";
                              print(savePath);
                              //output:  /storage/emulated/0/Download/banner.png

                              try {
                                await Dio()
                                    .download(imageUrl, savePath,
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
                              builder: (context) => HomeDashboard()));
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
              SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    // border: Border.all(width: 1, color: const Color(0xffF3F3F3)),
                  ),
                  child: Container(
                    height: 300,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    imageTitle,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xffffffff),
                        fontFamily: 'GraphikMedium'),
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
