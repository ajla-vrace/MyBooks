import 'package:json_annotation/json_annotation.dart';
import 'package:mybooks_mobile/models/knjiga.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'citat.g.dart';

@JsonSerializable()
class Citat {
  int? id;
  int? idKnjiga;
  String? tekstCitata;
  int? brojStranice;
  bool? jeOmiljeni;
  Knjiga? idKnjigaNavigation;
 
  
  Citat(this.id, this.idKnjiga, this.tekstCitata,this.brojStranice, this.jeOmiljeni,this.idKnjigaNavigation);

    /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Citat.fromJson(Map<String, dynamic> json) => _$CitatFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$CitatToJson(this);
}
