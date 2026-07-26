import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:mybooks_mobile/models/citat_statistika.dart';

class CitatStatistikaProvider {
  static const String baseUrl = String.fromEnvironment("baseUrl",
     defaultValue: "https://localhost:7208/");
 //defaultValue: "http://192.168.1.7:5208/");
//  defaultValue: "http://10.0.2.2:5208/"); //za emualtor

  final HttpClient client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  late final IOClient http;

  CitatStatistikaProvider() {
    http = IOClient(client);
  }

  Future<CitatStatistika> getStatistika(int korisnikId) async {
    //var uri = Uri.parse("${baseUrl}Citat/statistika");
    var uri = Uri.parse("${baseUrl}Citat/statistika?korisnikId=$korisnikId");
    String basicAuth = "Basic ${base64Encode(utf8.encode('proba:proba'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    Response response = await http.get(uri, headers: headers);

    if (response.statusCode < 300) {
      return CitatStatistika.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      "Citat statistika error: ${response.statusCode} - ${response.body}",
    );
  }
}
