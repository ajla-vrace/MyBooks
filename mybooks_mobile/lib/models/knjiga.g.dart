// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knjiga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Knjiga _$KnjigaFromJson(Map<String, dynamic> json) => Knjiga(
      json['id'] as int?,
      json['naslov'] as String?,
      json['autor'] as String?,
      json['opis'] as String?,
      json['datumKreiranja'] == null
          ? null
          : DateTime.parse(json['datumKreiranja'] as String),
      json['datumPocetka'] == null
          ? null
          : DateTime.parse(json['datumPocetka'] as String),
      json['datumZavrsetka'] == null
          ? null
          : DateTime.parse(json['datumZavrsetka'] as String),
      json['status'] as String?,
      json['ocjena'] as int?,
      json['recenzija'] as String?,
      json['slika'] as String?,
      json['isFavorite'] as bool,
      json['mood'] as String?,
      (json['zanrovi'] as List<dynamic>)
          .map((e) => Zanr.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$KnjigaToJson(Knjiga instance) => <String, dynamic>{
      'id': instance.id,
      'naslov': instance.naslov,
      'autor': instance.autor,
      'opis': instance.opis,
      'datumKreiranja': instance.datumKreiranja?.toIso8601String(),
      'datumPocetka': instance.datumPocetka?.toIso8601String(),
      'datumZavrsetka': instance.datumZavrsetka?.toIso8601String(),
      'status': instance.status,
      'ocjena': instance.ocjena,
      'recenzija': instance.recenzija,
      'slika': instance.slika,
      'isFavorite': instance.isFavorite,
      'mood': instance.mood,
      'zanrovi': instance.zanrovi,
    };
