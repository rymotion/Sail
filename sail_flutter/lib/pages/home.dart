import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sail_flutter/Scrape.dart';
import 'dart:async';
import './webPage.dart';
import '../main.dart';
//import '../Scrape.dart' as scrape;

List list = new List();

class MyHomePage extends StatefulWidget {

  String dataContext;

  MyHomePage(this.dataContext);

  @override
  _MyHomePageState createState() => new _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  var header = " ";
  var body = " ";

  _grabObjects() async {
    await scraper.canAccess.then((bool retVal) {
      // print("\nMenu access: ${retVal.toString()}");
    });
    await scraper.getHeader.then((String returnOnCom) {
      print("\nFrom header on home.dart: $returnOnCom\n");
      setState(() {
        header = returnOnCom;
      });
    });
    await scraper.getBody.then((String returnOnCom) {
      print("\nFrom body on home.dart: $returnOnCom\n");
      setState(() {
        body = returnOnCom;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _grabObjects();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  var spacer = new SizedBox(height: 32.0);

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new RefreshIndicator(
          // child: new Text("$header"),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      '$body',
                      maxLines: 20,
                      overflow: TextOverflow.clip,
                      style: new TextStyle(fontSize: 15.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onRefresh: _refreshHandler,
          backgroundColor: Colors.black38,
        ),
      );
  Future<Null> _refreshHandler() async {
    _grabObjects();
  }
}
