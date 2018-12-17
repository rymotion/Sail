import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as doc;
import 'dart:async';
import '../Scrape.dart';
import 'package:url_launcher/url_launcher.dart';

List list = new List();
Scrape scrape;
Scrape scrapeSecondPass;

String secondPassURL = "https://www.csusb.edu/sail/sail-alumni/join-sail’s-alumni-list";

class AlumniPage extends StatefulWidget {
  // Scrape dataContext = new Scrape();

//  Widget child;

  AlumniPage() {}
  AlumniPage.setScraper(Scrape dataContext) {
    scrape = new Scrape();
    print('data context:${dataContext.toString()}');
    scrape = dataContext;
    scrapeSecondPass = new Scrape.setLoad(secondPassURL);
  }
  // static _GenericPageState of(BuildContext context) {
  //   return (context.inheritFromWidgetOfExactType(HomeInhertied)
  //           as HomeInhertied)
  //       .myGenErState;
  // }

  @override
  _AlumniPageState createState() => new _AlumniPageState();
}

class _AlumniPageState extends State<AlumniPage> {
  var header = " ";
  List body = [];
  List<doc.Element> table;

  _grabObjects() async {
    // scrapeSecondPass = new Scrape.setLoad(secondPassURL);
    try {
      // TODO: add warning connect to network
      if (!await scrape.canAccess && !await scrapeSecondPass.canAccess) {
        var returnHeader = await scrapeSecondPass.getHeader;
        setState(() {
          header = returnHeader;
        });
        var returnBody = await scrapeSecondPass.getBody;
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
                new Expanded(child: _buildTable()),
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
      future: scrapeSecondPass.getPage,
      builder:
          (BuildContext context, AsyncSnapshot<List<doc.Element>> snapshot) {
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
              // return tableCards(context, snapshot.data);
              return new Container(
                padding: const EdgeInsets.all(20.0),
                child: _tableFormatter(snapshot.data),
              );
            } else if (!snapshot.hasData) {
              return new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.all(20.0),
                    child: new RichText(
                      textAlign: TextAlign.start,
                      text: new TextSpan(
                        text:
                            "You may not be properly connected to the internet.\nPlease check your settings and refresh the page.",
                        style: new TextStyle(
                          color: Colors.redAccent,
                          fontSize:
                              MediaQuery.of(context).textScaleFactor + 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
              // return new Text(
              //     'You may not be properly connected to the internet.\nPlease check your settings and refresh the page.');
            } else if (snapshot.hasError) {
              print('ERROR: ${snapshot.error.toString()}');
            }
        }
      },
    );
  }

  Widget _tableFormatter(List<doc.Element> data) {
    return new ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, int index) {
        switch (data[index].toString()) {
          case "<html h2>":
            return new Container(
              height: 100.0,
              padding: const EdgeInsets.all(20.0),
              child: new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: ' ${data[index].text}',
                  style: new TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            );
            break;
          case "<html p>":
            print("hit p");
            String href;
            data[index].children.forEach((f) {
              // setState(() {
              //   href = scrape.splitter(f);
              // });
              href = scrape.splitter(f);
            });
            return new Container(
              height: 100.0,
              padding: const EdgeInsets.all(20.0),
              child: new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: ' ${data[index].text}',
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
            break;
          case "<html tbody>":
            print("hit case");
            List<TableFormatter> tableFormat = new List<TableFormatter>();
            data[index].getElementsByTagName('tr').forEach((f) {
              tableFormat.add(new TableFormatter(
                courseTitle: f.getElementsByTagName('td')[0].text,
                lecturer: f.getElementsByTagName('td')[1].text,
                courseSection: f.getElementsByTagName('td')[2].text,
                catalogNum: f.getElementsByTagName('td')[3].text,
                daySched: f.getElementsByTagName('td')[4].text,
                dateTime: f.getElementsByTagName('td')[5].text,
                roomCall: f.getElementsByTagName('td')[6].text,
              ));
            });
            return new ListView.builder(
              shrinkWrap: true,
              itemCount: tableFormat.length,
              itemBuilder: (context, int index) {
                return new GestureDetector(
                  onTap: () {},
                  child: new Container(
                    height: 100.0,
                    width: 100.0,
                    decoration:
                        new BoxDecoration(color: Colors.white, boxShadow: [
                      new BoxShadow(
                        color: Colors.black45,
                        offset: Offset(20, 5),
                        blurRadius: 5.0,
                      ),
                    ]),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Flexible(
                              child: new RichText(
                                textAlign: TextAlign.justify,
                                text: new TextSpan(
                                  text: '${tableFormat[index].courseHead}',
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 3,
                              ),
                            ),
                            new Flexible(
                              child: new RichText(
                                textAlign: TextAlign.justify,
                                text: new TextSpan(
                                  text: '${tableFormat[index].lecName}',
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                        new Divider(),
                      ],
                    ),
                  ),
                );
              },
            );
            break;
          case "<html thead>":
            // return new Container(
            //   padding: const EdgeInsets.all(20.0),
            //   child: new RichText(
            //       textAlign: TextAlign.start,
            //       text: new TextSpan(
            //         text: ' ${data[index].outerHtml} thread container',
            //         style: (href != null)
            //             ? new TextStyle(
            //                 color: Colors.blue,
            //                 fontSize: 15.0,
            //                 fontWeight: FontWeight.bold)
            //             : new TextStyle(
            //                 color: Colors.black,
            //                 fontSize: 15.0,
            //                 fontWeight: FontWeight.normal),
            //         recognizer: new TapGestureRecognizer()
            //           ..onTap = () {
            //             (href.isNotEmpty && href != null)
            //                 ? _checkLaunch(href)
            //                 : print("none");
            //           },
            //       ),
            //     ),
            // );
            return new Divider();
            break;
          case "<html table>":
            // return new Text('${data[index].children}');
            for (var table in data[index].getElementsByTagName("tbody")) {
              List<TableFormatter> tableFormat = new List<TableFormatter>();
              table.getElementsByTagName('tr').forEach((f) {
                tableFormat.add(new TableFormatter(
                  courseTitle: f.getElementsByTagName('td')[0].text,
                  lecturer: f.getElementsByTagName('td')[1].text,
                  courseSection: f.getElementsByTagName('td')[2].text,
                  catalogNum: f.getElementsByTagName('td')[3].text,
                  daySched: f.getElementsByTagName('td')[4].text,
                  dateTime: f.getElementsByTagName('td')[5].text,
                  roomCall: f.getElementsByTagName('td')[6].text,
                ));
              });
              return new ListView.builder(
                shrinkWrap: true,
                itemCount: tableFormat.length,
                itemBuilder: (context, int index) {
                  return new GestureDetector(
                    onTap: () {},
                    child: new Container(
                      height: 100.0,
                      width: 100.0,
                      decoration:
                          new BoxDecoration(color: Colors.white, boxShadow: [
                        new BoxShadow(
                          color: Colors.black45,
                          offset: Offset(20, 5),
                          blurRadius: 5.0,
                        ),
                      ]),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Flexible(
                                child: new RichText(
                                  textAlign: TextAlign.justify,
                                  text: new TextSpan(
                                    text: '${tableFormat[index].courseHead}',
                                    style: new TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 3,
                                ),
                              ),
                              new Flexible(
                                child: new RichText(
                                  textAlign: TextAlign.justify,
                                  text: new TextSpan(
                                    text: '${tableFormat[index].lecName}',
                                    style: new TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 3,
                                ),
                              ),
                            ],
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
          case "<html br>":
            return new Divider();
            break;

          case "<html li>":
            String href;
            data[index].children.forEach((f) {
              // setState(() {
              //   href = scrape.splitter(f);
              // });
              href = scrape.splitter(f);
            });
            return new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    new Expanded(
                        child: new Container(
                          padding: const EdgeInsets.all(5.0),
                          child:  new RichText(
                            textAlign: TextAlign.start,
                            text: new TextSpan(
                              text: '${data[index].text}',
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
                            overflow: TextOverflow.ellipsis,
                            maxLines: 10,
                            softWrap: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
            break;
          default:
            String href;
            data[index].children.forEach((f) {
              // setState(() {
              //   href = scrape.splitter(f);
              // });
              href = scrape.splitter(f);
            });
            return new Container(
              padding: const EdgeInsets.all(20.0),
              child: new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: ' ${data[index].text}',
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
            break;
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
            } else if (snapshot.hasError) {
            } else {
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
                  text: new TextSpan(
                    text: "Header",
                    style: new TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
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
