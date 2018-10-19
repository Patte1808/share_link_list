import 'package:html/dom.dart';
import 'dart:async';
import '../database/share_provider.dart';
import 'dart:io';
import 'dart:convert';

class OGParser {

  var _keys = [
    "og:title",
    "og:type",
    "og:url",
    "og:image",
    "og:audio",
    "og:description",
    "og:determiner",
    "og:locale",
    "og:locale:alternate",
    "og:site_name",
    "og:video",
    "og:image:url",
    "og:image:secure_url",
    "og:image:type",
    "og:image:width",
    "og:image:height",
    "og:image:alt",
  ];

  Future getOgTags(String url) async {
    var httpClient = HttpClient();
    var json = await httpClient.getUrl(Uri.parse(url)).then((request) => request.close())
    .then((response) async {
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(Utf8Decoder()).join();
        var doc = Document.html(json);
        return Future.value(_processHeaderInformation(doc.head));
      }
    });

    return json;
  }

  _processHeaderInformation(Element head) {
    var json = Map<String, dynamic>();
    var metaTags = head.children.where((element) => element.localName == "meta" && _keys.contains(element.attributes.values.first));

    metaTags.forEach((tag) {
      json[tag.attributes.values.first.replaceAll("og:", "")] = tag.attributes.values.last;
    });

    return json;
  }
}