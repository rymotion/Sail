import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis/calendar/v3.dart';
import '../CalDevParse.dart';

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
    load();
    super.initState();
  }

  load() async {
    await calendarHandler.roomAvailable.then((Events x) async {
      setState(() {
        listOfEvents = x;
        isOpen = x.items.isEmpty;
      });
    }).catchError((onError) => debugPrint('Error:\n$onError'));
  }

  String check() {
    return isOpen ? "The Harbor is in use" : "The Harbor is open";
  }

  Color setColor() {
    return isOpen
        ? const Color.fromRGBO(100, 0, 0, 100.0)
        : const Color.fromRGBO(0, 100, 0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Sail Harbor'),
      ),
      body: new SafeArea(
        child: new ListView(
          children: <Widget>[
            // This text widget will be a function call to see if open
            new RefreshIndicator(
                child: new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new FutureBuilder(
                    future: calendarHandler.roomAvailable,
                    builder:
                        (BuildContext context, AsyncSnapshot<Events> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.active:
                          return new Container(
                            height: 100.0,
                            width: 100.0,
                            child: CircularProgressIndicator(),
                          );
                          break;
                        case ConnectionState.waiting:
                          return new Container(
                            height: 100.0,
                            width: 100.0,
                            child: CircularProgressIndicator(),
                          );
                          break;
                        case ConnectionState.none:
                          print("Error");
                          break;
                        case ConnectionState.done:
                          setState() {
                            isOpen = snapshot.data.items.isEmpty;
                          };
                          return new Text("${check()}");
                          break;
                      }
                    },

                  ),
                ),
                onRefresh: _handleRefresh),

            new Divider(),

            new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Text(
                'Current daily schedule for the harbor.',
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(0, 0, 0, 100.0),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _handleRefresh() async {
    load();

    Completer<Null> completer = new Completer<Null>();
    completer.complete();

    new Future.delayed(new Duration(seconds: 5)).then((_) {
      completer.complete();
    });

    return completer.future;
  }
}
