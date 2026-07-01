import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'citat_statistika.g.dart';

@JsonSerializable()
class CitatStatistika {
   bool? dodanoDanas;
   int? trenutniNiz;
   int? najduziNiz;
   String? tekstCitata;
   String? nazivKnjige;
   int? brojStranice;
  
  CitatStatistika(this.dodanoDanas,this.trenutniNiz, this.najduziNiz,this.tekstCitata, this.nazivKnjige,this.brojStranice);

    /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory CitatStatistika.fromJson(Map<String, dynamic> json) => _$CitatStatistikaFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$CitatStatistikaToJson(this);
}
