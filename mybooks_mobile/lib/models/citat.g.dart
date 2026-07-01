// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Citat _$CitatFromJson(Map<String, dynamic> json) => Citat(
      json['id'] as int?,
      json['idKnjiga'] as int?,
      json['tekstCitata'] as String?,
      json['brojStranice'] as int?,
      json['jeOmiljeni'] as bool?,
      json['idKnjigaNavigation'] == null
          ? null
          : Knjiga.fromJson(json['idKnjigaNavigation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CitatToJson(Citat instance) => <String, dynamic>{
      'id': instance.id,
      'idKnjiga': instance.idKnjiga,
      'tekstCitata': instance.tekstCitata,
      'brojStranice': instance.brojStranice,
      'jeOmiljeni': instance.jeOmiljeni,
      'idKnjigaNavigation': instance.idKnjigaNavigation,
    };
