// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik_znacka.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KorisnikZnacka _$KorisnikZnackaFromJson(Map<String, dynamic> json) =>
    KorisnikZnacka(
      json['id'] as int,
      json['korisnikId'] as int,
      json['znackaId'] as int,
      json['datumOtkljucavanja'] == null
          ? null
          : DateTime.parse(json['datumOtkljucavanja'] as String),
      json['znacka'] == null
          ? null
          : Znacka.fromJson(json['znacka'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$KorisnikZnackaToJson(KorisnikZnacka instance) =>
    <String, dynamic>{
      'id': instance.id,
      'korisnikId': instance.korisnikId,
      'znackaId': instance.znackaId,
      'datumOtkljucavanja': instance.datumOtkljucavanja?.toIso8601String(),
      'znacka': instance.znacka,
    };
