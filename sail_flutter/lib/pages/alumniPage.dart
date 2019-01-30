import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as doc;
import 'dart:async';
import '../Scrape.dart';
import 'package:url_launcher/url_launcher.dart';

List list = new List();
Scrape scrape;
Scrape scrapeSecondPass;
Scrape scrapeThirdPass;

class AlumniPage extends StatefulWidget {
  AlumniPage() {}
  AlumniPage.setScraper(Scrape dataContext) {
    scrape = new Scrape();
    print('data context:${dataContext.toString()}');
    scrape = dataContext;
    scrapeSecondPass =
        new Scrape.setLoad("/sail/sail-alumni/join-sail’s-alumni-list");
    scrapeThirdPass = new Scrape.setLoad("/sail/sail-alumni/trio-sss-alumni-association");
  }

  @override
  _AlumniPageState createState() => new _AlumniPageState();
}

class _AlumniPageState extends State<AlumniPage> {
  var header = " ";
  List body = [];
  List<doc.Element> table;

  @override
  initState() {
    // TODO: implement initState

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
                  break;
                case ConnectionState.waiting:
                  return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 100.0,
                        width: 100.0,
                      );
                  break;
                case ConnectionState.active:
                  return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 100.0,
                        width: 100.0,
                      );
                  break;
                default:
                  if (snapshot.hasData) {
                    return new Text('${snapshot.data}');
                  }
              }
            },
          ),
        ),
        body: new SafeArea(
          child: new RefreshIndicator(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildFirstPage(),
                _buildSecondPage(),
                _buildThirdPage(),
                // new Expanded(child: _buildSecondPage()),
                // new Expanded(child: _buildThirdPage()),
                new Container(padding: const EdgeInsets.all(10.0),
                child: new Column(
                  children: <Widget>[
                    new Text("For any other general information on the Alumni Association for California State University San Bernardino, please refer to the link below."),
                    new FlatButton(
                      color: Colors.blue,
                      child: new Text("CSUSB Alumni Association"),
                      onPressed: () => _checkLaunch("http://www.csusb.edu/alumni"),
                    ),
                  ],
                ),),
              ],
            ),
            onRefresh: _refreshHandler,
            backgroundColor: Colors.black38,
          ),
        ),
      );

  Future<Null> _refreshHandler() async {}

// MARK: Build table of data
  Widget _buildFirstPage() {
    return new FutureBuilder(
      future: scrape.getPage,
      builder:
          (BuildContext context, AsyncSnapshot<List<doc.Element>> snapshot) {
        return formatTable(snapshot);
      },
    );
  }

  Widget _buildSecondPage() {
    return new FutureBuilder(
      future: scrapeSecondPass.getPage,
      builder:
          (BuildContext context, AsyncSnapshot<List<doc.Element>> snapshot) {
        return formatTable(snapshot);
      },
    );
  }

  Widget _buildThirdPage(){
    return new FutureBuilder(
      future: scrapeThirdPass.getPage,
      builder:
          (BuildContext context, AsyncSnapshot<List<doc.Element>> snapshot) {
        return formatTable(snapshot);
      },
    );
  }

  Widget formatTable(AsyncSnapshot<List<doc.Element>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        print('Table connection does not exist.');
        break;
      case ConnectionState.waiting:
        print('Table connection is waiting.');
        return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 100.0,
                        width: 100.0,
                      );
        break;
      case ConnectionState.active:
        print('Table connection is active.');
        return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 100.0,
                        width: 100.0,
                      );
        break;
      default:
        if (snapshot.hasData) {
          print('there is data.');

          if (snapshot.data.first.hasChildNodes() &&
              snapshot.data.first.getElementsByTagName('a').isNotEmpty) {
            String embededURL = scrape.splitter(snapshot.data.first);
            return new Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    new RichText(
                      textAlign: TextAlign.start,
                      text: new TextSpan(
                        text: '${snapshot.data.first.text}',
                        style: new TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    new FlatButton(
                      color: Colors.blue,
                      child: new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                          text: 'Sign Up Here',
                          style: (embededURL != null)
                              ? new TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal)
                              : new TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal),
                        ),
                      ),
                      onPressed: () {
                        (embededURL.isNotEmpty && embededURL != null)
                            ? _checkLaunch(embededURL)
                            : print("none");
                      },
                    ),
                  ],
                ));
          } else {
            return new Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    new RichText(
                      textAlign: TextAlign.start,
                      text: new TextSpan(
                        text: '${snapshot.data.first.text}',
                        style: new TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ));
          }
        }
    }
    // return Text('');
  }

// MARK: Opens embeded urls if any
  _checkLaunch(String urlScheme) async {
    if (await canLaunch(urlScheme)) {
      await launch(urlScheme);
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
