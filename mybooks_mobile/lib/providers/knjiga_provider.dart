import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class KnjigaProvider extends BaseProvider<Knjiga> {
  KnjigaProvider(): super("Knjiga");

   @override
  Knjiga fromJson(data) {
    // TODO: implement fromJson
    return Knjiga.fromJson(data);
  }
}