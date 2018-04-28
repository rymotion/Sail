import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_web_view/flutter_web_view.dart';
import 'home.dart';
import 'calendar.dart';

// final MainDrawer _drawer = new MainDrawer();

class WebPage extends StatefulWidget {

  @override
  _WebPageState createState() => new _WebPageState();
}

class _WebPageState extends State<WebPage> {
  var currentPage = ' ';
  String _redirect;
  FlutterWebView flutterWebViewer = new FlutterWebView();
  bool _isLoading = false;

  @override
  void initState() {
      // TODO: implement initState
      super.initState();
  }

  @override
  Widget build(BuildContext context){
    Widget leading;
    if (_isLoading) {
      leading = new CircularProgressIndicator();
    }
    var columnItems = <Widget> [
      new MaterialButton(
        onPressed: launchWebViewExample,
        child: new Text("Launch"),
      ),
    ];
    var app = new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          leading: leading,
        ),
        body: new Column(
          children: columnItems,
        ),
      ),
    );
    return app;
  }

  void reload(){
    flutterWebViewer.load( "www.csusb.edu/sail",
        headers: {
          "X-SOME-HEADER": "MyCustomHeader",
        },
    );
  }

  void launchWebViewExample(){
    if (flutterWebViewer.isLaunched){
      return;
    }

    flutterWebViewer.launch("www.csusb.edu/sail",
    headers: {
      "X-SOME-HEADER": "MyCustomHeader",
    },
    javaScriptEnabled: true,
    toolbarActions: [
      new ToolbarAction("Dismiss", 1),
      new ToolbarAction("Reload", 2)
    ],
    barColor: Color.lerp(Colors.blue, Colors.blueGrey, 50.0),
    tintColor: Colors.white
    );
    flutterWebViewer.onToolbarAction.listen( (identifier) {
        switch (identifier) {
          case 1:
            flutterWebViewer.dismiss();
            break;
          case 2:
            reload();
            break;
    }
    });

    flutterWebViewer.listenForRedirect("mobile://test.com", true);
    flutterWebViewer.onWebViewDidStartLoading.listen((url){
      setState(() => _isLoading = true);
    });
    flutterWebViewer.onWebViewDidLoad.listen((url) {
      setState(() => _isLoading = false);
    });
    flutterWebViewer.onRedirect.listen((url) {
      flutterWebViewer.dismiss();
      setState(() => _redirect = url);
    });
  }
}
