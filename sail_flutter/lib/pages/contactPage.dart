import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as doc;
import 'dart:async';
import '../Scrape.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:transparent_image/transparent_image.dart';

List list = new List();
Scrape scrape = new Scrape.setLoad("/sail/meet-sail-staff");
final ScrollController controller = ScrollController();

class ContactPage extends StatefulWidget {
  ContactPage();

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
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                new Container(
                  child: _buildMainContact(),
                ),
                _buildTable(),
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
          case ConnectionState.done:
            if (snapshot.hasData) {
              print("running length: ${snapshot.data.length}");
              return new Container(
                padding: const EdgeInsets.all(20.0),
                child: _contactData(snapshot.data),
              );
            } else if (snapshot.hasError) {
              return new Container(
                padding: const EdgeInsets.all(20.0),
                child: new Text("${snapshot.error}"),
              );
            } else {
              return new Container(
                padding: const EdgeInsets.all(20.0),
                child: new Text("${snapshot.error}\n${snapshot.data}"),
              );
            }
            break;
          default:
            if (snapshot.hasData) {
              return new Container(
                padding: const EdgeInsets.all(20.0),
                child: _contactData(snapshot.data),
              );
            } else if (snapshot.hasError) {
              return new Container(
                padding: const EdgeInsets.all(20.0),
                child: new Text("${snapshot.error}"),
              );
            } else {
              return new Container(
                padding: const EdgeInsets.all(20.0),
                child: new Text("${snapshot.error}\n${snapshot.data}"),
              );
            }
            break;
        }
      },
    );
  }

// MARK: Build table of data
  Widget _buildTable() {
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
            return new SizedBox(
                        child: CircularProgressIndicator(),
                        height: 100.0,
                        width: 100.0,
                      );
            break;
          case ConnectionState.active:
            print('Table connection is active.');
            SizedBox(
                        child: CircularProgressIndicator(),
                        height: 100.0,
                        width: 100.0,
                      );
            break;
          default:
            if (snapshot.hasData) {
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
                          fontSize: MediaQuery.of(context).textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              print('ERROR: ${snapshot.error.toString()}');
            }
        }
      },
    );
  }

  Widget _tableFormatter(List<doc.Element> data) {
    return new GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, int index) {
        String imageURL = "";
        ContactData contactData = new ContactData(
          title: 'test',
        );
        // for (var tagType in data) {
        print(
            "html: ${data[index].toString()}\nattr:${data[index].attributeValueSpans}\n");

        for (var divData in data[index].children) {
          print("divData: ${divData.outerHtml}\n");

          // requiredData = deepData(divData);
          if (divData.getElementsByTagName("img").first?.attributes["alt"] ==
              "SAIL Program Logo") {
            // return new Text('');
            print("caught it");
          } else {
            // print("postParse: ${requiredData.first.outerHtml} $count");
            imageURL =
                divData.getElementsByTagName("img").first?.attributes["src"] ??
                    imageURL;

            print(divData.getElementsByTagName("p").isEmpty);
            divData.getElementsByTagName("p").isEmpty
                ? divData.getElementsByTagName("div").forEach((f) {
                    if (f.hasChildNodes()) {
                      f.children.forEach((x) {
                        switch (x.toString()) {
                          case "<html b>":
                            contactData.profileName = x?.text ?? null;
                            contactData.title = x.outerHtml;
                            break;

                          case "<html strong>":
                            contactData.profileName = x?.text ?? null;
                            contactData.title = x.outerHtml;
                            break;
                          case "<html a>":
                            contactData.emailURL =
                                x?.attributes["href"] ?? null;
                            contactData.eName = x?.text ?? null;
                            break;
                          default:
                            contactData.title = x.text;
                            break;
                        }

                        contactData.title = f.text;
                        print("running text: ${f.text}");
                      });

                      contactData.profileName = contactData?.name ?? "";
                      contactData.title = contactData?.officeTitle ?? "";
                      contactData.eName = contactData?.emailLabel ?? "";
                      contactData.emailURL = contactData?.emailURL ?? "";
                    }
                  })
                : divData.getElementsByTagName("p").forEach((f) {
                    print("${f.innerHtml}");
                    print("${f.children}");
                    print("${f.text}");
                    f.children.forEach((x) {
                      switch (x.toString()) {
                        case "<html b>":
                          contactData.profileName = x?.text ?? null;

                          break;

                        case "<html strong>":
                          contactData.profileName = x?.text ?? null;
                          break;
                        case "<html a>":
                          contactData.emailURL = x?.attributes["href"] ?? null;
                          contactData.eName = x?.text ?? null;
                          break;
                        case "<html p>":
                          if (x.text != "" || x.text.isNotEmpty) {}
                          break;

                        default:
                          contactData.title = x.text;
                          print("default: ${x.text}");
                          break;
                      }
                      contactData.title = f?.text ?? "null";
                    });
                  });
            return _formattedContact(contactData, imageURL);
          }
        }
      },
    );
  }

