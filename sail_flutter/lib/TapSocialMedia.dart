import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/parser_console.dart';
import 'package:html/dom.dart';

http.IOClient ioClient = new http.IOClient();
final String client_ID = "7b9fc94210cf435b9c11d38c02b670ed";
final String instagramEndpoint = "https://www.instagram.com/sail_csusb/";

class TapData {
  Future <List<Element>> fetchData() async {
    http.Response responseMeta = await http.get(instagramEndpoint);
    return interpret(responseMeta);
  }
  List<Element> interpret(http.Response response){
    Document pageDocument = parse(response.body);

    return pageDocument.children.last.getElementsByClassName("SCxLW o64aR");
    // return response.body;
  }

  // List<Element> media(Document data) {
  //   data.getElementsByTagName("article").forEach((f){
  //     f.getElementsByClassName("Nnq7C weEfm")
  //   });
  // }

  // List<Element> filter

  List<String> stackedPosts(List<Element> toProcess) {
    List<String> post = new List<String>();

    return post;
  }

  String singlePost(Element post){
    return post.attributes["href"];
  }
}