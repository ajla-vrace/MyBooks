import 'package:mybooks_mobile/models/znacka.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class ZnackaProvider extends BaseProvider<Znacka> {
  ZnackaProvider(): super("Znacka");

   @override
  Znacka fromJson(data) {
    // TODO: implement fromJson
    return Znacka.fromJson(data);
  }
}