import 'package:json_annotation/json_annotation.dart';

part 'statistika.g.dart';

@JsonSerializable()
class Statistika {
  int? ukupnoKnjiga;
  double? prosjecnaOcjena;

  List<KnjigePoMjesecu>? knjigePoMjesecima;
  List<TopZanr>? topZanrovi;

  Statistika(
    this.ukupnoKnjiga,
    this.prosjecnaOcjena,
    this.knjigePoMjesecima,
    this.topZanrovi,
  );

  factory Statistika.fromJson(Map<String, dynamic> json) =>
      _$StatistikaFromJson(json);

  Map<String, dynamic> toJson() => _$StatistikaToJson(this);
}

@JsonSerializable()
class KnjigePoMjesecu {
  String? mjesec;
  int? broj;

  KnjigePoMjesecu(this.mjesec, this.broj);

  factory KnjigePoMjesecu.fromJson(Map<String, dynamic> json) =>
      _$KnjigePoMjesecuFromJson(json);

  Map<String, dynamic> toJson() =>
      _$KnjigePoMjesecuToJson(this);
}

@JsonSerializable()
class TopZanr {
  String? naziv;
  int? broj;
  double? postotak;

  TopZanr(
    this.naziv,
    this.broj,
    this.postotak,
  );

  factory TopZanr.fromJson(Map<String, dynamic> json) =>
      _$TopZanrFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TopZanrToJson(this);
}