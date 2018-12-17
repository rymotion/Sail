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

  String check(Events data) {
    return data.items.isNotEmpty
        ? "The Harbor is in use"
        : "The Harbor is open";
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
        title: new Text('Sail Harbor'),
      ),
      body: new SafeArea(
        child: new RefreshIndicator(
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
                      return Column(
                        children: <Widget>[
                          new RichText(
                            textAlign: TextAlign.center,
                            text: new TextSpan(
                              text: "${check(snapshot.data)}",
                              style: TextStyle(
                                  color: setColor(snapshot.data),
                                  fontSize:
                                      MediaQuery.textScaleFactorOf(context) *
                                          50,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Divider(),
                          new Container(
                            padding: const EdgeInsets.all(10.0),
                            child: _loadCalendar(snapshot.data),
                          ),
                        ],
                      );
                      break;
                  }
                },
              ),
            ),
            onRefresh: _handleRefresh),
      ),
    );
  }

  Widget _loadCalendar(Events data) {
    print('size: ${data.items.length}');
    // return new Text('size: ${data.items.length}');
    return data.items.length == 0
        ? new Text(
            'Open Harbor Hours\nSo please come in.',
            style: new TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            textScaleFactor: MediaQuery.of(context).textScaleFactor * 2,
          )
        : new ListView.builder(
          itemCount: data.items.length,
          itemBuilder: (context, int index){
            return new GestureDetector(
              onTap: (){
              showModalBottomSheet(context: context, builder: (context) => new DetailScreen(data.items[index]));
              },
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(data.items[index].summary),
                  ),
                ],
              ),
            );
          },
        );
    // new Text(
    //                           'Current daily schedule for the harbor.',
    //                           style: new TextStyle(
    //                             fontWeight: FontWeight.bold,
    //                             color: const Color.fromRGBO(0, 0, 0, 100.0),
    //                           ),
    //                           textAlign: TextAlign.center,
    //                         ),
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
