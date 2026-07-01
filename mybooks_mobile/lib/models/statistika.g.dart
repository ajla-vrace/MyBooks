// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistika.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statistika _$StatistikaFromJson(Map<String, dynamic> json) => Statistika(
      json['ukupnoKnjiga'] as int?,
      (json['prosjecnaOcjena'] as num?)?.toDouble(),
      (json['knjigePoMjesecima'] as List<dynamic>?)
          ?.map((e) => KnjigePoMjesecu.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['topZanrovi'] as List<dynamic>?)
          ?.map((e) => TopZanr.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StatistikaToJson(Statistika instance) =>
    <String, dynamic>{
      'ukupnoKnjiga': instance.ukupnoKnjiga,
      'prosjecnaOcjena': instance.prosjecnaOcjena,
      'knjigePoMjesecima': instance.knjigePoMjesecima,
      'topZanrovi': instance.topZanrovi,
    };

KnjigePoMjesecu _$KnjigePoMjesecuFromJson(Map<String, dynamic> json) =>
    KnjigePoMjesecu(
      json['mjesec'] as String?,
      json['broj'] as int?,
    );

Map<String, dynamic> _$KnjigePoMjesecuToJson(KnjigePoMjesecu instance) =>
    <String, dynamic>{
      'mjesec': instance.mjesec,
      'broj': instance.broj,
    };

TopZanr _$TopZanrFromJson(Map<String, dynamic> json) => TopZanr(
      json['naziv'] as String?,
      json['broj'] as int?,
      (json['postotak'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TopZanrToJson(TopZanr instance) => <String, dynamic>{
      'naziv': instance.naziv,
      'broj': instance.broj,
      'postotak': instance.postotak,
    };
