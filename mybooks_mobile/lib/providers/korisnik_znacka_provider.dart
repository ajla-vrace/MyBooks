/*import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/korisnik_znacka.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class KorisnikZnackaProvider extends BaseProvider<KorisnikZnacka> {
  KorisnikZnackaProvider(): super("KorisnikZnacka");

   @override
  KorisnikZnacka fromJson(data) {
    // TODO: implement fromJson
    return KorisnikZnacka.fromJson(data);
  }
}*/
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:mybooks_mobile/models/korisnik_znacka.dart';
import 'package:mybooks_mobile/models/znacka.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class KorisnikZnackaProvider extends BaseProvider<KorisnikZnacka> {
  KorisnikZnackaProvider() : super("KorisnikZnacka") {
    httpClient = IOClient(client);
  }

  static const String baseUrl = String.fromEnvironment(
    "baseUrl",
    defaultValue: "https://localhost:7208/",
    // defaultValue: "http://localhost:5208/",
   //  defaultValue: "http://10.0.2.2:5208/",
  );

  final HttpClient client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  late final IOClient httpClient;

  /*KorisnikZnackaProvider.init()
      : super("KorisnikZnacka") {
    httpClient = IOClient(client);
  }*/

  @override
  KorisnikZnacka fromJson(data) {
    return KorisnikZnacka.fromJson(data);
  }

  Future<Znacka?> getSljedecaZnacka(int korisnikId) async {
    var uri = Uri.parse("${baseUrl}KorisnikZnacka/sljedeca/$korisnikId");

    String basicAuth = "Basic ${base64Encode(utf8.encode('proba:proba'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    Response response = await httpClient.get(
      uri,
      headers: headers,
    );

    if (response.statusCode < 300) {
      if (response.body.isEmpty) return null;

      return Znacka.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      "Sljedeca znacka error: ${response.statusCode} - ${response.body}",
    );
  }
}
