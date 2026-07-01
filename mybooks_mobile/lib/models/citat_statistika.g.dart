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
    );

Map<String, dynamic> _$CitatStatistikaToJson(CitatStatistika instance) =>
    <String, dynamic>{
      'dodanoDanas': instance.dodanoDanas,
      'trenutniNiz': instance.trenutniNiz,
      'najduziNiz': instance.najduziNiz,
      'tekstCitata': instance.tekstCitata,
      'nazivKnjige': instance.nazivKnjige,
      'brojStranice': instance.brojStranice,
    };
