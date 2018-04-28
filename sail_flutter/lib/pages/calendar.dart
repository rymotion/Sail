import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './home.dart';
import '../main.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => new _CalendarState();
}

class _CalendarState extends State<Calendar> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
    => new Scaffold(
      body: new GridView.count(
        crossAxisCount: 30,
        children: new List.generate(30, (index){
          return new Center(
            child: new Text('Item $index',
            style: Theme.of(context).textTheme.headline,
            ),
          );
        })
      ),
    );

}