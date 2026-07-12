import 'dart:convert';
import 'package:http/http.dart';
import 'package:mybooks_mobile/models/wish_knjiga.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class WishKnjigaProvider extends BaseProvider<WishKnjiga> {
  WishKnjigaProvider() : super("WishKnjiga");

  @override
  WishKnjiga fromJson(data) {
    return WishKnjiga.fromJson(data);
  }

  Future<WishKnjiga?> getRandom(int id) async {
    //var url = "https://localhost:7208/WishKnjiga/random";
    var url = "https://localhost:7208/WishKnjiga/random?korisnikId=$id";
   // var url = "${BaseProvider.baseUrl}WishKnjiga/random";

    var uri = Uri.parse(url);
    var headers = createHeaders();

    Response response = await http!.get(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty || response.body == "null") {
        return null;
      }

      var data = jsonDecode(response.body);
      return WishKnjiga.fromJson(data);
    }

    throw Exception("Greška prilikom dohvatanja knjige.");
  }
}