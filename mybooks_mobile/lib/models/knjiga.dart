import 'package:json_annotation/json_annotation.dart';
import 'package:mybooks_mobile/models/zanr.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'knjiga.g.dart';

@JsonSerializable()
class Knjiga {
  int? id;
  String? naslov;
  String? autor;
  String? opis;
  DateTime? datumKreiranja;
  DateTime? datumPocetka;
  DateTime? datumZavrsetka;
  String? status;
  int? ocjena;
  String? recenzija;
  String? slika;
  bool isFavorite;
  String? mood;
 List<Zanr> zanrovi;
  
  Knjiga(this.id, this.naslov, this.autor,this.opis, this.datumKreiranja,this.datumPocetka, this.datumZavrsetka, this.status,
   this.ocjena, this.recenzija, this.slika,this.isFavorite,this.mood,this.zanrovi );

    /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Knjiga.fromJson(Map<String, dynamic> json) => _$KnjigaFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$KnjigaToJson(this);
}
