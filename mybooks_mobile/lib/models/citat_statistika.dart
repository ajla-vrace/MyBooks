import 'package:json_annotation/json_annotation.dart';

part 'citat_statistika.g.dart';

@JsonSerializable()
class CitatStatistika {
  bool? dodanoDanas;
  int? trenutniNiz;
  int? najduziNiz;
  String? tekstCitata;
  String? nazivKnjige;
  int? brojStranice;

  List<CitatPoDanu>? citatiPoDanima;

  CitatStatistika(
    this.dodanoDanas,
    this.trenutniNiz,
    this.najduziNiz,
    this.tekstCitata,
    this.nazivKnjige,
    this.brojStranice,
    this.citatiPoDanima,
  );

  factory CitatStatistika.fromJson(Map<String, dynamic> json) =>
      _$CitatStatistikaFromJson(json);

  Map<String, dynamic> toJson() => _$CitatStatistikaToJson(this);
}

@JsonSerializable()
class CitatPoDanu {
  DateTime? datum;
  int? broj;

  CitatPoDanu(this.datum, this.broj);

  factory CitatPoDanu.fromJson(Map<String, dynamic> json) =>
      _$CitatPoDanuFromJson(json);

  Map<String, dynamic> toJson() => _$CitatPoDanuToJson(this);
}