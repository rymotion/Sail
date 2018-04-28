import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/parser_console.dart';
import 'package:html/dom.dart';
import 'dart:io';

http.IOClient ioClient = new http.IOClient();
final String url = 'http://www.csusb.edu/sail';
String header = 'Header';
String body = 'Body';
Document document;

//MARK:
class ElementFormatter {

  String elementHeader;
  String elementURL;
  String elementAccessible;

  ElementFormatter({this.elementHeader,this.elementURL,this.elementAccessible});

  String get grabHeader => elementHeader;
  String get grabURL => elementHeader;
  String get grabAccess => elementAccessible;

}

class Scrape {

  String conCatURL;

  Scrape(this.conCatURL);

  Future <bool> get canAccess => _access();
  Future <String> get getHeader => _parseHeader();
  Future <String> get getBody => _parseBody();
  Future <List<ElementFormatter>> get getNavigation => _navMenuGeneration();
  Future <List<String>> get getLinks => _parseLinks();
  Future <List<Datagram>> get getImages => _parseImages();

//  MARK: Makes sure that site is accessible.
  Future <bool> _access() async {
    useConsole();
    bool timeout = false;
    await _getWebResponse()
        .then((Document responder) {
          document = responder;
          print("inside document");
          for (var element in document.body.children) {
            print("\n${element.outerHtml}\n");
          }
        });

    return timeout;
  }

// MARK: Web scraping code
  Future <Document> _getWebResponse() async {
    try {
      http.Response response = await http.get(url);
      if (response.body.isNotEmpty) {
        print('This is the webresponse:\n${response.body.split('\n')}');
        return parse(response.body);
      } else {
        print("\nNo connection.\n");
      }
      return parse(response.body);
    } catch (e) {
      print('\n${e.toString()}\n');
    }
    return null; // If this somehow returns null then it's probably this.
  }

// MARK: Gets and returns header module
  Future <String> _parseHeader() async {
    try {
      // for (var element in document.querySelectorAll("h2")) {
      //   print('The header on website: ${element.text}\n');
      //   header = element.text;
      // }
      header = document.querySelectorAll("h1").first.text;
    } catch (e) {
      print('${e.toString()}');
    }
    return header;
  }

// MARK: Gets and returns data for body
  Future <String> _parseBody() async {
    try {
      for (var element in document.querySelectorAll("article")) {
        print('The is the body element: ${element.text}\n');
        body = element.text;
      }
    } catch (e) {
      print('${e.toString()}');
    }
    return body;
  }

// MARK: Gets the link metadata
  Future <List<String>> _parseLinks() async {
    List<String> links;
    try {
      for (var element in document.querySelectorAll("article")) {
        print('The is the body element: ${element.text}\n');
        body = element.text;
      }
    } catch (e) {
      print('${e.toString()}');
    }
    return links;
  }

  String _splitter(String toSplit) {
    int matchIndex = 0;
    int startIndex = 0;
    print('Splitter:\n');

    if (toSplit.contains('href')){
      // MARK: i is used to store the initial index of string
      for (var i = 0; i < toSplit.length; i++) {
        // Find first instance of "
        if ('"' == toSplit[i] && startIndex == 0) {
          print('Found beginning instance of " in ${i.toString()}\n');
          i++;
          startIndex = i;
        } else if ('"' == toSplit[i] && matchIndex == 0){
          print('Found ending instance of " in ${i.toString()}\n');
          matchIndex = i;
        }
      }
    }
    toSplit = toSplit.substring(startIndex, matchIndex);
    print("This is the substring: \n$toSplit");
    return toSplit;
  }

  Future <List<ElementFormatter>> _navMenuGeneration() async {
    var navMenu = new List<ElementFormatter>();
    print('Nav Menu:\n');
    try {
      for(var element in document.getElementsByClassName("menu-block-wrapper menu-block-249 menu-name-menu-sail-student-assistance-in- parent-mlid-0 menu-level-2")){
        for (var check in element.nodes){
          for (var internal in check.children){
            var menuElement = new ElementFormatter(
              elementHeader: internal.text,
              elementURL: _splitter(internal.innerHtml),
              elementAccessible: '',
            );          
            print('URL inner:\n\n${_splitter(internal.innerHtml)}\n\n');
            print('Title:\n\n${internal.text}\n\n');

            navMenu.add(menuElement);
          }
        }
      }
    } catch (e) {
      print('${e.toString()}');
    }

    return navMenu;
  }

// MARK: Gets and picture metadata
  Future <List<Datagram>> _parseImages() async {
    List<Datagram> images;
    return images;
  }
}

class NavItem {
  final String urlString;
  final String headerString;

  const NavItem({this.urlString, this.headerString});
}