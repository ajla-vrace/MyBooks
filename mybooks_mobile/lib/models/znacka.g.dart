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
    );

Map<String, dynamic> _$ZnackaToJson(Znacka instance) => <String, dynamic>{
      'id': instance.id,
      'naziv': instance.naziv,
      'opis': instance.opis,
      'ikonica': instance.ikonica,
    };
