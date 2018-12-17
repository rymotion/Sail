import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../Scrape.dart' as scraper;
import 'package:sail_flutter/containerView.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

List list = new List();

final scraper.Scrape scrape = new scraper.Scrape();

class MyHomePage extends StatefulWidget {
  String dataContext;

//  Widget child;

  MyHomePage({Key key, this.dataContext}) : super(key: key);

//  need to be able to set and get url string

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String header;
  List<dom.Element> body = List<dom.Element>();

  _grabObjects() async {
    try {
      if (!await scrape.canAccess) {
        var returnHeader = await scrape.getHeader;
        setState(() {
          header = returnHeader;
        });
        var returnBody = await scrape.getBody;
        setState(() {
          body = returnBody.cast<dom.Element>();
        });

        var x = await scrape.sideMenu;
        print(x.toString());
      } else {
        // TODO: Spout error
      }
    } catch (e) {
      print('${e.toString()}');
    }
  }

  dom.Element f2(dom.Element f) => f;

  @override
  void initState() {
    // TODO: implement initState
//    super.initState();
    _grabObjects();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  var spacer = new SizedBox(height: 32.0);
  MainDrawer drawer = new MainDrawer();

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new FutureBuilder(
            future: scrape.getHeader,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  print('Table connection does not exist.');
                  break;
                case ConnectionState.waiting:
                  print('Table connection is waiting.');
                  return new Container(
                    height: 100.0,
                    width: 100.0,
                    child: CircularProgressIndicator(),
                  );
                  break;
                case ConnectionState.active:
                  print('Table connection is active.');
                  return new Container(
                    height: 100.0,
                    width: 100.0,
                    child: CircularProgressIndicator(),
                  );
                  break;
                default:
                  if (snapshot.hasData) {
                    print('there is data.');
                    return new Text('${snapshot.data}');
                  }
              }
            },
          ),
        ),
        drawer: drawer,
        body: new SafeArea(
          child: new RefreshIndicator(
            // child: new Text("$header"),
            // TODO: add instagram feed and program contact details
            child: _buildContext(),
            onRefresh: _refreshHandler,
          ),
        ),
      );

  Widget _buildContext() {

    return new FutureBuilder(
      future: scrape.getBody,
      builder: (BuildContext context, AsyncSnapshot<List<dom.Element>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            //  ERROR
            break;
          case ConnectionState.waiting:
            return new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new CircularProgressIndicator(),
              ],
            );
            break;

          case ConnectionState.done:
            if (snapshot.hasError) {
              print('${snapshot.error.toString()}');
            } else if (snapshot.hasData) {

              // snapshot.data.forEach((data){
              //   href = scrape.splitter(data);
              //   body.add(data);
              //   print("returned data: ${data.toString()}");
              //   print("current running length: ${body.length}");
              // });
              return new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, int index){
                  String href;
                  snapshot.data[index].children.forEach((f) {

                    href = scrape.splitter(f);
                  });
                  if (snapshot.data[index].toString() == "<html h2>") {
                    return new Container(
                      padding: const EdgeInsets.all(20.0),
                      child: new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                          text: '${snapshot.data[index].text}',
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
                          text: '${snapshot.data[index].text}',
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
            }
            break;
          default:
            break;
        }
      },
    );
  }

  _checkLaunch(String urlScheme) async {
    print(urlScheme);
    if (await canLaunch(urlScheme)) {
      await launch(urlScheme,
          forceSafariVC: false,
          forceWebView: false,
          statusBarBrightness: Brightness.light);
    } else {
      if (urlScheme.contains('//')) {
        // var somethingBack = urlScheme.split('//');
        var somethingBack = urlScheme.replaceFirst('//', 'https:');

        // var somethingBack = urlScheme.replaceFirst('//', ' ');
        _checkLaunch(somethingBack);
      } else {
        // TODO: Add dialog window
        throw 'invalid urlSceme: $urlScheme';
      }
    }
    // launch(urlScheme);
  }

  Widget _loadAsync(Future<String> output) {
    _grabObjects();
    if (output == null) {
      return new LinearProgressIndicator();
    } else {
      return new FutureBuilder(
        future: output,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            return new Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
              child: new Text(
                '$data',
                softWrap: true,
                overflow: TextOverflow.fade,
                style: new TextStyle(fontSize: 15.0),
              ),
            );
          } else {
            return new LinearProgressIndicator();
          }
        },
      );
    }
  }

  Future<Null> _refreshHandler() async {
    print("hit refresh Handler");
    _grabObjects();
  }
}
