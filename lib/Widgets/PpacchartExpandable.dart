import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ppac/ConnectionUtil.dart';
import 'package:ppac/Model/orgchartmodel.dart';
import 'package:http/http.dart' as http;
import 'package:ppac/constant.dart';

class PpacchartExpandable extends StatefulWidget {
  const PpacchartExpandable({Key? key}) : super(key: key);

  @override
  _PpacchartExpandablewidgetState createState() =>
      _PpacchartExpandablewidgetState();
}

class _PpacchartExpandablewidgetState extends State<PpacchartExpandable> {
  StreamSubscription? connection;
  bool isdataconnection = false;
  var Internetstatus = "Unknown";
  bool isLoading = true;
  int selected = -1;
  List<objmember> orgchartlist = [];
  List<objmember> orgchartlistchildone = [];

  List<objmember> orgchartlistchildtwo = [];

  @override
  void initState() {
    super.initState();
    ConnectionUtil connectionStatus = ConnectionUtil.getInstance();
    connectionStatus.initialize();
    connection = connectionStatus.connectionChange.listen(connectionChanged);
  }

  Future<List<objmember>> getorgchartfromapi(String url) async {
    try {
      Map data = {'method': 'getOrgChart'};
      var body = utf8.encode(json.encode(data));

      var response = await http
          .post(Uri.parse(url),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${Prefs.getString("token").toString()}"
              },
              body: body)
          .timeout(const Duration(seconds: 500));

      print("response:${response.statusCode}");

      if (response.statusCode == 200) {

        Map arrorglistdecoded = json.decode(response.body);
        print("decoded:$arrorglistdecoded");

        orgchartlist = [];
        for (var objorgchart in arrorglistdecoded["OrgChart"]) {
          print("name:" + objorgchart["name"]);

          print("Seconditeration:" + objorgchart["children"].toString());

          orgchartlistchildone = [];

          for (var objorgchartone in objorgchart["children"]) {
            orgchartlistchildtwo = [];
            for (var objcharttwo in objorgchartone["children"]) {
              orgchartlistchildtwo.add(objmember(
                  department: objcharttwo["department"],
                  membername: objcharttwo["name"],
                  designation: objcharttwo["designation"],
                  introductioncontent: objcharttwo["introduction"] +
                      "\n\n" +
                      objcharttwo["descriptions"],
                  imgurl: objcharttwo["image"],
                  isexpand: false,
                  childData: []));

            }
            if (orgchartlistchildtwo.length > 0) {
              orgchartlistchildone.add(objmember(
                  department: objorgchartone["department"],
                  membername: objorgchartone["name"],
                  designation: objorgchartone["designation"],
                  introductioncontent: objorgchartone["introduction"] +
                      "\n\n" +
                      objorgchartone["descriptions"],
                  imgurl: objorgchartone["image"],
                  isexpand: true,
                  childData: orgchartlistchildtwo));
            } else {
              orgchartlistchildone.add(objmember(
                  department: objorgchartone["department"],
                  membername: objorgchartone["name"],
                  designation: objorgchartone["designation"],
                  introductioncontent: objorgchartone["introduction"] +
                      "\n\n" +
                      objorgchartone["descriptions"],
                  imgurl: objorgchartone["image"],
                  isexpand: false,
                  childData: []));
            }
          }
          orgchartlist.add(objmember(
              department: objorgchart["department"],
              membername: objorgchart["name"],
              designation: objorgchart["designation"],
              introductioncontent: objorgchart["introduction"] +
                  "\n\n" +
                  objorgchart["descriptions"],
              imgurl: objorgchart["image"],
              isexpand: true,
              childData: orgchartlistchildone));
        }

        print("orgchartthree len" + orgchartlistchildtwo.length.toString());
        print("orgchartttwo len" + orgchartlistchildone.length.toString());
        print("orgchart len" + orgchartlist.length.toString());

        setState(() {
          isdataconnection = true;
          isLoading = false;
        });
        return orgchartlist;
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
        Internetstatus = "Connected To The Internet";
        isdataconnection = true;
        print('Data connection is available.');
        setState(() {
          getorgchartfromapi(ApiConstant.url);
          isLoading = true;
        });
      } else if (!isdataconnection) {
        Internetstatus = "No Data Connection";
        isdataconnection = false;
        print('You are disconnected from the internet.');
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    connection?.cancel();
    super.dispose();
  }

  void _showcontent(BuildContext context, String datacontent, String department,
      String imgurl) {
    showDialog(
      context: context, barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Introduction to ' + department,
            style: TextStyle(
                color: const Color(0xff000000),
                fontFamily: 'GraphikMedium',
                fontSize: 14),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Image(
                  image: NetworkImage(imgurl),
                  width: 180.0,
                  height: 250.0,
                  fit: BoxFit.cover,
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 0),
                  child: Text(
                    datacontent,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        color: const Color(0xff000000),
                        fontFamily: 'GraphikRegular',
                        height: 1.2,
                        fontSize: 14),
                  ),
                )
              ],
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(left: 0, top: 0, right: 15, bottom: 0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Color(0xff085196),
                  ),
                ),
                child: Text('Ok',
                    style: TextStyle(
                        color: const Color(0xffffffff),
                        fontFamily: 'GraphikMedium',
                        fontSize: 14)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return isdataconnection
        ? Scaffold(
            backgroundColor: Colors.transparent,

            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    height: Platform.isIOS ? 450 : 500,
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) =>
                          ExpansionTile(
                        key: Key('builder ${selected.toString()}'),

                        initiallyExpanded: index == selected,
                        onExpansionChanged: (bool isExpanded) {
                          if (isExpanded) {
                            setState(() {
                              Duration(seconds: 20000);
                              selected = index;
                            });
                          } else {
                            setState(() {
                              selected = -1;
                            });
                            print("nt expanded");
                          }

                        },


                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            SizedBox(
                              height: 35,
                              width: 35,

                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/no_image.png',
                                image: orgchartlist[index].imgurl.isNotEmpty
                                    ? orgchartlist[index].imgurl
                                    : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThyEKIq_a7eWEwVEoo1aTBQ6gV1KQ4BI8ojEQgnl0ITQ&s",
                                height: 32,
                                width: 32,
                              ),
                              // ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Flexible(
                                child:
                                    Card(
                              child: ListTile(
                                  // leading: Container(margin:EdgeInsets.all(1.5),child:Image.network(widget.imgurl)),
                                  title: Text(
                                    orgchartlist[index].membername,
                                    style: TextStyle(
                                        color: const Color(0xff000000),
                                        fontFamily: 'GraphikMedium',
                                        fontSize: 16),
                                  ),
                                  subtitle: orgchartlist[index]
                                              .department
                                              .length >
                                          0
                                      ? Text(
                                          orgchartlist[index].designation +
                                              " - " +
                                              orgchartlist[index].department,
                                          style: TextStyle(
                                              color: const Color(0xff085196),
                                              fontFamily: 'GraphikMedium',
                                              fontSize: 14),
                                        )
                                      : Text(
                                          orgchartlist[index].designation,
                                          style: TextStyle(
                                              color: const Color(0xff085196),
                                              fontFamily: 'GraphikMedium',
                                              fontSize: 14),
                                        ),

                                  onTap: (() =>

                                      _showcontent(
                                          context,
                                          orgchartlist[index]
                                              .introductioncontent,
                                          orgchartlist[index].designation,
                                          orgchartlist[index].imgurl))),
                            )),
                          ],
                        ),
                        children: orgchartlist[index]
                            .childData
                            .map<Widget>((club) => CategoriesExpandableWidget(
                                currentmenuitem: club,
                                submenuitem: orgchartlist[index].childData,
                                title: orgchartlist[index].membername,
                                subtitle: orgchartlist[index].designation))
                            .toList(),
                      ),
                      itemCount: orgchartlist.length,
                      separatorBuilder: (context, index) {
                        return Divider(

                          height: 0,
                        );
                      },
                    ),
                  ),
          )
        : Container(
            color: Colors.white,
            child: Center(
                child: Container(
                    margin: EdgeInsets.only(
                        left: 30, top: 30, right: 30, bottom: 50),
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
                              fontFamily: 'HelveticaNueueMedium',
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
                              fontFamily: 'HelveticaNueueThin',
                              color: Color(0xff243444),
                            ),
                          ),
                        ),
                      ],
                    ))),
          );
  }
}

