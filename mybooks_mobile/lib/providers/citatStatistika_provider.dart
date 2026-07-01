import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:mybooks_mobile/models/citat_statistika.dart';

class CitatStatistikaProvider {
  static const String baseUrl =
      String.fromEnvironment("baseUrl", defaultValue: "https://localhost:7208/");

  final HttpClient client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  late final IOClient http;

  CitatStatistikaProvider() {
    http = IOClient(client);
  }

  Future<CitatStatistika> getStatistika() async {
    var uri = Uri.parse("${baseUrl}Citat/statistika");

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