import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/korisnik_znacka.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class KorisnikZnackaProvider extends BaseProvider<KorisnikZnacka> {
  KorisnikZnackaProvider(): super("KorisnikZnacka");

   @override
  KorisnikZnacka fromJson(data) {
    // TODO: implement fromJson
    return KorisnikZnacka.fromJson(data);
  }
}