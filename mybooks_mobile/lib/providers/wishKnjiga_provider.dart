import 'package:mybooks_mobile/models/wish_knjiga.dart';
import 'package:mybooks_mobile/providers/base_provider.dart';

class WishKnjigaProvider extends BaseProvider<WishKnjiga> {
  WishKnjigaProvider(): super("WishKnjiga");

   @override
  WishKnjiga fromJson(data) {
    // TODO: implement fromJson
    return WishKnjiga.fromJson(data);
  }
}