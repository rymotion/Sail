import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';

class ScanID extends StatefulWidget {
  @override
  _ScanIDState createState() => new _ScanIDState();
}

class _ScanIDState extends State<ScanID> {
  String name = "";
  String id = "";

  final TextEditingController _nameEditingController =
      new TextEditingController();
  final TextEditingController _idEditingController =
      new TextEditingController();
  @override
  void initState() {}
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Event Check-In"),
      ),
      body: new SafeArea(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new Expanded(
              child: new Center(
                child: new QrImage(
                    data: "$name $id",
                    onError: (ex) {
                      print("[QR] ERROR - $ex");
                      setState(() {
                        // _inputErrorText = "Error! Maybe your input value is too long?";
                      });
                    }),
              ),
            ),
            new Text('Please hold your phone towards the scanner.'),
            new Container(
              height: MediaQuery.of(context).size.height/4,
              width: MediaQuery.of(context).size.width*0.75,
              child: new Column(
                children: [
                  new Expanded(
                    child: new TextField(
                      decoration: new InputDecoration(hintText: 'Full Name'),
                      controller: _nameEditingController,
                    ),
                  ),
                  new Expanded(
                    child: new TextField(
                      decoration:
                          new InputDecoration(hintText: 'Student ID number'),
                      controller: _idEditingController,
                    ),
                  ),
                ],
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: new FlatButton(
                child: new Text("Submit"),
                onPressed: () {
                  setState(() {
                    name = _nameEditingController.text;
                    id = _idEditingController.text;
                    print("${_nameEditingController.text}");
                    print("${_idEditingController.text}");
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
