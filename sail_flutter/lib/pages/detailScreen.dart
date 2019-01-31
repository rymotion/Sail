import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  Event data;

  DetailScreen(Event data, {Key key}) : super(key: key) {
    this.data = data;
  }

  State createState() => DetailScreenState();
}

final key = GlobalKey<DetailScreenState>();

class DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SafeArea(
        child: eventDetails(this.widget.data),
      ),
    );
  }

  Widget eventDetails(Event data) {
   
   var dateFormat = new DateFormat('jm');

   String formattedStartDate = dateFormat.format(this.widget.data.start.dateTime.toLocal());

   String formattedEndDate = dateFormat.format(this.widget.data.end.dateTime.toLocal());

    return new Container(
      padding: const EdgeInsets.all(10.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new RichText(
            textAlign: TextAlign.start,
            text: new TextSpan(
              text: '${this.widget.data.summary}',
              style: new TextStyle(
                  color: new Color.fromRGBO(20, 20, 20, 100.0),
                  fontWeight: FontWeight.bold),
            ),
          ),
          new Divider(),
          timetoText(this.widget.data.start.dateTime),
          new Text(
              'Starting at: $formattedStartDate\nEnding at: $formattedEndDate'),
          new Text('Inside: ${this.widget.data.location}'),
        ],
      ),
    );
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

    return new Text('$month ${dateTime.day}, ${dateTime.year}');
  }
}
