import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';

import 'package:ppac/Widgets/gstgoodwebviewcontent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

import '../Response/CentralResponse.dart';

import 'package:http/http.dart' as http;

class GstGoods extends StatefulWidget {
  String menuname;
  String submenuname;

  GstGoods({required this.menuname, required this.submenuname});

  @override
  _GstGoodsState createState() => _GstGoodsState();
}

class _GstGoodsState extends State<GstGoods> {
  late String nongstgoodsSlug;
  late String gstgoodsSlug;
  String? htmlContent = "";
  String pagecontentId = " ";

  String? pagetitle;
  String? menuname;
  String? submenuname;

  String? selectedGoods;
  bool ishtmlload = false;
  List<String> yearList = [];
  List<String> viewDataIn = [];

  List<String> goodsitem = [];
  List<CentralTab> centraltabList = [];
  List<String> strtab = [];
  String viewhistoryfile = '';
  int selected = 0;
  int selectedIndex = -1;

  bool isLoading = true;
  final _key = UniqueKey();

  Future setStr(ishtml) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString("ishtml", ishtml);
  }

  Future<CentralResponse> fetchCentralData() async {
    try {
      Map data = {
        'slug': Selectedslugname.slugname,
        'method': 'getImportExportcontent',
      };
      //encode Map to JSON
      print('param:$data');
      final prefs = await SharedPreferences.getInstance();
      menuname = prefs.getString("SharedmenuName");
      ApiData.menuName = menuname.toString();
      // print("prefmenuname:${menuname}");
      var body = utf8.encode(json.encode(data));
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
        final centralData = centralResponseFromJson(response.body);

        if (centralData.htmlcontent == "True") {
          print("htmlcontent is true");
          htmlContent = "true";
          ishtmlload = false;
          setStr(htmlContent);
        } else {
          print("htmlcontent is false");
          htmlContent = "false";
          ishtmlload = false;
          setStr(htmlContent);
        }
        TABULARPAGECONTENT.pagetitle =
            centralData.pageContents.pageTitle.toString();
        print("pagetitle:${TABULARPAGECONTENT.pagetitle}");

        TABULARPAGECONTENT.historyfilename =
            centralData.pageContents.historyUpload.toString();
        print("historyfilename:${TABULARPAGECONTENT.historyfilename}");

        TABULARPAGECONTENT.pagecontent =
            centralData.pageContents.pageContents!.replaceAll("\t\r", "");
        print("pagecontent:${TABULARPAGECONTENT.pagecontent}");

        TABULARPAGECONTENT.department =
            centralData.pageContents.department.toString();
        print("Page ID:$centralData.pageContents.id");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'pagecontentid', centralData.pageContents.id.toString());

        pagecontentId = centralData.pageContents.id.toString();
        print("pagecontentid$pagecontentId");

        TABULARPAGECONTENT.tabs = centralData.tabs.toString();
        print('tabscontent:${TABULARPAGECONTENT.tabs}');

        setState(() {
          if (centralData.tabs.isNotEmpty) {
            goodsitem = centralData.tabs;
          }
          if (centralData.tab.isNotEmpty) {
            centraltabList = centralData.tab;
          }

          if (centralData.strtab.isNotEmpty) {
            strtab = centralData.strtab;
          }

          print("goodsitem:$goodsitem");
          print("tabList:$centraltabList");

          isLoading = false;
        });
        return centralData;
      } else {
        throw Exception('Failed to load');
      }
    } on SocketException catch (e) {
      throw Exception('Failed to load $e');
    }
  }

  @override
  void initState() {
    super.initState();

    try {
      isLoading = true;

      fetchCentralData();
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
      Scaffold(
          backgroundColor: Colors.white.withOpacity(0.2),
          body: SingleChildScrollView(
            physics: Platform.isAndroid
                ? ScrollPhysics()
                : BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                    height: 500,
                    child: GridView.builder(
                      physics: Platform.isAndroid
                          ? ScrollPhysics()
                          : BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                      shrinkWrap: true,
                      itemCount: goodsitem.length,
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
                          child: gstGridCell(goodsitem[index], index),
                          onTap: () => gridClicked(index, goodsitem[index]),
                        );
                      },
                    ))
              ],
            ),
          ))
    ]);
  }

  gridClicked(int index, String goodsitem) {
    print("index click:+$index");

    Selectedslugname.slugname = strtab[index];

    if (Selectedslugname.slugname ==
        "prices/central-excise-and-customs-rate-on-major-petroleum-products") {
      menuname = "Prices";
      pagetitle = "Central Excise and Customs Rate on Major Petroleum Products";
      submenuname =
          "Central Excise and Customs Rate on Major Petroleum Products for Non-GST Goods";
    } else if (Selectedslugname.slugname ==
        "prices/central-excise-and-customs-rate-on-major-petroleum-products-for-gst-goods") {
      pagetitle = "Central Excise and Customs Rate on Major Petroleum Products";
      menuname = "Prices";
      submenuname =
          "Central Excise and Customs Rate on Major Petroleum Products for GST Goods";
    } else if (Selectedslugname.slugname ==
        "prices/excise-duty-on-export-of-petrol-diesel-atf-and-special-additional-excise-duty-saed-on-domestic-crude-oil-production") {
      pagetitle = "Excise duty on Export of Petrol, Diesel & ATF";
      menuname = "Prices";
      submenuname =
          "Excise duty on Export of Petrol, Diesel & ATF and Special Additional Excise Duty(SAED) on Domestic Crude Oil Production";
    } else if (Selectedslugname.slugname ==
        "prices/contribution-to-central-and-state-exchequer") {
      menuname = "Prices";
      pagetitle = "Contribution to Central and State Exchequer";
      submenuname = "Contribution of Petroleum Sector to Exchequer";
    } else if (Selectedslugname.slugname ==
        "prices/state-wise-collection-of-sales-tax-vat-on-pol-products") {
      menuname = "Prices";
      pagetitle = "Contribution to Central and State Exchequer";
      submenuname = "State wise collection of Sales Tax VAT on POL products";
    } else if (Selectedslugname.slugname ==
        "prices/state-wise-collection-of-sgst-utgst") {
      menuname = "Prices";
      pagetitle = "Contribution to Central and State Exchequer";
      submenuname = "State wise collection of SGST UTGST";
    } else if (Selectedslugname.slugname ==
        "prices/dealers-distributors-commission-on-petrol-diesel-pds-kerosene-domestic-lpg") {
      menuname = "Prices";
      pagetitle =
          "Dealers/Distributors Commission on Petrol, Diesel, PDS Kerosene & Domestic LPG";
      submenuname =
          "Dealers/Distributors Commission on Petrol, Diesel, PDS Kerosene & Domestic LPG";
    } else if (Selectedslugname.slugname ==
        "dealers-distributors-commission-on-petrol-diesel-pds-kerosene-domestic-lpg/dealers-commission-on-petrol-and-diesel") {
      menuname =
          "Dealers/Distributors Commission on Petrol, Diesel, PDS Kerosene & Domestic LPG";
      pagetitle =
          "Dealers/Distributors Commission on Petrol, Diesel, PDS Kerosene & Domestic LPG";
      submenuname = "Dealers Commission on Petrol and Diesel";
    } else if (Selectedslugname.slugname ==
        "dealers-distributors-commission-on-petrol-diesel-pds-kerosene-domestic-lpg/dealers-distributors-commission-on-pds-kerosene-and-dom-lpg") {
      menuname =
          "Dealers/Distributors Commission on Petrol, Diesel, PDS Kerosene & Domestic LPG";
      pagetitle =
          "Dealers/Distributors Commission on Petrol, Diesel, PDS Kerosene & Domestic LPG";
      submenuname =
          "Dealers/Distributors Commission on PDS Kerosene and DOM LPG";
    } else {
      menuname = widget.menuname;
      submenuname = widget.submenuname;
      pagetitle = widget.submenuname;
    }

    Platform.isIOS
        ? Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => GstGoodWebViewContent(
                  menuname: menuname.toString(),
                  submenuname: submenuname.toString(),
                  pagetitle: pagetitle.toString(),
                  slugname: Selectedslugname.slugname,
                )))
        : Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => GstGoodWebViewContent(
                  menuname: menuname.toString(),
                  submenuname: submenuname.toString(),
                  pagetitle: pagetitle.toString(),
                  slugname: Selectedslugname.slugname,
                )));
  }
}

class gstGridCell extends StatelessWidget {
  const gstGridCell(this.mainMenuModel, this.index, {Key? key})
      : super(key: key);

  @required
  final String mainMenuModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      alignment: Alignment.center,
      width: 158,
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: const Color(0xffF3F3F3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xffB4B4B4),
            blurRadius: 5.0,
          ),
        ],
        color: const Color(0xff085196),
      ),
      child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/crude_processing.svg",
                width: 42,
                height: 42,
                color: Color(0xffffffff),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                  child: Text(
                mainMenuModel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color(0xffffffff),
                    fontFamily: 'GraphikMedium'),
              )),
            ],
          )),
    ));
  }
}
