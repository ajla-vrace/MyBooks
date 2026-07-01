import 'package:json_annotation/json_annotation.dart';
import 'package:mybooks_mobile/models/knjiga.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'wish_knjiga.g.dart';

@JsonSerializable()
class WishKnjiga {
  int? id;
  String? naslov;
  String? autor;
  String? napomena;
  String? prioritet;
   String? slika;
  
  WishKnjiga(this.id, this.naslov, this.autor,this.napomena, this.prioritet,this.slika);

    /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory WishKnjiga.fromJson(Map<String, dynamic> json) => _$WishKnjigaFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$WishKnjigaToJson(this);
}
