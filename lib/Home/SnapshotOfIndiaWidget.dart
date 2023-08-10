import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../Model/HomeDashboardReportModel.dart';
import '../constant.dart';

class SnapshotOfIndiaWidget extends StatefulWidget {
  SnapshotOfIndiaWidget({super.key, required this.reportDataArr});
  List<Report> reportDataArr;

  @override
  State<SnapshotOfIndiaWidget> createState() => _SnapshotOfIndiaWidgetState();
}
class _SnapshotOfIndiaWidgetState extends State<SnapshotOfIndiaWidget> {
  final themeBlueColor = Color(0xff085196);

  List<Widget> widgetreportDataArr=[];

  late PageController pageController;
  @override
  void initState() {

    pageController = PageController(viewportFraction: 0.8);

    print("reportlen"+widget.reportDataArr.length.toString());
    for (int i = 0; i < widget.reportDataArr.length; i++) {
      widgetreportDataArr.add(ReportWidget(widget.reportDataArr[i]));
    }

  }
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return
      Column(
      children: [
        Expanded(child:
        Container(
          height: 300,
          width: double.infinity,
          child: PageView(
            children: widgetreportDataArr,
            controller: pageController,

            onPageChanged: (index){
      setState(() {
        _current = index;
      });
            },
          ),
        )),
        SizedBox(height: 10),
        CarouselIndicator(
          count: widgetreportDataArr.length,
          index: _current,
          activeColor: const Color(0xff085196),
          color: const Color(0xffD4D4D4),

        ),
      ],
    );
  }


 // int _current = 0;
  Widget ReportWidget(Report data) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: [
      Expanded(child:
          Container(
            height: 295,
            margin: EdgeInsets.only(right: 10),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(5),
                color: themeBlueColor.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Flexible(
                      child: Text(
                        data.title ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: 'GraphikMedium'),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Image.network(
                        data.image ?? "",
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                        onPressed: () {

                          ApiConstant.launchURL(data.viewReport ?? "");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeBlueColor,

                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0)),
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          minimumSize: const Size(151.92, 33),
                        ),
                        child: const Text(
                          'View Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Graphik',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
