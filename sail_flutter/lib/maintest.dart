  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter/cupertino.dart';
  import './pages/home.dart' as home;
  import './pages/eventCalendar.dart' as calendar;
  import './pages/genericPage.dart' as generic;
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

void main() => runApp(new MaterialApp(
      home: new MainDrawer(),
      showSemanticsDebugger: false,
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: false,
    ));

List<ElementFormatter> list = [];
StatefulWidget loadedWidget;
String loadURL = '/home';
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
    load();
    loadedWidget = new home.MyHomePage();
  }

  load() async {
    scraper = new Scrape();
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

    await scraper.getNavigation.then((List<ElementFormatter> returnOnComm) {
      for (var elements in returnOnComm) {
        print('On returned elements for list: \n${elements
            .elementHeader}\n\n${elements.elementURL}\n\n');
        list.add(elements);
      }
    });
    list.add(new ElementFormatter(
      elementHeader: "Calendar",
      elementURL: "/calendar",
      elementAccessible: "",
    ));
  }

  reload() async {
    await scraper.canAccess.then((bool retVal) {
      print('the connection is:\n$retVal\n');
    }).whenComplete(() async {
      print("\ncomplete\n");
    });
    loadedWidget = new home.MyHomePage();
  }

//   StatefulWidget changeBody(String newWidget) {
//     switch (newWidget) {
//       case "/sail/sail-alumni":
//         print("\nalumni load\n");
//         setState(() {
//           scraper = new Scrape();
//           scraper.loadingURL = scraper.lastUsed + newWidget;
//           reload();
//           loadedWidget = new generic.GenericPage(dataContext: newWidget);
//         });
//         break;
//       case "/sail/students":
//         setState(() {
//           scraper = new Scrape();
//           scraper.loadingURL = scraper.lastUsed + newWidget;
//           reload();
//           loadedWidget = new generic.GenericPage(dataContext: newWidget);
//         });
//         break;
//       case "/sail/sail-courses":
//         setState(() {
//           scraper = new Scrape();
//           scraper.loadingURL = scraper.lastUsed + newWidget;
//           reload();
//           loadedWidget = new generic.GenericPage(dataContext: newWidget);
//         });
// //        open new window
//         break;
//       case "/sail":
//         setState(() {
//           scraper = new Scrape();
//           scraper.loadingURL = scraper.lastUsed + newWidget;
//           reload();
//           loadedWidget = new home.MyHomePage(dataContext: newWidget);
//         });
// //        pop
//         break;
//       case "/calendar":
//         setState(() {
//           loadedWidget = new calendar.EventsCalendar();
//         });
// //        open calendar
//         break;
//       default:
// //        error
//         break;
//     }

//     print('\n$newWidget\n');

//     setState(() {
//       loadURL = newWidget;
//     });

//     reload();

//     // TODO: close current running widget open new widget
//     return loadedWidget;
//   }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "$header",
            overflow: TextOverflow.fade,
          ),
          centerTitle: true,
        ),
        body: new SafeArea(
            child: new RefreshIndicator(
                child: loadedWidget, onRefresh: _handleRefresh)
        ),
        drawer: new Drawer(
          child: new ListView.builder(
            itemCount: list == null ? 0 : list.length,
            itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                title: new Text('${list[index].elementHeader}'),
                onTap: () {
                  // changeBody(list[index].elementURL);
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) => loadedWidget));
                },
              );
            },
          ),
        ),
      );

  Future<Null> _handleRefresh() async {

    load();

    Completer<Null> completer = new Completer<Null>();
    completer.complete();

    new Future.delayed(new Duration(seconds: 5)).then((_) {
      completer.complete();
    });

    return completer.future;
  }
}
