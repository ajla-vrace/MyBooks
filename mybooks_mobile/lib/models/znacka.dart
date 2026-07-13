import 'package:json_annotation/json_annotation.dart';

part 'znacka.g.dart';

@JsonSerializable()
class Znacka {

  int id;
  String naziv;
  String? opis;
  String? ikonica;


  Znacka(
    this.id,
    this.naziv,
    this.opis,
    this.ikonica,
  );


  factory Znacka.fromJson(Map<String,dynamic> json)
      => _$ZnackaFromJson(json);


  Map<String,dynamic> toJson()
      => _$ZnackaToJson(this);

}