class CategoriesExpandableWidget extends StatefulWidget {
  final objmember currentmenuitem;

  List<objmember> submenuitem = [];


  String subtitle;
  String title;

  CategoriesExpandableWidget(
      {required this.currentmenuitem,
      required this.submenuitem,
      required this.title,
      required this.subtitle});

  @override
  _CategoriesExpandableWidgetState createState() =>
      _CategoriesExpandableWidgetState();
}

class _CategoriesExpandableWidgetState
    extends State<CategoriesExpandableWidget> {
  List<objmember> submenulist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    print("title" + widget.title);
    print("subtitle" + widget.subtitle);
    print("current menu name " + widget.currentmenuitem.membername);

    print("sub menu item " + widget.submenuitem.length.toString());


  }

  void _showcontent(BuildContext context, String datacontent, String department,
      String imgurl, objmember data) {
    showDialog(
      context: context, barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Introduction to ' + department,
            style: TextStyle(
                color: const Color(0xff000000),
                fontFamily: 'GraphikMedium',
                fontSize: 14),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Image(
                  image: NetworkImage(imgurl),
                  width: 180.0,
                  height: 250.0,
                  fit: BoxFit.cover,
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 0),
                  child: data.department == "Gas"
                      ? Html(data: datacontent)
                      : Text(
                          datacontent,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              color: const Color(0xff000000),
                              fontFamily: 'GraphikRegular',
                              height: 1.2,
                              fontSize: 14),
                        ),
                )
              ],
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(left: 0, top: 0, right: 15, bottom: 0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Color(0xff085196),
                  ),
                ),
                child: Text('Ok',
                    style: TextStyle(
                        color: const Color(0xffffffff),
                        fontFamily: 'GraphikMedium',
                        fontSize: 14)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        );
      },
    );
  }

  int selected = -1;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.currentmenuitem.childData.isEmpty) {
      return ListTile(

          leading: FadeInImage.assetNetwork(
            placeholder: 'assets/images/no_image.png',
            image: widget.currentmenuitem.imgurl.isNotEmpty
                ? widget.currentmenuitem.imgurl
                : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThyEKIq_a7eWEwVEoo1aTBQ6gV1KQ4BI8ojEQgnl0ITQ&s",
            height: 32,
            width: 32,
          ),
          title: Text(
            widget.currentmenuitem.membername,
            style: TextStyle(
                color: const Color(0xff000000),
                fontFamily: 'GraphikMedium',
                fontSize: 16),
          ),
          subtitle: Text(
            widget.currentmenuitem.designation +
                " - " +
                widget.currentmenuitem.department,
            style: TextStyle(
                color: const Color(0xff085196),
                fontFamily: 'GraphikMedium',
                fontSize: 14),
          ),
          onTap: () {
            _showcontent(
                context,
                widget.currentmenuitem.introductioncontent,
                widget.currentmenuitem.designation,
                widget.currentmenuitem.imgurl,
                widget.currentmenuitem);
          });
    } else {
      return ExpansionTile(
        key: Key('builder ${selected.toString()}'),

        initiallyExpanded: index == selected,
        onExpansionChanged: (bool isExpanded) {
          if (isExpanded) {
            setState(() {
              Duration(seconds: 20000);
              selected = index;
            });
          } else {
            setState(() {
              selected = -1;
            });
            print("nt expanded");
          }

        },


        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(
              height: 35,
              width: 35,

              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/no_image.png',
                image: widget.currentmenuitem.imgurl.isNotEmpty
                    ? widget.currentmenuitem.imgurl
                    : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThyEKIq_a7eWEwVEoo1aTBQ6gV1KQ4BI8ojEQgnl0ITQ&s",
                height: 32,
                width: 32,
              ),
              // ),
            ),
            const SizedBox(
              width: 15,
            ),
            Flexible(
                child:
                    Card(
              child: ListTile(
                  title: Text(
                    widget.currentmenuitem.membername,
                    style: TextStyle(
                        color: const Color(0xff000000),
                        fontFamily: 'GraphikMedium',
                        fontSize: 16),
                  ),
                  subtitle: widget.currentmenuitem.department.length > 0
                      ? Text(
                          widget.currentmenuitem.designation +
                              " - " +
                              widget.currentmenuitem.department,
                          style: TextStyle(
                              color: const Color(0xff085196),
                              fontFamily: 'GraphikMedium',
                              fontSize: 14),
                        )
                      : Text(
                          widget.currentmenuitem.designation,
                          style: TextStyle(
                              color: const Color(0xff085196),
                              fontFamily: 'GraphikMedium',
                              fontSize: 14),
                        ),

                  onTap: (() =>

                      _showcontent(
                          context,
                          widget.currentmenuitem.introductioncontent,
                          widget.currentmenuitem.designation,
                          widget.currentmenuitem.imgurl,
                          widget.currentmenuitem))),
            )),
          ],
        ),
        children: widget.currentmenuitem.childData
            .map<Widget>((club) => CategoriesExpandableWidget(
                currentmenuitem: club,
                submenuitem: widget.currentmenuitem.childData,
                title: widget.currentmenuitem.membername,
                subtitle: widget.currentmenuitem.designation))
            .toList(),
      );
    }
  }
}
