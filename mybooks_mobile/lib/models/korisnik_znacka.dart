import 'package:json_annotation/json_annotation.dart';
import 'package:mybooks_mobile/models/znacka.dart';

part 'korisnik_znacka.g.dart';

@JsonSerializable()
class KorisnikZnacka {
  int id;
  int korisnikId;
  int znackaId;
  DateTime? datumOtkljucavanja;
  Znacka? znacka;

  KorisnikZnacka(this.id, this.korisnikId, this.znackaId,
      this.datumOtkljucavanja, this.znacka);

  factory KorisnikZnacka.fromJson(Map<String, dynamic> json) =>
      _$KorisnikZnackaFromJson(json);

  Map<String, dynamic> toJson() => _$KorisnikZnackaToJson(this);
}
