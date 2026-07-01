import 'package:mybooks_mobile/models/citat.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class CitatProvider extends BaseProvider<Citat> {
  CitatProvider(): super("Citat");

   @override
  Citat fromJson(data) {
    // TODO: implement fromJson
    return Citat.fromJson(data);
  }
}