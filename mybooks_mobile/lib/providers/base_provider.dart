import 'dart:convert';
import 'dart:io';

import 'package:mybooks_mobile/models/search_result.dart';

import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/io_client.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";
  HttpClient client = HttpClient();
  IOClient? http;
  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    print("baseurl $_baseUrl");
   
     _baseUrl = const String.fromEnvironment("baseUrl",
        defaultValue: "https://localhost:7208/");      //ovo radi za probu
    /*  _baseUrl = const String.fromEnvironment("baseUrl",
      defaultValue: "http://192.168.1.7:5208/",);*/  //za mobitel
   /* _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5208/",
    );*/ //ne oov

   /*    _baseUrl = const String.fromEnvironment("baseUrl",
      defaultValue: "http://10.0.2.2:5208/",); */  //emulator ovo

    // defaultValue: "https://10.0.2.2:7208/"); //za emulator
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http!.get(uri, headers: headers);
    // print("response body je ${response.body}");
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.count = data['count'];

      for (var item in data['result']) {
        // print("Item koji se parsira: $item");
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw new Exception("Unknown error");
    }
    //print("response: ${response.request} ${response.statusCode}, ${response.body}");
  }

  Future getById(int id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    Response response = await http!.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);

    print("REQUEST URL: $url");
    print("REQUEST BODY: $jsonRequest");
    print("REQUEST HEADERS: $headers");

    var response = await http!.post(uri, headers: headers, body: jsonRequest);
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      var errorMessage = await _handleErrorResponse(response);
      throw Exception(errorMessage);
    }
  }

  Future<String> _handleErrorResponse(Response response) async {
    var data = jsonDecode(response.body);
    if (response.statusCode == 400 &&
        data['message'] == "Korisničko ime već postoji.") {
      return "Korisničko ime već postoji.";
    } else {
      return "Unknown error: ${data['message']}";
    }
  }

  Future<dynamic> postCustom(String action, dynamic request) async {
    var url = "$_baseUrl$_endpoint/$action";

    var uri = Uri.parse(url);

    var headers = createHeaders();

    var body = jsonEncode(request);

    var response = await http!.post(
      uri,
      headers: headers,
      body: body,
    );

    if (isValidResponse(response)) {
      if (response.body.isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    }

    return null;
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http!.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<bool> delete(int id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    Response response = await http!.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      // Ako je odgovor false, znači nešto nije u redu
      if (data == false) {
        throw Exception("Ne postoji sa datim ID-om.");
      }

      notifyListeners();
      return data; // Vraćamo true ako je uspešno obrisano
    } else {
      throw Exception("Nepoznata greška.");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      print(response.body);
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      throw new Exception("Something bad happened please try again");
    }
  }

  Map<String, String> createHeaders() {
    /*String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";*/
    String username = "proba";
    String password = "proba";
    print("passed creds: $username, $password");

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";
    print("passed creds poslije: $username, $password");
    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };

    return headers;
  }

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }
}
