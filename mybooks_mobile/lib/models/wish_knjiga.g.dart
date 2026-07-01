// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wish_knjiga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishKnjiga _$WishKnjigaFromJson(Map<String, dynamic> json) => WishKnjiga(
      json['id'] as int?,
      json['naslov'] as String?,
      json['autor'] as String?,
      json['napomena'] as String?,
      json['prioritet'] as String?,
      json['slika'] as String?,
    );

Map<String, dynamic> _$WishKnjigaToJson(WishKnjiga instance) =>
    <String, dynamic>{
      'id': instance.id,
      'naslov': instance.naslov,
      'autor': instance.autor,
      'napomena': instance.napomena,
      'prioritet': instance.prioritet,
      'slika': instance.slika,
    };
