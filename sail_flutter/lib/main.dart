import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import './pages/home.dart' as home;

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.lightBlue,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
  platform: TargetPlatform.iOS,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.lightBlue,
  accentColor: Colors.lightBlueAccent,
  platform: TargetPlatform.android,
);

TargetPlatform defaultTargetPlatform;

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(new MaterialApp(
      home: new home.MyHomePage(),
      showSemanticsDebugger: false,
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: false,
    ));
  });
}
