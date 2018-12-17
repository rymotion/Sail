import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/parser_console.dart';
import 'package:html/dom.dart';
import 'dart:io';

http.IOClient ioClient = new http.IOClient();
String header = '';
String body = '';
Document document;
final String baseURL = 'http://www.csusb.edu';

//MARK:
class ElementFormatter {
  String elementHeader;
  String elementURL;
  String elementAccessible;

  ElementFormatter({
    this.elementHeader, this.elementURL, this.elementAccessible
  });

  String get grabHeader => elementHeader;
  String get grabURL => elementHeader;
  String get grabAccess => elementAccessible;
}

class PageFormatter {
  String header;
  String subtitle;
  List<Element> pageBody;
  List<TableFormatter> table;

  PageFormatter({
    this.header, this.subtitle, this.pageBody, this.table
  });

  String get grabHeader => header;
  String get grabSubtitle => subtitle;
  List<Element> get grabPage => pageBody;
  List<TableFormatter> get grabTable => table;
}

class ContactData {
  String profileURL;
  String profileName;
  String emailURL;
  String title;
  String eName;

  ContactData({
    this.profileName,
    this.emailURL,
    this.profileURL,
    this.title,
    this.eName
//    this.subtitle
  });

  String get name => profileName;
  String get headshotURL => profileURL;
  String get email => emailURL;
  String get emailLabel => eName;
  String get officeTitle => title;
}

class TableFormatter {
  String courseTitle;
  String lecturer;
  String courseSection;
  String catalogNum;
  String daySched;
  String dateTime;
  String roomCall;

  TableFormatter({
      this.courseTitle,
      this.lecturer,
      this.courseSection,
      this.catalogNum,
      this.daySched,
      this.dateTime,
      this.roomCall
  });

  String get courseHead => courseTitle;
  String get lecName => lecturer;
  String get courSec => courseSection;
  String get catNum => catalogNum;
  String get days => daySched;
  String get timeSche => dateTime;
  String get roomLoc => roomCall;
}

class Scrape {
  List<TableFormatter> table = new List();
  String lastUsed;
  String url = '/sail';
  String loadingURL;

  Scrape() {
    // set extention url based on instantiation
    loadingURL = baseURL + url;
    print('from Scrape:\n $loadingURL');
  }

  Scrape.setLoad(String url) {
    lastUsed = baseURL;
    loadingURL = baseURL + url;
    print('from Scrape:\n $loadingURL');
  }

