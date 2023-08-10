import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';

import 'package:ppac/Screens/DocumentViewPageNew.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../Home/gridcells.dart';
import '../Model/MainMenuModel.dart';


class AboutPPAC extends StatefulWidget {
  String menuname;

  AboutPPAC({required this.menuname});

  @override
  State<AboutPPAC> createState() => _AboutPPACState();
}

class _AboutPPACState extends State<AboutPPAC> {
  List<Menu> menu = [];
  bool isdataconnection = true;
  bool loading = true;
  var Internetstatus = "Unknown";
  String? menuname;
  StreamSubscription? connection;

  Future<List<Menu>> fetchMainMenuData(String url) async {
    try {
      Map data = {
        'parent_id': '229',
        'menugrp_id': '1',
        'method': 'getAllMenus',
      };

      final prefs = await SharedPreferences.getInstance();
      menuname = prefs.getString("SharedmenuName");
      ApiData.menuName = menuname.toString();
      print("prefmenuname:${menuname}");
      //encode Map to JSON
      var body = utf8.encode(json.encode(data));

      var response = await http
          .post(Uri.parse(url),
              headers: {"Content-Type": "application/json", "Authorization": "Bearer ${ApiData.token}"}, body: body)
          .timeout(const Duration(seconds: 500));

      print("response:${response.statusCode}");

      if (response.statusCode == 200) {

        try {
          Map decoded = json.decode(response.body);

          if (decoded.length > 0) {

            print("decoded:$decoded");

            menu = [];

            for (var objMenuTitle in decoded["Menu"]) {
              var menuTitle = objMenuTitle['name'];
              print("File Title:$menuTitle");

              menu.add(Menu(
                nId: objMenuTitle['n_id'],
                parentId: objMenuTitle['parent_id'],
                name: objMenuTitle['name'],
                slug: objMenuTitle['slug'],
                targetBlank: objMenuTitle['target_blank'],
                position: objMenuTitle['position'],
                language: objMenuTitle['language'],
                status: objMenuTitle['status'],
                createdAt: objMenuTitle['created_at'],
                createdBy: objMenuTitle['created_by'],
                updatedAt: objMenuTitle['updated_at'],
                updatedBy: objMenuTitle['updated_by'],
                relId: objMenuTitle['rel_id'],
                menuId: objMenuTitle['menu_id'],
                groupId: objMenuTitle['group_id'],
              ));

            }

            setState(() {
              isdataconnection = true;
              loading = false;
            });
          } else {
            setState(() {
              isdataconnection = true;
              loading = false;

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Something went wrong.Please try again!!',
                  style:
                  TextStyle(color: Colors.white, fontFamily: 'GraphikRegular',fontSize: 15),
                ),
                backgroundColor:Color(0xff085196),
              ));
            });
          }
        } on Exception catch (e) {
          print("unable to load data");
          setState(() {
            isdataconnection = true;
            loading = false;

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Something went wrong.Please try again!!',
                style:
                TextStyle(color: Colors.white, fontFamily: 'GraphikRegular',fontSize: 15),
              ),
              backgroundColor: Color(0xff085196),
            ));
          });
        }

        return menu;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isdataconnection = hasConnection;
      if (isdataconnection) {
        Internetstatus = "Connected TO The Internet";

        isdataconnection = true;


        print('Data connection is available.');

      } else if (!isdataconnection) {
        Internetstatus = "No Data Connection";
        isdataconnection = false;
        print('You are disconnected from the internet.');

        loading = false;

      }
    });
  }

  @override
  void initState() {
    fetchMainMenuData(ApiConstant.url);
    super.initState();
  }

  @override
  void dispose() {

    connection?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));

    return isdataconnection
        ? loading
            ? Scaffold(
                body: Center(
                    child: CircularProgressIndicator(
                color: Color(0xff085196),
              )))
            : Stack(children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/splash_background.jpg',
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Scaffold(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  appBar: AppBar(
                    toolbarHeight: 99,
                    centerTitle: true,
                    titleSpacing: 0.0,
                    elevation: 1,
                    title: Transform(
                      // you can forcefully translate values left side using Transform
                      transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                      child:

                      Text(
                        ApiData.menuName,
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
                            ApiData.gridclickcount = 0;
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ),
                  body: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [

                          const SizedBox(
                            height: 20,
                          ),
                          LayoutBuilder(builder: (context, constraints) {
                            return GridView.builder(
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: menu.length,
                              scrollDirection: Axis.vertical,
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 1,
                                mainAxisSpacing: 18,
                                childAspectRatio: 2,
                                mainAxisExtent: 120,
                                crossAxisCount: 2,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  child: GridCell(menu[index], index),
                                  onTap: () => gridClicked(index, menu[index]),
                                );
                              },
                            );
                          })
                        ],
                      ),
                    ),
                  ),
                )
              ])
        : Container(
            margin:
                const EdgeInsets.only(left: 30, top: 30, right: 30, bottom: 50),
            height: 150,
            width: 300,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xffD0D3D4),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.signal_wifi_statusbar_connected_no_internet_4,
                  size: 70,
                  color: Color(0xffAB0E1E),
                ),
                SizedBox(
                  height: 10,
                ),
                DefaultTextStyle(
                  style: TextStyle(decoration: TextDecoration.none),
                  child: Text(
                    'No Internet Connection Found! ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'GraphikMedium',
                      color: Color(0xffAB0E1E),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                DefaultTextStyle(
                  style: TextStyle(decoration: TextDecoration.none),
                  child: Text(
                    'Please enable your internet ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'GraphikThin',
                      color: Color(0xff243444),
                    ),
                  ),
                ),
              ],
            ));
  }

  gridClicked(int index, Menu data) async {
    print('gridClicked : $index, ${data.menuId}');
    setState(() {
      ApiData.menuName = menuname.toString();
      ApiData.subMenuID = data.menuId;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("SharedmenuName");
    ApiData.submenuName = data.name;
    prefs.setString('SharedmenuName', ApiData.menuName);
    print("stored_menuname:${ApiData.menuName}");

    Selectedslugname.slugname = data.slug;

    Platform.isIOS?
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentViewPageNew(
          menuname: ApiData.menuName,
          submenuname: ApiData.submenuName,
        ),
      ),
    ):
    Navigator.push(
      context,
      PageTransition(

          type: PageTransitionType.rightToLeft,
          child:  DocumentViewPageNew(
            menuname: ApiData.menuName,
            submenuname: ApiData.submenuName,
          ),
          inheritTheme: true,
          ctx: context),
    );

  }
}
