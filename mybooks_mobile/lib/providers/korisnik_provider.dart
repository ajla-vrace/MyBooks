import 'package:mybooks_mobile/models/korisnik.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnik");

  @override
  Korisnik fromJson(data) {
    // TODO: implement fromJson
    return Korisnik.fromJson(data);
  }

  Future<Korisnik?> login(
    String email,
    String lozinka
) async {

  var response = await postCustom(
    "login",
    {
      "email": email,
      "lozinka": lozinka
    },
  );


  print("LOGIN RESPONSE:");
  print(response);


  if(response != null){
    return Korisnik.fromJson(response);
  }

  return null;
}
}