  Future<bool> get canAccess => _access();
  Future<String> get getHeader => _parseHeader();
  Future<List<Element>> get getBody => _parseBody();
  // Future<List<List<TableFormatter>>> get getTable => _tableParse();
  Future<List<ElementFormatter>> get getNavigation => _navMenuGeneration();
  Future<List<String>> get getLinks => _parseLinks();
  Future<String> get getImages => _parseImages();
  Future<List<Element>> get getContactMain => _getContact();
  Future<List> get _internalHeader => _parseBodyHeader();
  Future<List> get sideMenu => _getSideBar();
  Future<List<Element>> get getPage => _pageElements();
  Future<List<Element>> get grabContact => _contactList();
  // String get href() => _splitter(toSplit);
//  MARK: Makes sure that site is accessible.
  Future<bool> _access() async {
    useConsole();
    document = await _getWebResponse();
    if (document != null) {
      return true;
    }
    return false;
  }

// MARK: Web scraping code
  Future<Document> _getWebResponse() async {
    try {
      http.Response response = await http.get(loadingURL);
      if (response.body.isNotEmpty) {
//        print('This is the webresponse:\n${response.body.split('\n')}');
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
  Future<String> _parseHeader() async {
    document = await _getWebResponse();
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

  Future<List<Element>> _getContact() async {
    document = await _getWebResponse();
    List<Element> contact = new List();
    try {
      for (var contactList in document.getElementsByClassName(
          "entity entity-bean bean-csusb-bb-contact-block clearfix")) {
        contactList.getElementsByTagName('p').forEach((f) {
          contact.add(f);
          print('${f.text}');
        });
      }
      return contact;
    } catch (e) {
      print("Exception thrown: ${e.toString()}");
    }

  }

  List<TableFormatter> _tableParse(Element tableData) {
    List<TableFormatter> tempList = new List<TableFormatter>();
    try {
      for (var tableElements in tableData.getElementsByTagName('table')) {
        tableElements.getElementsByTagName('tbody').forEach((f){
          f.getElementsByTagName('tr').forEach((x){
          // MARK: table for course table
          print("table:\n ${x.getElementsByTagName('td')[0].text};\n ${x.getElementsByTagName('td')[1].text};\n ${x.getElementsByTagName('td')[2].text};\n ${x.getElementsByTagName('td')[3].text};\n ${x.getElementsByTagName('td')[4].text};\n ${x.getElementsByTagName('td')[5].text};\n ${x.getElementsByTagName('td')[6].text}");
            tempList.add(new TableFormatter(
              courseTitle: x.getElementsByTagName('td')[0].text,
              lecturer: x.getElementsByTagName('td')[1].text,
              courseSection: x.getElementsByTagName('td')[2].text,
              catalogNum: x.getElementsByTagName('td')[3].text,
              daySched: x.getElementsByTagName('td')[4].text,
              dateTime: x.getElementsByTagName('td')[5].text,
              roomCall: x.getElementsByTagName('td')[6].text,
            ));
          });
          print("break from loop");
          tempList.add(new TableFormatter(
            courseTitle: "",
            lecturer: "",
            courseSection: "",
            catalogNum: "",
            daySched: "",
            dateTime: "",
            roomCall: "",
          ));
        });
      }
      return tempList;
    } catch (e) {}
  }
// MARK: The headers and pre/post text of each table in view
  List<Element> _tableHeading(Element elementDocument) {
    // document = await _getWebResponse();
    List<Element> elementData = new List<Element>();
    try {
      for (var elementIn in document.getElementsByClassName("region region-content")) {
        for (var headingElements in elementIn.getElementsByClassName('field-item even')) {
          for(var i = 0; i < elementIn.getElementsByClassName('field-item even').length; i++){
            // elementData.add(headingElements.getElementsByTagName('h2')[i]);
            // print("Inner data: ${elementData.last.outerHtml}");
            // headingElements.getElementsByTagName('p')[i].text != "" ? elementData.add(headingElements.getElementsByTagName('p')[i]) : print("No Data for p.");
            // print("Inner data: ${elementData.last.outerHtml}");
            headingElements.getElementsByTagName('center')[i].text != "" ? elementData.add(headingElements.getElementsByTagName('center')[i]) : print("No Data for center.");
            print("Inner data: ${elementData.last.outerHtml}");
            // headingElements.getElementsByTagName('ul')[i].text != "" ? elementData.add(headingElements.getElementsByTagName('ul')[i]) : print("No Data for ul.");
            // print("Inner data: ${elementData.last.outerHtml}");
          }
        }
      }
      return elementData;
    } catch (e) {
      print(e.toString());
    }
  }

// MARK: Gets and returns data for body
  Future<List<Element>> _parseBody() async {
    document = await _getWebResponse();
    List<Element> body = new List();
    try {
      for (var element in document.getElementsByClassName("region region-content")) {
        if (element.getElementsByTagName('table').isNotEmpty) {
          element.querySelector('table').remove();
        } else {
          var previousElement = element.getElementsByTagName('h2').first;
          body.add(element.getElementsByTagName('h2').first);
            print(element.getElementsByClassName('field-item even').length);
            element.getElementsByClassName('field field-name-field-pa-center-content field-type-text-long field-label-hidden').forEach((item){
              // item.firstChild.remove();

              for (var title in item.getElementsByTagName('h2')) {
                print(title.innerHtml);
                previousElement == title ? print('alternate header failed') : body.add(title);
              }
              for (var div in item.getElementsByTagName('p')) {
                print(div.innerHtml);
                body.add(div);
              }
              for (var bullet in item.getElementsByTagName('ul')) {
                print(bullet.innerHtml);
                body.add(bullet);
              }
            });
        }
      }
    } catch (e) {
      print('${e.toString()}');
    }
    return body;
  }

  Future<List> _parseBodyHeader() async {
    document = await _getWebResponse();

    List headList = [];
    document.querySelectorAll("h2").forEach((f) {
      headList.add(f);
      print(f);
    });
    return headList;
  }

// MARK: Gets the link metadata
  Future<List<String>> _parseLinks() async {
    document = await _getWebResponse();
    List<String> links;
    try {
      for (var element in document.querySelectorAll("article")) {
//        print('The is the body element: ${element.text}\n');
        body = element.text;
      }
    } catch (e) {
      print('${e.toString()}');
    }
    return links;
  }

  String splitter(Element toSplit) {
    int matchIndex = 0;
    int startIndex = 0;

    String extract;
    print('Splitter:\n');
    if (toSplit.getElementsByTagName('a').isNotEmpty) {
      toSplit.getElementsByTagName('a').forEach((f) {
        print('not empty');
        var temp = f.outerHtml;
        print("starting String: $temp");
        if (temp.contains("href")) {
          for (var i = 0; i < temp.length; i++) {
            // Find first instance of "
            if ('"' == temp[i] && startIndex == 0) {
//          print('Found beginning instance of " in ${i.toString()}\n');
              i++;
              startIndex = i;
            } else if ('"' == temp[i] && matchIndex == 0) {
//          print('Found ending instance of " in ${i.toString()}\n');
              matchIndex = i;
            }
          }
          // print('in supstring: ${temp.substring(startIndex, matchIndex)}');
          try {
            extract = temp.substring(startIndex, matchIndex);
          } catch (e){
            print("Error thrown here: ${e.toString()}");
          }
        }
      });
    } else if (toSplit.getElementsByClassName('img').isNotEmpty) {
      toSplit.getElementsByTagName('img').forEach((f){
        print('not empty');
        var temp = f.outerHtml;
        print("starting String: $temp");
        if (temp.contains("src")) {
          for (var i = 0; i < temp.length; i++) {
            // Find first instance of "
            if ('"' == temp[i] && startIndex == 0) {
//          print('Found beginning instance of " in ${i.toString()}\n');
              i++;
              startIndex = i;
            } else if ('"' == temp[i] && matchIndex == 0) {
//          print('Found ending instance of " in ${i.toString()}\n');
              matchIndex = i;
            }
          }
          // print('in supstring: ${temp.substring(startIndex, matchIndex)}');
          try {
            extract = temp.substring(startIndex, matchIndex);
          } catch (e){
            print("Error thrown here: ${e.toString()}");
          }
        }
      });
    }
    print(extract);
    return extract;
  }

  Future<List<ElementFormatter>> _navMenuGeneration() async {
    document = await _getWebResponse();
    var navMenu = new List<ElementFormatter>();
//    print('Nav Menu:\n');
    try {
      for (var element in document.getElementsByClassName(
          "menu-block-wrapper menu-block-249 menu-name-menu-sail-student-assistance-in- parent-mlid-0 menu-level-2")) {
        for (var check in element.nodes) {
          print('Node: ${check.children.toString()}');
          for (var internal in check.children) {
            print(internal.innerHtml);
            navMenu.add(ElementFormatter(
              elementAccessible: '',
              elementHeader: internal.text,
              elementURL: splitter(internal),
            ));
          }
        }
      }
    } catch (e) {
      print('${e.toString()}');
    }

    return navMenu;
  }

Future <List> _getSideBar() async{
  document = await _getWebResponse();
  try{
    print('sidebar navigation menu');
    document.getElementsByTagName('ul').forEach((f){
      for (var items in document.getElementsByClassName('manu nav')) {
      print('${items.innerHtml}');
    }
    });
  } catch (e){
    print('${e.toString()}');
  }
}

// MARK: Gets and picture metadata

  Future <String> _parseImages() async {
    document = await _getWebResponse();
    String images;

    return images;
  }

  Future <List<Element>> _pageElements() async {
    document = await _getWebResponse();
    List<Element> currentPage = new List<Element>();
    try{
      for (var elements in document.getElementsByClassName("region region-content")) {
        for (var items in elements.getElementsByClassName("field field-name-field-pa-center-content field-type-text-long field-label-hidden")){
          for (var data in items.getElementsByClassName("field-item even")){
            data.children.forEach((f){
              f.children.forEach((x){
                currentPage.add(x);
              });
            });
          }
        }
      }
      return currentPage;
    } catch (e){
      print('${e.toString()}');
    }
  }

  Future<List<Element>> _contactList() async {
    document = await _getWebResponse();
    List<Element> listedContact = new List<Element>();
    List<ContactData> contactData = new List<ContactData>();
    ContactData person = new ContactData();
    try{
      for (var elements in document.getElementsByClassName("region region-content")) {
        for (var items in elements.getElementsByClassName("field-items")){
          for (var node in items.getElementsByClassName("field field-name-field-pa-center-content field-type-text-long field-label-hidden")) {

            print("item from internal nodes: ${node.toString()}\n${node.innerHtml}");
            
            listedContact.add(node);

            break;
          }
        }
      }
      // traverses from start of page again
      for (var elements in document.getElementsByClassName("region region-content")) {
        // print(elements.attributes["field-items"].toString());
        for (var items in elements.getElementsByClassName("ds-3col-equal entity entity-paragraphs-item paragraphs-item-three-columns view-mode-full clearfix")){
          for (var nodes in items.getElementsByClassName("field-items")) {

            print("item from left nodes: ${nodes.toString()}\n${nodes.innerHtml}");
            // _findContent(leftNode.children);
            listedContact.addAll(_findContent(nodes.children));

          }
        }
      }
    } catch (e){
      print('${e.toString()}');
    }

    return listedContact;
  }

  // recursive function to find nested content within <html div>
  List<Element> _findContent(List<Element> nestContent){
    List<Element> foundElement = new List<Element>();
    for(var content in nestContent){
      print("children: ${nestContent.toString()}");
      if (content.hasChildNodes()) {
        return _findContent(content.children);
      } else {
        // print("node Content:" + content?.text ?? "no Content");
        // if (content?.text == null) {
        //   nestContent.remove(content);
        // } else {
        //   foundElement.add(content);
        // }
        foundElement.addAll(nestContent);
//        foundElement.add(content);
        print("hits return. current running size: ${foundElement.length}");
        return foundElement;
      }
    }
    print("broke out of loop");
    return foundElement;
  }
}

class NavItem {
  final String urlString;
  final String headerString;

  const NavItem({this.urlString, this.headerString});
}
