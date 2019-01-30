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
Scrape scrapeThirdPass;

class StudentPage extends StatefulWidget {
  StudentPage() {}
  StudentPage.setScraper(Scrape dataContext) {
    scrape = new Scrape();
    print('data context:${dataContext.toString()}');
    scrape = dataContext;
    scrapeSecondPass =
        new Scrape.setLoad("/sail/students/prospective-students");
    scrapeThirdPass = new Scrape.setLoad("/sail/students/current-students");
  }

  @override
  _StudentPageState createState() => new _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
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
                    height: 50.0,
                    width: 50.0,
                  );
                  break;
                case ConnectionState.active:
                  return new SizedBox(
                    child: CircularProgressIndicator(),
                    height: 50.0,
                    width: 50.0,
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
                new Expanded(child: _buildThirdPage()),
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

  Widget _buildThirdPage() {
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
        if (snapshot.data.isNotEmpty) {
          print('there is data.');
          return new ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, int index) {
              print(snapshot.data[index].toString());
              switch (snapshot.data[index].toString()) {
                case "<html h2>":
                  return new Container(
                    height: 100.0,
                    padding: const EdgeInsets.all(20.0),
                    child: new RichText(
                      textAlign: TextAlign.start,
                      text: new TextSpan(
                        text: '${snapshot.data[index].text}',
                        style: new TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                  break;
                case "<html h3>":
                  return new Container(
                    height: 100.0,
                    padding: const EdgeInsets.all(20.0),
                    child: new RichText(
                      textAlign: TextAlign.start,
                      text: new TextSpan(
                        text: '${snapshot.data[index].text}',
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
                  String title;
                  snapshot.data[index].children.forEach((f) {
                    href = scrape.splitter(f);
                    title = f.text;
                  });

                  if (snapshot.data[index]
                      .getElementsByTagName('a')
                      .isNotEmpty) {
                    return new Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            new RichText(
                              textAlign: TextAlign.start,
                              text: new TextSpan(
                                text: '${snapshot.data[index].text}',
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            new FlatButton(
                              color: Colors.blue,
                              child: new RichText(
                                textAlign: TextAlign.start,
                                text: new TextSpan(
                                  text: title,
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
                        ));
                  } else if (snapshot.data[index].text == null) {
                    return new Divider();
                  } else {
                    return new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: new RichText(
                        textAlign: TextAlign.start,
                        text: new TextSpan(
                          text: '${snapshot.data[index].text}',
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    );
                  }
                  break;
                case "<html tbody>":
                  print("hit case");
                  List<TableFormatter> tableFormat = new List<TableFormatter>();
                  snapshot.data[index].getElementsByTagName('tr').forEach((f) {
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
                          decoration: new BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
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
                                        text:
                                            '${tableFormat[index].courseHead}',
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
                  return new Divider();
                  break;
                case "<html table>":
                  for (var table
                      in snapshot.data[index].getElementsByTagName("tbody")) {
                    List<TableFormatter> tableFormat =
                        new List<TableFormatter>();
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
                            decoration: new BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
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
                                          text:
                                              '${tableFormat[index].courseHead}',
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
                  snapshot.data[index].children.forEach((f) {
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
                case "<html div>":
                  return new Divider();
                  break;
                case "<html ul>":
                  var bulletList = snapshot.data[index].children.toList();
                  return new ListView.builder(
                    shrinkWrap: true,
                    itemCount: bulletList.length,
                    itemBuilder: (context, int list) {
                      return new ListTile(
                        leading: new Container(
                          height: 10.0,
                          width: 10.0,
                            decoration: new BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: new Text("${bulletList[list].text}"),
                      );
                    },
                  );
                  break;
                default:
                  String href;
                  snapshot.data[index].children.forEach((f) {
                    href = scrape.splitter(f);
                  });
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
                  break;
              }
            },
          );
        }
    }
  }

  Widget _debug(List<doc.Element> data) {
    return new ListView.builder(
      itemCount: data.length,
      itemBuilder: (contxt, int index) {
        return new Text("data: ${data[index].innerHtml}");
      },
    );
  }

// MARK: Opens embeded urls if any
  _checkLaunch(String urlScheme) async {
    if (await canLaunch(urlScheme)) {
      await launch(urlScheme);
    } else {
      if (urlScheme.contains('//')) {
        var somethingBack = urlScheme.replaceFirst('//', 'https:');
        _checkLaunch(somethingBack);
      } else {
        // TODO: Add dialog window
        throw 'invalid urlSceme: $urlScheme';
      }
    }
  }
}
