import 'package:flutter/material.dart';
import 'package:ppac/Model/orgchartmodel.dart';

class ParentWidget extends StatefulWidget {
  final String directoryName;
  final String lastModified;
  final VoidCallback? onPressedNext;
  final List<objmember> childData;
  final String imgurl;
  final String department;
  late bool isexpand;
  final String introductioncontent;

  ParentWidget(
      {required this.directoryName,
      required this.lastModified,
      this.onPressedNext,
      required this.childData,
      required this.imgurl,
      required this.department,
      required this.isexpand,
      required this.introductioncontent});

  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  void _showcontent(
      BuildContext context, String datacontent, String department) {
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
                Image(image:NetworkImage
                (widget.imgurl),
                  width: 180.0,
                  height: 250.0,
                  fit: BoxFit.cover,
                ),
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
            )],
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

  // bool isexpand = false;

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      widget.directoryName,
      style: TextStyle(
          color: const Color(0xff000000),
          fontFamily: 'GraphikMedium',
          fontSize: 16),
    );


    IconButton expandButton = IconButton(
        icon: widget.isexpand
            ? Icon(Icons.keyboard_arrow_down)
            : Icon(Icons.navigate_next),
        onPressed: () {
          print("test");

          setState(() {
            if (widget.isexpand) {
              widget.isexpand = false;
            } else {
              widget.isexpand = true;
            }
          });
        });


    Widget designation = widget.department.length > 0
        ? Text(
            widget.lastModified + " - " + widget.department,
            style: TextStyle(
                color: const Color(0xff085196),
                fontFamily: 'GraphikMedium',
                fontSize: 14),
          )
        : Text(
            widget.lastModified,
            style: TextStyle(
                color: const Color(0xff085196),
                fontFamily: 'GraphikMedium',
                fontSize: 14),
          );

    return Card(
      child: ListTile(
          leading: Container(margin:EdgeInsets.all(1.5),child:Image.network(widget.imgurl)),
          title: titleWidget,
          subtitle: designation,
          trailing: expandButton,
          onTap: (() =>
              // isexpand =true
              _showcontent(
                  context, widget.introductioncontent, widget.lastModified))),
    );
  }
}
