import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:mybooks_mobile/models/statistika.dart';

class StatistikaProvider {
  static String baseUrl =
      const String.fromEnvironment(
        "baseUrl",
        defaultValue: "https://localhost:7208/",
       // defaultValue: "http://192.168.1.7:5208/",  //za mobitel
       // defaultValue: "http://10.0.2.2:5208/",  //za emualtor
      );

  HttpClient client = HttpClient();
  IOClient? http;

  StatistikaProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<Statistika> getStatistika(int korisnikId)async {
 // var uri = Uri.parse("${baseUrl}Statistika");
 //var uri = Uri.parse("${baseUrl}Knjiga/statistika");
 var uri = Uri.parse("${baseUrl}Knjiga/statistika?korisnikId=$korisnikId");
print("uri: $uri");
  String username = "proba";
  String password = "proba";

  String basicAuth =
      "Basic ${base64Encode(utf8.encode('$username:$password'))}";

  var headers = {
    "Content-Type": "application/json",
    "Authorization": basicAuth,
  };

  Response response = await http!.get(uri, headers: headers);

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode < 300) {
    var data = jsonDecode(response.body);
    return Statistika.fromJson(data);
  }

  throw Exception("Greška pri učitavanju statistike");
}
}