// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'znacka.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Znacka _$ZnackaFromJson(Map<String, dynamic> json) => Znacka(
      json['id'] as int,
      json['naziv'] as String,
      json['opis'] as String?,
      json['ikonica'] as String?,
      json['tip'] as String,
      json['prag'] as int,
      json['nivo'] as int?,
    );

Map<String, dynamic> _$ZnackaToJson(Znacka instance) => <String, dynamic>{
      'id': instance.id,
      'naziv': instance.naziv,
      'opis': instance.opis,
      'ikonica': instance.ikonica,
      'tip': instance.tip,
      'prag': instance.prag,
      'nivo': instance.nivo,
    };
