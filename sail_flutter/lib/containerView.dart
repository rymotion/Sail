import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './pages/home.dart';
import './pages/eventCalendar.dart';
import './pages/calendar.dart';
import './pages/genericPage.dart';
import './pages/genericTable.dart';
import './Scrape.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import './pages/studentID.dart';

List<ElementFormatter> list = [];
StatefulWidget loadedWidget;
String loadURL = '/home';
Scrape scraper;
String header = "";

class MainDrawer extends StatefulWidget {
// Multiple call stack ERROR
// TODO: Fix multiple instantiation
  @override
  _MainDrawerState createState() => new _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  // Future <SharedPreferences> _prefs = SharedPreferences.getInstance();
  var hasTapped = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // TODO: add cache to menu
    list = [];
    loadedWidget;
    loadURL = '/home';
    scraper;
    header = "";
  }

  _MainDrawerState() {
    load();
  }
  @override
  void initState() {
    super.initState();
  }

  load() async {
    // final SharedPreferences prefs = await _prefs;
    scraper = new Scrape();
    await scraper.canAccess.then((bool retVal) {
      print('the connection is:\n$retVal\n');
    }).whenComplete(() async {
      print("\ncomplete\n");
    });

    await scraper.getHeader.then((String returnOnComm) {
      print('head');
      setState(() {
        header = returnOnComm;
      });
    });

    list = await scraper.getNavigation;

    list.add(new ElementFormatter(
      elementHeader: "Event Calendar",
      elementURL: "/calendar",
      elementAccessible: "",
    ));
    list.add(new ElementFormatter(
      elementHeader: "Harbor Calendar",
      elementURL: "/harbor_calendar",
      elementAccessible: "",
    ));
    list.add(new ElementFormatter(
      elementHeader: "Appointment Scheduler",
      elementURL: "https://csusb.mywconline.net/",
      elementAccessible: "",
    ));
    list.add(new ElementFormatter(
      elementHeader: "Event Check-In",
      elementURL: "/check-in",
      elementAccessible: "",
    ));
  }

  reload() async {
    await scraper.canAccess.then((bool retVal) {
      print('the connection is:\n$retVal\n');
    }).whenComplete(() async {
      print("\ncomplete\n");
    });
    loadedWidget = new MyHomePage();
  }

  changeBody(String newWidget) {
    // var newPage = GenericPage();
    var newPage;
    switch (newWidget) {
      case "/sail/sail-alumni":
        print("\nalumni load\n");
        // scraper.loadingURL = scraper.lastUsed + newWidget;
        newPage = new GenericPage.setScraper(
            (scraper = new Scrape.setLoad(newWidget)));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => newPage));
        break;
      case "/sail/students":
        debugPrint("student");
        // scraper.loadingURL = scraper.lastUsed + newWidget;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new GenericPage.setScraper(
                    (scraper = new Scrape.setLoad(newWidget)))));
        break;
      case "/sail/sail-courses":
        // scraper.loadingURL = scraper.lastUsed + newWidget;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new GenericTable.setScraper(
                    (scraper = new Scrape.setLoad(newWidget)))));
        break;
      case "/sail":
        // scraper.loadingURL = scraper.lastUsed + newWidget;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new GenericPage.setScraper(
                    (scraper = new Scrape.setLoad(newWidget)))));
        break;
      case "/calendar":
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new EventsCalendar()));
//        open calendar
        break;
      case "/harbor_calendar":
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new CalendarScreen()));
        break;
      case "/check-in":
        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new ScanID()));
        break;
      default:
        _checkLaunch(newWidget);
        break;
    }

    print('\n$newWidget\n');

    setState(() {
      loadURL = newWidget;
    });

    // reload();

    // TODO: close current running widget open new widget
    debugPrint("hit end and will return");
    return loadedWidget;
  }

// MARK: This allows us to safely check if this is a URL Scheme safely
  _checkLaunch(String urlScheme) async {
    if (await canLaunch(urlScheme)) {
      await launch(urlScheme,
          forceSafariVC: false,
          forceWebView: false,
          statusBarBrightness: Brightness.light);
    } else {
      // TODO: Add dialog window
      throw 'invalid urlSceme: $urlScheme';
    }
    // launch(urlScheme);
  }

  @override
  Widget build(BuildContext context) => new Drawer(
        child: Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          direction: Axis.vertical,
          children: <Widget>[
            new Container(
              width: MediaQuery.of(context).size.width,
              child: _buildList(),
            ),
            new Divider(),
            new Container(
              width: MediaQuery.of(context).size.width,
              child: buildContact(),
            ),
          ],
        ),
        semanticLabel: "Main Menu",
      );

  Widget _buildList() {
    return new FutureBuilder(
      future: scraper.getNavigation,
      builder: (BuildContext context,
          AsyncSnapshot<List<ElementFormatter>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            //TODO: add error code
            break;
          case ConnectionState.waiting:
            return new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
              ],
            );
            break;
          default:
            if (snapshot.hasError) {
              print('Snapshot Error: ${snapshot.error.toString()}');
            } else {
              return new ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, int index) {
                  print('list: ${list[index].elementURL}');
                  return new GestureDetector(
                    // onTapDown: _tapDown,
                    // onTapUp: _tapUp,
                    // onTapCancel: _tapCancel,
                    onTap: () {
                      _onTap(list[index].elementURL);
                    },
                    child: new Container(
                      color: hasTapped ? Colors.blueAccent : Colors.white,
                      child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new ListTile(
                          title: new Text('${list[index].elementHeader}'),
                        ),
                        new Divider(),
                      ],
                      
                    ),
                    ),
                  );
                },
              );
            }
            break;
        }
      },
    );
  }

  void _onTap(String newWidget) {
    changeBody(newWidget);
  }

  void _tapDown(TapDownDetails details){
    setState((){
      hasTapped = true;
    });
  }

  void _tapUp(TapUpDetails details){
    setState((){
      hasTapped = false;
    });
  }
  void _tapCancel(){
    setState((){
      hasTapped = false;
    });
  }
  
  Widget buildContact() {
    return new FutureBuilder(
      future: scraper.getContactMain,
      builder: (context, AsyncSnapshot<List<dom.Element>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
              ],
            );
            break;
          case ConnectionState.active:
            return new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
              ],
            );
            break;
          // case ConnectionState.done:
          //   break;
          default:
            if (snapshot.hasData) {
              return new ListView.builder(
                // scrollDirection: Axis.vertical,
                itemCount: snapshot.data.length,
                itemBuilder: (context, int index) {
                  String href;
                  print('item builder:${snapshot.data[index].children}');
                  snapshot.data[index].children.forEach((f) {
                    href = scraper.splitter(f);
                  });
                  return new Container(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    child: new RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                          text: ' ${snapshot.data[index].text}',
                          style: (href.isNotEmpty)
                              ? new TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal)
                              : new TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () {
                              (href.isNotEmpty && href != null)
                                  ? _checkLaunch(href)
                                  : print("none");
                            }),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
            } else {}
            break;
        }
      },
    );
  }
}
