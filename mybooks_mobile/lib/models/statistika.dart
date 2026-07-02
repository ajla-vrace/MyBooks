import 'package:json_annotation/json_annotation.dart';

part 'statistika.g.dart';

@JsonSerializable()
class Statistika {
  int? ukupnoKnjiga;
  double? prosjecnaOcjena;

  List<KnjigePoMjesecu>? knjigePoMjesecima;
  List<TopZanr>? topZanrovi;

  List<TopAutor>? topAutori;
  List<MoodStatistika>? moodStatistika;
  
  Statistika(this.ukupnoKnjiga, this.prosjecnaOcjena, this.knjigePoMjesecima,
      this.topZanrovi, this.topAutori, this.moodStatistika);

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

  Map<String, dynamic> toJson() => _$KnjigePoMjesecuToJson(this);
}

@JsonSerializable()
class MoodStatistika {
  String? mood;
  int? broj;

  MoodStatistika(this.mood, this.broj);

  factory MoodStatistika.fromJson(Map<String, dynamic> json) =>
      _$MoodStatistikaFromJson(json);

  Map<String, dynamic> toJson() => _$MoodStatistikaToJson(this);
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

  Map<String, dynamic> toJson() => _$TopZanrToJson(this);
}

@JsonSerializable()
class TopAutor {
  String? imeAutora;
  int? brojKnjiga;
  double? postotak;

  TopAutor(
    this.imeAutora,
    this.brojKnjiga,
    this.postotak,
  );

  factory TopAutor.fromJson(Map<String, dynamic> json) =>
      _$TopAutorFromJson(json);

  Map<String, dynamic> toJson() => _$TopAutorToJson(this);
} 