// TODO: Fix
  Widget _formattedContact(ContactData contactData, String imageURL) {
    String href;

    if (contactData?.name != null) {
      return new GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Scaffold(
                body: SafeArea(
                  child: Column(

                    children: <Widget>[
                      // Image
                      new Image.network(
                        imageURL,
                        alignment: Alignment.topCenter,
                        height: 200.0,
                        width: 200.0,
                        excludeFromSemantics: false,
                        semanticLabel: '${contactData.name}',
                      ),
                      // Name
                      new RichText(
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
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
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        text: new TextSpan(
                          text:
                              '${contactData.title.replaceFirst(contactData.name, "").replaceAll(contactData.emailLabel, "")}',
                          style: new TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      // Contact
                      new MaterialButton(
                        // color: Colors.blueAccent,
                        onPressed: () {
                          _checkLaunch(contactData.email);
                        },
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.mail_outline,
                              color: Colors.blue,
                            ),
                            new RichText(
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
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
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: new Container(
          decoration: new BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color.fromARGB(100, 0, 0, 0),
                width: 1.5,
              ),
              borderRadius: new BorderRadius.circular(10.0)),
          padding: const EdgeInsets.all(5.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisSize: MainAxisSize.,
            children: <Widget>[
              // Image
              new Image.network(
                imageURL,
                alignment: Alignment.topCenter,
                height: 125.0,
                width: 125.0,
                excludeFromSemantics: false,
                semanticLabel: '${contactData.name}',
              ),
              
              // Name
              new Row(
                children: <Widget>[
                  new Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20.0,
                  ),
                  new RichText(
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    text: new TextSpan(
                      text: '${contactData.name}',
                      style: new TextStyle(
                          color: Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
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

  List<doc.Element> deepData(doc.Element data) {
    List<doc.Element> returnedData = new List<doc.Element>();
    switch (data.toString()) {
      case "<html div>":
        for (var child in data.children) {
          return deepData(child);
        }
        break;
      case "<html br>":
        returnedData.add(data);
        break;
      case "<html p>":
        if (data.text == "" || data.text == " ") {
          // Do nothing
          break;
        } else {
          returnedData.add(data);
        }
        break;
      default:
        returnedData.add(data);
        break;
    }
    return returnedData;
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
                        new Icon(
                          Icons.error_outline,
                          color: Colors.black,
                          size: 5.0,
                        ),
                        new Text("Something went wrong. Please try again.")
                      ],
                    );
                  }
                  break;
                default:
                  return new Column(
                    children: <Widget>[
                      SizedBox(
                        child: CircularProgressIndicator(),
                        height: 100.0,
                        width: 100.0,
                      ),
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

// MARK: Gets main office contact data should be six elements
/*
  [0] Location
  [1] Phone
  [2] Fax
  [3] Email
  [4] office hours
  [5] office hours 2
 */
  Widget _contactData(List<doc.Element> data) {
    return new ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, int index) {
        switch (data[index].text.contains("Phone")) {
          case true:
            return new MaterialButton(
              onPressed: () {
                _checkLaunch(data[index]
                    .text
                    .replaceAll("Phone:", "tel:+1 ")
                    .replaceAll("(", "")
                    .replaceAll(")", ""));
                print(data[index].text.replaceAll("Phone", "tel"));
              },
              child: new Row(
                children: <Widget>[
                  new Icon(
                    Icons.phone_in_talk,
                    color: Colors.blue,
                  ),
                  new RichText(
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    text: new TextSpan(
                      text: '${data[index].text}',
                      style: new TextStyle(
                          color: Colors.blue,
                          fontSize: 15.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            );
            break;
          default:
            switch (data[index].getElementsByTagName('a').isNotEmpty) {
              case true:
                return new MaterialButton(
                  // color: Colors.blueAccent,
                  onPressed: () {
                    // data[index].text.replaceAll("Phone", "tel:");
                    _checkLaunch(data[index]
                        .getElementsByTagName('a')
                        .first
                        .attributes["href"]);
                    print(data[index]
                        .getElementsByTagName('a')
                        .first
                        .attributes["href"]);
                  },
                  child: new Row(
                    children: <Widget>[
                      new Icon(
                        Icons.mail_outline,
                        color: Colors.blue,
                      ),
                      new RichText(
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        text: new TextSpan(
                          text: '${data[index].text}',
                          style: new TextStyle(
                              color: Colors.blue,
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ),
                );
                break;
              default:
                return new Container(
                  padding: const EdgeInsets.all(20.0),
                  child: new RichText(
                    textAlign: TextAlign.start,
                    text: new TextSpan(
                      text: '${data[index].text}',
                      style: (new TextStyle(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).textScaleFactor + 15.0,
                          fontWeight: FontWeight.normal)),
                    ),
                  ),
                );
                break;
            }
            break;
        }
      },
      physics: NeverScrollableScrollPhysics(),
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
        _checkLaunch(somethingBack);
      } else if (urlScheme == " " || urlScheme == null) {
        return new SimpleDialog(
          children: <Widget>[
            new Center(
              child: new Container(
                  child: new Text(
                      'The person you are trying to contact might not have an email setup at this time.')),
            )
          ],
        );
      } else {
        // TODO: Add dialog window
        showDialog(
            context: context,
            builder: (context) {
              return new SimpleDialog(
                children: <Widget>[
                  new Center(
                    child: new Container(
                        child: new Text(
                            'You may be missing a required application\nfor $urlScheme')),
                  )
                ],
              );
            });
        throw 'invalid urlSceme: $urlScheme';
        // _callError();
      }
    }
    // launch(urlScheme);
  }
}
