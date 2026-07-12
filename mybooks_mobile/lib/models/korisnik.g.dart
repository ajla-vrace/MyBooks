// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korisnik.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korisnik _$KorisnikFromJson(Map<String, dynamic> json) => Korisnik(
      json['id'] as int,
      json['ime'] as String,
      json['email'] as String,
      json['godisnjiCilj'] as int?,
      json['omiljeniZanrId'] as int?,
    );

Map<String, dynamic> _$KorisnikToJson(Korisnik instance) => <String, dynamic>{
      'id': instance.id,
      'ime': instance.ime,
      'email': instance.email,
      'godisnjiCilj': instance.godisnjiCilj,
      'omiljeniZanrId': instance.omiljeniZanrId,
    };
