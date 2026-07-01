// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citat_statistika.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CitatStatistika _$CitatStatistikaFromJson(Map<String, dynamic> json) =>
    CitatStatistika(
      json['dodanoDanas'] as bool?,
      json['trenutniNiz'] as int?,
      json['najduziNiz'] as int?,
      json['tekstCitata'] as String?,
      json['nazivKnjige'] as String?,
      json['brojStranice'] as int?,
      (json['citatiPoDanima'] as List<dynamic>?)
          ?.map((e) => CitatPoDanu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CitatStatistikaToJson(CitatStatistika instance) =>
    <String, dynamic>{
      'dodanoDanas': instance.dodanoDanas,
      'trenutniNiz': instance.trenutniNiz,
      'najduziNiz': instance.najduziNiz,
      'tekstCitata': instance.tekstCitata,
      'nazivKnjige': instance.nazivKnjige,
      'brojStranice': instance.brojStranice,
      'citatiPoDanima': instance.citatiPoDanima,
    };

CitatPoDanu _$CitatPoDanuFromJson(Map<String, dynamic> json) => CitatPoDanu(
      json['datum'] == null ? null : DateTime.parse(json['datum'] as String),
      json['broj'] as int?,
    );

Map<String, dynamic> _$CitatPoDanuToJson(CitatPoDanu instance) =>
    <String, dynamic>{
      'datum': instance.datum?.toIso8601String(),
      'broj': instance.broj,
    };
