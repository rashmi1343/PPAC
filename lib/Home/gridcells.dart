import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Model/MainMenuModel.dart';

class GridCellSubmenu extends StatelessWidget {
  GridCellSubmenu(this.mainMenuModel, this.submenuname, {Key? key})
      : super(key: key);

  @required
  final Menu mainMenuModel;
  final String? submenuname;
  final themeBlueColor = Color(0xff085196);

  @override
  Widget build(BuildContext context) {
    return Center(child: _getcontainersubmenu(submenuname));
  }

  Widget _getcontainersubmenu(menuname) {
    if (menuname == "Prices") {
      return Container(
        alignment: Alignment.center,
        // height: 108,
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
          color: const Color(0xffffffff),
        ),
        child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/images/prices.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xff007A35),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff111111),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (menuname == "Subsidy") {
      return Container(
        alignment: Alignment.center,
        // height: 108,
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
          color: const Color(0xffffffff),
        ),
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/images/subsidy.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xff007A35),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff111111),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (menuname == "Location of Refineries") {
      return Container(
        alignment: Alignment.center,
        // height: 108,
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
          color: const Color(0xffffffff),
        ),
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/images/location-of-refienries.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xff007A35),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff111111),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (menuname == "Crude Processing") {
      return Container(
        alignment: Alignment.center,
        // height: 108,
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
          color: const Color(0xffffffff),
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
                  color: const Color(0xff007A35),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff111111),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (menuname == "Statewise Sales") {
      return Container(
        alignment: Alignment.center,
        // height: 108,
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
          color: const Color(0xffffffff),
        ),
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/images/statewise_sales.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xff007A35),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff111111),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        // height: 108,
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
          color: const Color(0xffffffff),
        ),
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/images/circle-info.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xff007A35),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff111111),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    }
  }
}

class GridCell extends StatelessWidget {
  GridCell(this.mainMenuModel, this.index, {Key? key}) : super(key: key);

  @required
  final Menu mainMenuModel;
  final int index;
  final themeBlueColor = Color(0xff085196);

  @override
  Widget build(BuildContext context) {
    return Center(child: _getcontainer(index));
  }

  Widget _getcontainer(position) {
    if (position == 0 && mainMenuModel.name == "Home") {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/house-blank.svg",
                  width: 42,
                  height: 42,
                  //   color: const Color(0xff007A35),
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 1) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/prices.svg",
                  width: 42,
                  height: 42,
                  // color: const Color(0xff007A35),
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 2) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/file-chart-column.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 3) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/production.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 4) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/consumpation.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 5) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/natural-gas.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 6) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/petroleum.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 7) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/gavel-light.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        // padding: const EdgeInsets.only(
        //     left: 10, top: 10, right: 10),
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
                  "assets/images/circle-info.svg",
                  width: 42,
                  height: 42,
                  color: const Color(0xffffffff),
                ),
                const SizedBox(
                  height: 10,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xffffffff),
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    }
  }
}

class HomeGridCell extends StatelessWidget {
  HomeGridCell(this.mainMenuModel, this.index, {Key? key}) : super(key: key);

  @required
  final Menu mainMenuModel;
  final int index;
  final themeBlueColor = Color(0xff085196);

  @override
  Widget build(BuildContext context) {
    return Center(child: _getcontainer(index));
  }

  circleIcon(String icon) {
    return CircleAvatar(
      backgroundColor: themeBlueColor.withOpacity(0.2),
      radius: 25,
      child: SvgPicture.asset(
        icon, //"assets/images/prices.svg",
        width: 20,
        height: 20,
        // color: const Color(0xff007A35),
        color: themeBlueColor, //const Color(0xffffffff),
      ),
    );
  }

  Widget _getcontainer(position) {
    if (position == 0 && mainMenuModel.name == "Home") {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/house-blank.svg",
                width: 22,
                height: 22,
                // color: const Color(0xff007A35),
                color: themeBlueColor,
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                  child: Text(
                mainMenuModel.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: themeBlueColor,
                    fontFamily: 'GraphikMedium'),
              )),
            ],
          ),
        ),
      );
    } else if (position == 1) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              circleIcon("assets/images/prices.svg"),
              const SizedBox(
                height: 5,
              ),
              Flexible(
                  child: Text(
                mainMenuModel.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: themeBlueColor,
                    //Color(0xffffffff),
                    fontFamily: 'GraphikMedium'),
              )),
            ],
          ),
        ),
      );
    } else if (position == 2) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                circleIcon("assets/images/export.svg"),
                const SizedBox(
                  height: 5,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: themeBlueColor,
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 3) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                circleIcon("assets/images/production.svg"),
                const SizedBox(
                  height: 5,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: themeBlueColor,
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 4) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                circleIcon("assets/images/consumpation.svg"),
                const SizedBox(
                  height: 5,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: themeBlueColor,
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 5) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
            padding: const EdgeInsets.all(1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                circleIcon("assets/images/natural-gas.svg"),
                const SizedBox(
                  height: 5,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: themeBlueColor,
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 6) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                circleIcon("assets/images/petroleum.svg"),
                const SizedBox(
                  height: 5,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: themeBlueColor,
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 7) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                circleIcon("assets/images/file-chart-column.svg"),
                const SizedBox(
                  height: 5,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: themeBlueColor,
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else if (position == 8) {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                circleIcon("assets/images/gavel-light.svg"),
                const SizedBox(
                  height: 5,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: themeBlueColor,
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        // height: 108,
        //width: 158,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),

        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                circleIcon("assets/images/circle-info.svg"),
                const SizedBox(
                  height: 5,
                ),
                Flexible(
                    child: Text(
                  mainMenuModel.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.normal,
                      color: themeBlueColor,
                      fontFamily: 'GraphikMedium'),
                )),
              ],
            )),
      );
    }
  }
}
