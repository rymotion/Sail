import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../CalDevParse.dart';
import 'package:googleapis/calendar/v3.dart';
import '../pages/detailScreen.dart';

final CalDevParse calendarHandler = new CalDevParse();

class EventsCalendar extends StatefulWidget {
  @override
  _EventCalState createState() => new _EventCalState();
}

class _EventCalState extends State<EventsCalendar> {
  Events listOfEvents;
  Future<Events> list;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
  }

  load() async {
    try {
      listOfEvents = await calendarHandler.eventList;
      listOfEvents.items.forEach((f) {
        print(f.toJson());
      });

      // setState(() {
      //     list = list;
      // });
    } catch (e) {
      print('caught in catch: $e');
    }
    // makeHead();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Events loadHandle() {
    Events events = new Events();
    events.items.single.summary = "There are no upcoming events";
    events.items.single.start.dateTime = new DateTime.now();
    events.items.single.organizer.displayName = "None";
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Sail Events'),
      ),
      body: new SafeArea(
        child: new ListView(
          // mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.max,
          
          children: <Widget>[
            new Container(
              height: 25.0,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20.0),
              child: new Text(
                'Upcoming Events:',
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 25.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            new Container(
              height: 300.0,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20.0),
              child: _buildFutureContext(calendarHandler.eventList),
            ),
            new Divider(),
            new Container(
              height: 25.0,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20.0),
              child: new Text(
                'Past Events:',
                style: TextStyle(
                  color: Color.fromRGBO(0, 0, 0, 25.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            new Container(
              height: 300.0,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(20.0),
              child: _buildPastContext(calendarHandler.pastEvent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureContext(Future<Events> data) {
    load();
    print('Hit build at event Row.');
    return new FutureBuilder(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<Events> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // produce Error
            break;
          case ConnectionState.waiting:
            return new Container(
              height: 100.0,
              width: 100.0,
              child: CircularProgressIndicator(),
            );
            break;
          default:
            if (snapshot.hasError) {
              print('Snapshot Error: ${snapshot.error.toString()}');
            } else {
              if (snapshot.data.items.length != 0) {
                return _buildCalendarCard(context, snapshot.data.items);
              } else {
                print("no events.");
                return new RichText(
                  text: new TextSpan(text: "There are no upcoming events."),
                  overflow: TextOverflow.fade,
                );
              }
            }
        }
      },
    );
  }

  Widget _buildPastContext(Future<Events> data) {
    load();
    print('Hit build at event Row.');
    return new FutureBuilder(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<Events> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // produce Error
            break;
          case ConnectionState.waiting:
            return new Container(
              height: 100.0,
              width: 100.0,
              child: CircularProgressIndicator(),
            );
            break;
          default:
            if (snapshot.hasError) {
              print('Snapshot Error: ${snapshot.error.toString()}');
            } else {
              if (snapshot.data.items.length != 0) {
                
                return _buildCalendarCard(context, snapshot.data.items.reversed.toList());
              } else {
                print("no events.");
                return new RichText(
                  text: new TextSpan(text: "There are no upcoming events."),
                  overflow: TextOverflow.fade,
                );
              }
            }
        }
      },
    );
  }
  Widget _buildCalendarCard(BuildContext context, List<Event> data) {
    // Events events = data.data as Events;
    if (data != null) {
      return new ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, int index) {
          return new GestureDetector(
            onTap: () {
              // Navigator.push(
              //     context,
              //     new MaterialPageRoute(
              //         builder: (context) =>
              //             new DetailScreen(events.items[index])));
              showModalBottomSheet(context: context, builder: (context) => new DetailScreen(data[index]));
            },
            child: new Column(
              children: <Widget>[
                timetoText(data[index].start.dateTime),
                new ListTile(
                  title: new Text(
                    data[index].summary,
                  ),
                ),
                new Divider(),
              ],
            ),
          );
        },
      );
    } else {
      return new Container(
        height: 100.0,
        width: 100.0,
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget timetoText(DateTime dateTime) {
    String month;
    switch (dateTime.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
      default:
        break;
    }

    return new Text(
      '$month ${dateTime.day}, ${dateTime.year}',
      textAlign: TextAlign.start,
    );
  }

  Widget getUpcomingEvents(Event data) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new DetailScreen(data)));
      },
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(data.summary),
          ),
          new Divider(),
        ],
      ),
    );
  }

  Widget getCurrentlyHappening(Event data) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new DetailScreen(data)));
      },
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(data.summary),
          ),
          new Divider(),
        ],
      ),
    );
  }

  Widget getPastEvents(Event data) {
    return new GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new DetailScreen(data)));
      },
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(data.summary),
          ),
          new Divider(),
        ],
      ),
    );
  }
}