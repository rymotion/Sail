// import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as doc;
import 'dart:async';
import '../Scrape.dart';
import 'package:url_launcher/url_launcher.dart';

List list = new List();
Scrape scrape = new Scrape.setLoad("/sail/meet-sail-staff");

class ContactPage extends StatefulWidget {
  // Scrape dataContext = new Scrape();

//  Widget child;

  ContactPage();
  // static _ContactPageState of(BuildContext context) {
  //   return (context.inheritFromWidgetOfExactType(HomeInhertied)
  //           as HomeInhertied)
  //       .myGenErState;
  // }

  @override
  _ContactPageState createState() => new _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
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
                // new Expanded(child: _buildMainContact()),
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

  Widget _buildMainContact() {
    return new FutureBuilder(
      future: scrape.getContactMain,
      builder: (context, AsyncSnapshot<List<doc.Element>> snapshot) {
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
                    href = scrape.splitter(f);
                  });
                  return new Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      new RichText(
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
                    ],
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

// MARK: Build table of data
  Widget _buildTable() {
    _grabObjects();
    return new FutureBuilder(
      future: scrape.grabContact,
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
    data = data.where((value) => value.text != null).toList();
    return new ListView.builder(
      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: data.length,
      itemBuilder: (context, int index) {
        String href;
        href = scrape.splitter(data[index]);
        print("data size: ${data.length}");
        print("incoming data: ${data[index].hasChildNodes()}");

        if (data[index].children.length == 1 &&
            data[index].children.first.toString() == "<html div>") {
//          return new Text("one child div");
          return _profileImage(data[index].children.first);
        } else {
          return data[index].hasChildNodes()
              ? _formattedContact(data[index].children, data[index])
              : new Text(
                  '',
                );
        }
      },
    );
  }

  Widget _formattedContact(List<doc.Element> child, doc.Element parent) {
    ContactData contactData = new ContactData();
//    child = child.where((value) => value != "null").toList();
    for (var tagType in child) {
      if (tagType.text == null) {
        child.remove(tagType);
      } else {
        switch (tagType.toString()) {
          case "<html b>":
            contactData.profileName = tagType?.text ?? null;
            break;
          // case "<html br>":
          //   contactData.title = tagType.outerHtml;
          //   break;
          case "<html strong>":
            contactData.profileName = tagType?.text ?? null;
            break;
          case "<html a>":
            contactData.emailURL = tagType?.attributes["href"] ?? null;
            contactData.eName = tagType?.text ?? null;
            break;
          case "<html p>":
            if (tagType.text != " " || tagType.text != null) {
              child.remove(tagType);
            }
            break;

          // case "<html br>":
          //   contactData.title = tagType.text;
          // break;
          default:
            contactData.title = parent.text;
            break;
        }
      }
    }
    String href;

    if (contactData?.name != null) {
      return new GestureDetector(
        onTap: () {
          _checkLaunch(contactData.emailURL);
        },
        child: new Container(
          decoration: new BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color.fromARGB(100, 0, 0, 0),
                width: 1.5,
              ),
              borderRadius: new BorderRadius.circular(10.0)),
          padding: const EdgeInsets.all(20.0),
          child: new Column(
            children: <Widget>[
              // Name
              new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  text: '${contactData.name}',
                  style: new TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              // Office
              new RichText(
                textAlign: TextAlign.start,
                text: new TextSpan(
                  // text: '${contactData.officeTitle}',
                  text: (contactData.officeTitle != null)
                      ? '${contactData.officeTitle.replaceAll(contactData.name, "").replaceAll(contactData.emailLabel, "")}'
                      : "",
                  style: new TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal),
                ),
              ),
              // Contact
              new Row(
                children: <Widget>[
                  new Icon(
                    Icons.mail_outline,
                    color: Colors.blue,
                  ),
                  new RichText(
                    textAlign: TextAlign.start,
                    text: new TextSpan(
                      text: '${contactData.emailLabel}',
                      style: new TextStyle(
                          color: Colors.blue,
                          fontSize: 15.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return new Divider();
    }
  }

  String parseTitle(String parseTitle) {
    // return parseTitle.replaceAll(, "")
  }

  Widget _profileImage(doc.Element data) {
    var profileURL =
        data.children.first.children.first.attributes["src"].toString();
//    return new Image.network(src)
    if (profileURL == "null") {
      String href;
      return new Container(
        height: 500.0,
        width: MediaQuery.of(context).size.width,
        decoration: new BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Color.fromARGB(100, 0, 0, 0),
              width: 1.5,
            ),
            borderRadius: new BorderRadius.circular(10.0)),
        padding: const EdgeInsets.all(20.0),
        //TODO: load in the contact details of SAIL
        child: new GestureDetector(
          onTap: () {},
          child: new FutureBuilder(
            future: scrape.getContactMain,
            builder: (BuildContext context,
                AsyncSnapshot<List<doc.Element>> programContact) {
              switch (programContact.connectionState) {
                case ConnectionState.none:
                  return new Column(
                    children: <Widget>[
                      new Icon(
                          Icons.signal_cellular_connected_no_internet_4_bar,
                          color: Colors.black),
                      new Text(
                          "Please check your connection settings then refresh this page.")
                    ],
                  );
                  break;

                case ConnectionState.done:
                  if (programContact.hasData) {
                    return new ListView.builder(
                      itemCount: programContact.data.length,
                      itemBuilder: (context, int index) {
                        return new Expanded(
                          child: new Text(
                              "${programContact.data[index].outerHtml}"),
                        );
                      },
                    );
                  } else {
                    return new Column(
                      children: <Widget>[
                        new Icon(Icons.error_outline, color: Colors.black),
                        new Text("Something went wrong. Please try again.")
                      ],
                    );
                  }
                  break;
                default:
                  return new Column(
                    children: <Widget>[
                      new CircularProgressIndicator(),
                    ],
                  );
                  break;
              }
            },
          ),
        ),
      );
    } else {
      return new Image.network(
        "$profileURL",
        height: 100.0,
        width: 100.0,
      );
    }
//    return new Text('${data.children.first.children.first.attributes["src"].toString()}');
  }

// MARK: Gets data in body of webpage
  Widget _pageData(doc.Element data) {
    for (var internalData in data.getElementsByClassName("content")) {
      return new Text("${internalData.toString()} : ${internalData.outerHtml}");
    }
    return new Text('data');
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
        // _callError();
      }
    }
    // launch(urlScheme);
  }
}
