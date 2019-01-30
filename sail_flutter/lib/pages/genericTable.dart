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

class GenericTable extends StatefulWidget {
  // Scrape dataContext = new Scrape();

//  Widget child;

  GenericTable() {}
  GenericTable.setScraper(Scrape dataContext) {
    scrape = new Scrape();
    print('data context:${dataContext.toString()}');
    scrape = dataContext;
  }
  // static _GenericTableState of(BuildContext context) {
  //   return (context.inheritFromWidgetOfExactType(HomeInhertied)
  //           as HomeInhertied)
  //       .myGenErState;
  // }

  @override
  _GenericTableState createState() => new _GenericTableState();
}

class _GenericTableState extends State<GenericTable> {
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
      // for (var item in table) {
      //   print('screen call for: ${item.text.split('\n')}');
      // }
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
                  return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 50.0,
                        width: 50.0,
                      );
                  break;
                case ConnectionState.active:
                  // print('Table connection is active.');
                  return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 50.0,
                        width: 50.0,
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
            child: _buildTable(),
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
    // _grabObjects();
    return new FutureBuilder(
      future: scrape.getPage,
      builder:
          (BuildContext context, AsyncSnapshot<List<doc.Element>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            print('Table connection does not exist.');
            break;
          case ConnectionState.waiting:
            print('Table connection is waiting.');
            return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 50.0,
                        width: 50.0,
                      );
            break;
          case ConnectionState.active:
            print('Table connection is active.');
            return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 50.0,
                        width: 50.0,
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
        String href;
        data[index].children.forEach((f) {
          href = scrape.splitter(f);
        });
        print("incoming data: ${data[index].toString()}");
        switch (data[index].toString()) {
          case "<html h2>":
            return new Container(
              padding: const EdgeInsets.all(10.0),
              child: new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: '${data[index].text}',
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
            if (data[index].getElementsByTagName('a').isNotEmpty) {
              var nestedAttr = data[index].getElementsByTagName('a');
              return new Container(
                height: 500.0,
                padding: const EdgeInsets.all(10.0),
                child: new ListView.builder(
                  itemCount: nestedAttr.length,
                  itemBuilder: (context, int x) {
                    return new FlatButton(
                      onPressed: () {
                        _checkLaunch(nestedAttr[x].attributes["href"]);
                      },
                      color: Colors.blueAccent,
                      child: Text("${nestedAttr[x].text}"),
                    );
                  },
                ),
              );
            } else {
              return new Container(
                padding: const EdgeInsets.all(10.0),
                child: new RichText(
                  textAlign: TextAlign.start,
                  text: new TextSpan(
                    text: '${data[index].text}',
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              );
            }
            break;
          case "<html h4>":
            return new Container(
              padding: const EdgeInsets.all(10.0),
              child: new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: '${data[index].text}',
                  style: (href != null)
                      ? new TextStyle(
                          color: Colors.blue,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold)
                      : new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                ),
              ),
            );
            break;
          case "<html h5>":
            return new Container(
              padding: const EdgeInsets.all(10.0),
              child: new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: '${data[index].text}',
                  style: (href != null)
                      ? new TextStyle(
                          color: Colors.blue,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold)
                      : new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                ),
              ),
            );
            break;
          // TODO: make special exception for this
          case "<html center>":
            print("center: ${data[index].toString()}");
            return new Text("${data[index].text}");
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
              return _listedView(tableFormat);
            }
            break;
          case "<html strong>":
            if (data[index].getElementsByTagName('a').isNotEmpty) {
              print("data: ${data[index].attributeSpans}");
              href = scrape.splitter(data[index]);
              print("href: $href");

              if (href == null || href.isEmpty) {
                return new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new RichText(
                    textAlign: TextAlign.start,
                    text: new TextSpan(
                        text: '${data[index].outerHtml}',
                        style: new TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              } else {
                return new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new Column(
                    children: <Widget>[
                      new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                            text: '${data[index].text}',
                            style: new TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold)),
                      ),
                      new FlatButton(
                        color: Colors.blue,
                        child: new RichText(
                          textAlign: TextAlign.start,
                          text: new TextSpan(
                            text: '${data[index].text}',
                            style: (href != null)
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
                          (href.isNotEmpty && href != null)
                              ? _checkLaunch(href)
                              : print("none");
                        },
                      ),
                    ],
                  ),
                );
              }
            } else {
              return new Container(
                padding: const EdgeInsets.all(10.0),
                child: new RichText(
                  textAlign: TextAlign.start,
                  text: new TextSpan(
                    text: '${data[index].text}',
                    style: (new TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal)),
                  ),
                ),
              );
            }
            break;
          case "<html span>":
            return new Container(
              padding: const EdgeInsets.all(10.0),
              child: new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: '${data[index].text}',
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

          case "<html h3>":
            return new Container(
              padding: const EdgeInsets.all(10.0),
              child: new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: '${data[index].text}',
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
          case "<html a>":
            print("data: ${data[index].attributeSpans}");
            href = scrape.splitter(data[index]);
            print("href: $href");

            if (href == null) {
              return new Container(
                padding: const EdgeInsets.all(10.0),
                child: new RichText(
                  textAlign: TextAlign.start,
                  text: new TextSpan(
                      text:
                          '${data[index].attributes["href"]}\n${data[index].innerHtml}',
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold)),
                ),
              );
            } else {
              return new Container(
                padding: const EdgeInsets.all(10.0),
                child: new Column(
                  children: <Widget>[
                    new RichText(
                      textAlign: TextAlign.start,
                      text: new TextSpan(
                          text: '${data[index].text}',
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold)),
                    ),
                    new FlatButton(
                      color: Colors.blue,
                      child: new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                          text: 'Request Form',
                          style: (href != null)
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
                        (href.isNotEmpty && href != null)
                            ? _checkLaunch(href)
                            : print("none");
                      },
                    ),
                  ],
                ),
              );
            }
            break;
          case "<html div>":
            return new Text("${data[index].text}");
            break;
          // case "<html br>":
          //   print("skip on page");
          //   break;
          default:
            return new Text("");
            break;
        }
      },
    );
  }

  Widget _debug(List<doc.Element> data) {
    return new ListView.builder(
      itemCount: data.length,
      itemBuilder: (contxt, int index) {
        return new Text("data: ${data[index].toString()}");
      },
    );
  }

  Widget _listedView(List<TableFormatter> tableFormat) {
    return new ListView.builder(
      shrinkWrap: true,
      itemCount: tableFormat.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, int index) {
        return new GestureDetector(
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (context) => new ClassDetail(tableFormat[index]));
          },
          child: new Container(
            height: 100.0,
            width: 100.0,
            decoration: new BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color.fromARGB(100, 0, 0, 0),
                width: 1.5,
              ),
              borderRadius: new BorderRadius.circular(10.0),
            ),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Flexible(
                      child: new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                          text: '${tableFormat[index].courseHead}',
                          style: new TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
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
                    new Container(
                      width: 15.0,
                      height: 15.0,
                    ),
                    new Row(
                      children: <Widget>[
                        new Icon(
                          Icons.info_outline,
                          color: Colors.black,
                        ),
                        new Text('Tap for more information'),
                      ],
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

// MARK: Opens embeded urls if any
  _checkLaunch(String urlScheme) async {
    if (await canLaunch(urlScheme)) {
      await launch(urlScheme);
    } else {
      if (urlScheme.contains('//')) {
        // var somethingBack = urlScheme.split('//');
        var somethingBack = urlScheme.replaceFirst('//', 'https:');
        print(somethingBack);
        _checkLaunch(somethingBack);
      } else {
        // TODO: Add dialog window
        throw 'invalid urlSceme: $urlScheme';
      }
    }
    // launch(urlScheme);
  }
}

class ClassDetail extends StatefulWidget {
  TableFormatter data;

  ClassDetail(TableFormatter data, {Key key}) : super(key: key) {
    this.data = data;
  }

  State createState() => ClassDetailState();
}

class ClassDetailState extends State<ClassDetail> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SafeArea(
        child: new Container(
          height: 500.0,
          padding: const EdgeInsets.all(10.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: '${this.widget.data.courseTitle}',
                  style: new TextStyle(
                    color: new Color.fromRGBO(20, 20, 20, 100.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textScaleFactor: 2,
              ),
              new Divider(),
              new Column(
                children: <Widget>[
                  // TODO: add bigger fonts
                  new Text(
                    'Section: ${this.widget.data.courseSection}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textScaleFactor: 2,
                  ),
                  new Text(
                    'Lecturer: ${this.widget.data.lecturer}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textScaleFactor: 2,
                  ),
                  new Text(
                    'Time: ${this.widget.data.dateTime}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w200),
                    textScaleFactor: 2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
