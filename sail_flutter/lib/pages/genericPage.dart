import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as doc;
import 'dart:async';
import '../Scrape.dart';
import 'package:url_launcher/url_launcher.dart';

List list = new List();
Scrape scrape = new Scrape();

class GenericPage extends StatefulWidget {
  // Scrape dataContext = new Scrape();

//  Widget child;

  GenericPage() {}
  GenericPage.setScraper(Scrape dataContext) {
    scrape = new Scrape();
    print('data context:${dataContext.toString()}');
    scrape = dataContext;
  }
  static _GenericPageState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(HomeInhertied)
            as HomeInhertied)
        .myGenErState;
  }

  @override
  _GenericPageState createState() => new _GenericPageState();
}

class _GenericPageState extends State<GenericPage> {
  var header = " ";
  List body = [];
  List<doc.Element> table;

  _grabObjects() async {
    try {
      // TODO: add warning connect to network
      if (!await scrape.canAccess) {
        var returnHeader = await scrape.getHeader;
        setState(() {
          header = returnHeader;
        });
        var returnBody = await scrape.getBody;
        setState(() {
          body = returnBody;
        });
        // list = await scrape.getTable;
        await scrape.sideMenu;
      } else {
        // TODO: spout error
      }
      for (var item in table) {
        print('screen call for: ${item.text.split('\n')}');
      }
    } catch (e) {
      print('${e.toString()}');
    }
  }

  @override
  initState() {
    // TODO: implement initState
    _grabObjects();
    super.initState();
  }

  @override
  dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  var spacer = new SizedBox(height: 32.0);

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new FutureBuilder(
            future: scrape.getHeader,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  // print('Table connection does not exist.');
                  break;
                case ConnectionState.waiting:
                  // print('Table connection is waiting.');
                  return new Container(
                    height: 50.0,
                    width: 50.0,
                    child: new CircularProgressIndicator(),
                  );
                  break;
                case ConnectionState.active:
                  // print('Table connection is active.');
                  return new Container(
                    height: 50.0,
                    width: 50.0,
                    child: new CircularProgressIndicator(),
                  );
                  break;
                default:
                  if (snapshot.hasData) {
                    // print('there is data.');
                    return new Text('${snapshot.data}');
                  }
              }
            },
          ),
        ),
        body: new SafeArea(
          child: new RefreshIndicator(
            // child: new Text("$header"),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Expanded(child: _buildContext()),
                // new Expanded(child: _buildTable()),
              ],
            ),
            onRefresh: _refreshHandler,
            backgroundColor: Colors.black38,
          ),
        ),
      );

  Future<Null> _refreshHandler() async {
    _grabObjects();
  }

// MARK: Build table of data
  Widget _buildTable() {
    print('Hit build table');
    _grabObjects();
    return new FutureBuilder(
      future: scrape.getPage,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            print('Table connection does not exist.');
            break;
          case ConnectionState.waiting:
            print('Table connection is waiting.');
            return new Container(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(),
            );
            break;
          case ConnectionState.active:
            print('Table connection is active.');
            return new Container(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(),
            );
            break;
          default:
            if (snapshot.hasData) {
              print('there is data for table');
              return tableCards(context, snapshot.data);
            } else if (!snapshot.hasData) {
              return new Text(
                  'You may not be properly connected to the internet.\nPlease check your settings and refresh the page.');
            } else if (snapshot.hasError) {
              print('ERROR: ${snapshot.error.toString()}');
            }
        }
      },
    );
  }

// MARK: Gets data in body of webpage
  Widget _buildContext() {
    // _grabObjects();
    return new FutureBuilder(
      future: scrape.getBody,
      builder: (context, AsyncSnapshot<List<doc.Element>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // Make an error dialog box appear
            break;
          case ConnectionState.active:
            return new Container(
              height: 100.0,
              width: 100.0,
              child: CircularProgressIndicator(),
            );
            break;
          default:
            if (snapshot.hasData) {
              print('generic return: ${snapshot.data.toString()}');
              return new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, int index) {
                  String href;
                  snapshot.data[index].children.forEach((f) {
                    print('home outer: ${f.outerHtml}');
                    href = scrape.splitter(f);
                  });

                  print(snapshot.data[index].toString());
                  // Title
                  if (snapshot.data[index].toString() == "<html h2>") {
                    return new Container(
                      padding: const EdgeInsets.all(20.0),
                      child: new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                          text: ' ${snapshot.data[index].text}',
                          style: (href != null)
                              ? new TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold)
                              : new TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () {
                              (href.isNotEmpty && href != null)
                                  ? _checkLaunch(href)
                                  : print("none");
                            },
                        ),
                      ),
                    );
                  } else if (snapshot.data[index].toString() == "<html p>") {
                    return new Container(
                      padding: const EdgeInsets.all(20.0),
                      child: new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                          text: ' ${snapshot.data[index].text}',
                          style: (href != null)
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
                            },
                        ),
                      ),
                    );
                  }
                },
              );
            } else if (snapshot.hasError) {} else {
              return new Container(
                height: 100.0,
                width: 100.0,
                child: CircularProgressIndicator(),
              );
            }
            break;
        }
      },
    );
  }

  Widget tableCards(BuildContext context, List<PageFormatter> data) {
    List<PageFormatter> element = data;
    return new ListView.builder(
      itemCount: element.length,
      itemBuilder: (context, int index) {
        var page = element[index].grabPage;
        var table = element[index].grabTable;
        for (var x = 0; x < page.length; x++) {
          for (var y = 0; y < table.length; y++) {
            print(table[y].lecName);
            return new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // MARK: This is the heading
                new RichText(
                  textAlign: TextAlign.start,
                  text: new TextSpan(text: "Header", style: new TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                ),
                // MARK: This is the data context of the table
                new RichText(
                  textAlign: TextAlign.start,
                  text: new TextSpan(
                    text: '${table[y].lecName}',
                    recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      // push over to more detail
                    },
                  ),
                ),
              ],
            );
          }
        }
      },
      padding: const EdgeInsets.all(2.0),
    );
  }

// MARK: Opens embeded urls if any
  _checkLaunch(String urlScheme) async {
    if (await canLaunch(urlScheme)) {
      await launch(urlScheme,
          forceSafariVC: false,
          forceWebView: false,
          statusBarBrightness: Brightness.light);
    } else {
      if (urlScheme.contains('//')) {
        // var somethingBack = urlScheme.split('//');
        var somethingBack = urlScheme.replaceFirst('//', 'https:');
        _checkLaunch(somethingBack);
      } else {
        // TODO: Add dialog window
        throw 'invalid urlSceme: $urlScheme';
      }
    }
    // launch(urlScheme);
  }
}

class HomeInhertied extends InheritedWidget {
  final _GenericPageState myGenErState;

  HomeInhertied({
    Key key,
    @required this.myGenErState,
    @required Widget child,
  })
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(HomeInhertied oldWidget) => true;
}
