import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './pages/home.dart' as home;
import './pages/webPage.dart' as webPage;
import './pages/calendar.dart' as calendar;
import './Scrape.dart';

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.lightBlue,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
  platform: TargetPlatform.iOS,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.lightBlue,
  accentColor: Colors.lightBlueAccent,
  platform: TargetPlatform.android,
);

TargetPlatform defaultTargetPlatform;

void main() =>
    runApp(new MaterialApp(
      home: new MainDrawer(),
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      showSemanticsDebugger: false,
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: false,
    ));

List<ElementFormatter> list = [];
StatefulWidget loadedWidget;
String loadURL;
Scrape scraper;
String header = "";

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => new _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {

  @override
  void initState() {
    super.initState();
    loadURL = '/home';
    load();
    loadedWidget = new home.MyHomePage("/home");
  }

  @override
  void dispose() {
    super.dispose();
  }

  void load() async {
    scraper = new Scrape(loadURL);
    await scraper.canAccess.then((bool retVal) {
      print('the connection is:\n$retVal\n');
    }).whenComplete(() async {
      print("\ncomplete\n");
    });

    await scraper.getHeader.then((String returnOnComm) {
      setState(() {
        header = returnOnComm;
      });
    });

    await scraper.getNavigation.then((List <ElementFormatter> returnOnComm) {
      for (var elements in returnOnComm) {
        print('On returned elements for list: \n${elements
            .elementHeader}\n\n${elements.elementURL}\n\n');
        list.add(elements);
      }
    });
  }

  StatefulWidget changeBody(String newWidget) {
    Navigator.of(context).push(new PageRouteBuilder(
      pageBuilder: (BuildContext context, _, __) {
        return loadedWidget = new home.MyHomePage(newWidget);
      },
    )
    );
    // TODO: close current running widget open new widget
//    return loadedWidget;
  }

  int i = 0;

  @override
  Widget build(BuildContext context) =>
      new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "$header",
            overflow: TextOverflow.fade,
          ),
          centerTitle: true,
        ),
        // body: new home.MyHomePage(),
        body: new RefreshIndicator(
            child: loadedWidget, onRefresh: _handleRefresh),
        drawer: new Drawer(
          child: new ListView.builder(
            itemCount: list == null ? 0 : list.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                title: new Text('${list[index].elementHeader}'),
                onTap: () {
//                  Navigator.pop(context);
                  changeBody(list[index].elementURL);
                },
              );
            },
//            itemBuilder: (BuildContext context, int index) => loadTableNav(index),
          ),
        ),
      );

//  Widget loadTableNav(index){
//    return Container(
//      padding: EdgeInsets.all(5.0),
//      child: Column(
//        children: <Widget>[
//          new Text(list[index].grabHeader),
//        ],
//      ),
//    );
//  }

  Future<Null> _handleRefresh() async {
    setState(() {
      header = "refreshed: $i";
    });
    i++;

    load();

    Completer<Null> completer = new Completer<Null>();
    completer.complete();

    new Future.delayed(new Duration(seconds: 5)).then((_) {
      completer.complete();
    });

    return completer.future;
  }
}
