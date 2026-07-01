import 'package:mybooks_mobile/models/zanr.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class ZanrProvider extends BaseProvider<Zanr> {
  ZanrProvider(): super("Zanr");

   @override
  Zanr fromJson(data) {
    // TODO: implement fromJson
    return Zanr.fromJson(data);
  }
}