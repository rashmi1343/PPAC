

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ChildWidget extends StatelessWidget {
  final String fileName;
  final String lastModified;
  final String imgurl;
  final String dept;
  final String introcontent;

  ChildWidget(
      {required this.fileName,
      required this.lastModified,
      required this.imgurl,
      required this.dept,
      required this.introcontent});

  void _showcontent(
      BuildContext context, String datacontent, String designation) {
    showDialog(
      context: context, barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Introduction to ' + designation,
            style: TextStyle(
                color: const Color(0xff000000),
                fontFamily: 'GraphikMedium',
                fontSize: 14),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Image(image:NetworkImage
                  (imgurl),
                  width: 180.0,
                  height: 250.0,
                  fit: BoxFit.cover,
                ),
                dept=="Gas"?
                Html(data:datacontent) :
                Container(
                  margin: EdgeInsets.only(left:0,top:10,right:0,bottom:0),
                  child:
                  Text(
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
        margin: EdgeInsets.only(left:0,top:0,right:15,bottom:0),
            child:
            ElevatedButton(
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
        )],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget fileNameWidget = Text(
      this.fileName,
      style: TextStyle(
          color: const Color(0xff000000),
          fontFamily: 'GraphikMedium',
          fontSize: 16),
    );


    Widget lastModifiedWidget = Text(
      lastModified + " - " + dept,
      style: TextStyle(
          color: const Color(0xff085196),
          fontFamily: 'GraphikMedium',
          fontSize: 14),
    );


    return Card(
      elevation: 0.0,
      child: ListTile(
        leading: Container(margin:EdgeInsets.all(1.5),child:Image.network(imgurl)),
        title: fileNameWidget,
        subtitle: lastModifiedWidget,
        onTap: (() => _showcontent(context, this.introcontent, lastModified)),
      ),
    );
  }
}
