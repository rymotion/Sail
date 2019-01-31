import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis/calendar/v3.dart';
import '../CalDevParse.dart';
import '../pages/detailScreen.dart';

final CalDevParse calendarHandler = new CalDevParse();

bool isOpen = false;
Color color;

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => new _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Events listOfEvents = new Events();
  List<Event> list = [];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    // load();
    super.initState();
  }

  load() async {
    await calendarHandler.future_Events.then((Events x) async {
      setState(() {
        listOfEvents = x;
        isOpen = x.items.isEmpty;
      });
    }).catchError((onError) => debugPrint('Error:\n$onError'));
  }

  String check(Events data) {
    return data.items.isNotEmpty ? "UNAVAILABLE." : "OPEN. Please come in.";
  }

  Color setColor(Events data) {
    return data.items.isNotEmpty
        ? const Color.fromRGBO(100, 0, 0, 100.0)
        : const Color.fromRGBO(0, 100, 0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('SAIL Harbor'),
      ),
      body: new SafeArea(
        child: new RefreshIndicator(
            child: new Container(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    height: 350.0,
                    child: _isHappeningNow(),
                  ),
                  Divider(),
                  Text("Upcoming Events"),
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      height: 350.0,
                      child: _loadCalendar(calendarHandler.future_Events)),
                  Divider(),
                  Text("Past Events"),
                  Container(
                      padding: const EdgeInsets.all(10.0),
                      height: 200.0,
                      child: _loadCalendar(calendarHandler.past_Events)),
                ],
              ),
            ),
            onRefresh: _handleRefresh),
      ),
    );
  }

  Widget _loadCalendar(Future<Events> data) {
    return new FutureBuilder(
      future: data,
      builder: (context, AsyncSnapshot<Events> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            return new SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(),
            );
            break;
          case ConnectionState.waiting:
            return new SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(),
            );
            break;
          case ConnectionState.none:
            // MARK: Throw error to ask if the user can check their connection
            break;
          default:
            // Program has recieved data from Client Calendar
            switch (snapshot.hasData) {
              case true:
                return new ListView.builder(
                  itemCount: snapshot.data.items.length,
                  itemBuilder: (context, int list) {
                    return new FlatButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) => new DetailScreen(snapshot.data.items[list])
                            );
                      },
                      child: Text("${snapshot.data.items[list].summary}"),
                    );
                  },
                  physics: NeverScrollableScrollPhysics(),
                );
                // return new Text("Test");
                break;
              default:
                return new Container(
                  height: 100.0,
                  child: Text("No events"),
                );
                break;
            }
            break;
        }
      },
    );
  }

  Widget _isHappeningNow() {
    return new FutureBuilder(
      future: calendarHandler.runningCurrEvent,
      builder: (BuildContext context, AsyncSnapshot<Events> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            return new SizedBox(
              child: CircularProgressIndicator(),
              height: 50.0,
              width: 50.0,
            );
            break;
          case ConnectionState.waiting:
            return new SizedBox(
              child: CircularProgressIndicator(),
              height: 50.0,
              width: 50.0,
            );
            break;
          case ConnectionState.none:
            return new SizedBox(
              child: Text("Please check your connection and try again."),
              height: 50.0,
              width: 50.0,
            );
            break;
          case ConnectionState.done:
            // final String failSafe = "There are no events happening now in the Harbor.";
            switch (snapshot.data.items.isNotEmpty) {
              case true:
                return Column(
                  children: <Widget>[
                    new RichText(
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      text: new TextSpan(
                        text: "The Harbor is currently ${check(snapshot.data)}",
                        style: TextStyle(
                            color: setColor(snapshot.data),
                            fontSize:
                                MediaQuery.textScaleFactorOf(context) * 20,
                            fontWeight: FontWeight.bold),
                            
                      ),
                    ),
                    new Text("Happening right now:"),
                    new FlatButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) => new DetailScreen(snapshot.data.items.first));
                      },
                      child: Text("${snapshot.data.items.first.summary}"),
                    ),
                  ],
                );
                break;
              default:
                return Column(
                  children: <Widget>[
                    new RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                        text: "The Harbor is currently ${check(snapshot.data)}",
                        style: TextStyle(
                            color: setColor(snapshot.data),
                            fontSize:
                                MediaQuery.textScaleFactorOf(context) * 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
                break;
            }
            break;
          default:
            return new Text("Uncaught error");
            break;
        }
      },
    );
  }

  Future<Null> _handleRefresh() async {
    // load();

    Completer<Null> completer = new Completer<Null>();
    completer.complete();

    new Future.delayed(new Duration(seconds: 5)).then((_) {
      completer.complete();
    });

    return completer.future;
  }
}
