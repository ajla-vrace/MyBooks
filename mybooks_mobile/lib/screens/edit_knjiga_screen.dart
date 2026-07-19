import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/zanr.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/zanr_provider.dart';
import 'package:mybooks_mobile/data/moods.dart';

class EditKnjigaScreen extends StatefulWidget {
  final Knjiga knjiga;

  const EditKnjigaScreen({
    super.key,
    required this.knjiga,
  });

  @override
  State<EditKnjigaScreen> createState() => _EditKnjigaScreenState();
}

class _EditKnjigaScreenState extends State<EditKnjigaScreen> {
  static const Color primary = Color(0xFF6D8B74);
  static const Color primaryDark = Color(0xFF4E6B54);

  // maksimalan broj žanrova koje korisnik može odabrati
  static const int maxZanrova = 3;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _naslovController;
  late final TextEditingController _autorController;
  late final TextEditingController _opisController;
  late final TextEditingController _recenzijaController;

  double _ocjena = 0;
  bool _isFavorite = false;

  // slika se čuva kao base64 string (isto kao i ostatak aplikacije).
  // _slikaBase64 == null && _slikaUklonjena == true -> korisnik je eksplicitno
  // uklonio postojeću sliku, pa šaljemo "" na backend umjesto da je ignorišemo.
  String? _slikaBase64;
  bool _slikaUklonjena = false;

  // žanrovi — učitavaju se sa servera (svi dostupni), a odabrani su oni
  // koje knjiga već ima. Obavezno je odabrati bar jedan, a najviše maxZanrova.
  List<Zanr> _sveZanrovi = [];
  final Set<int> _selectedZanrIds = {};
  bool _loadingZanrovi = true;

  // mood — jednostruki odabir iz statične liste u data/moods.dart, obavezan
  String? _selectedMood;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final k = widget.knjiga;

    _naslovController = TextEditingController(text: k.naslov ?? "");
    _autorController = TextEditingController(text: k.autor ?? "");
    _opisController = TextEditingController(text: k.opis ?? "");
    _recenzijaController = TextEditingController(text: k.recenzija ?? "");

    _ocjena = (k.ocjena ?? 0).toDouble();
    _isFavorite = k.isFavorite ?? false;
    _slikaBase64 = k.slika;
    _selectedMood = k.mood;

    if (k.zanrovi != null) {
      for (final z in k.zanrovi!) {
        if (z.id != null) _selectedZanrIds.add(z.id!);
      }
    }

    // osvježava dugme "Sačuvaj izmjene" (enable/disable) svaki put kad
    // korisnik nešto ukuca, jer se to poredi sa originalnim vrijednostima
    _naslovController.addListener(_onFieldChanged);
    _autorController.addListener(_onFieldChanged);
    _opisController.addListener(_onFieldChanged);
    _recenzijaController.addListener(_onFieldChanged);

    loadZanrovi();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  Future<void> loadZanrovi() async {
    try {
      var provider = ZanrProvider();
      var result = await provider.get();

      setState(() {
        _sveZanrovi = result.result;
        _loadingZanrovi = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingZanrovi = false);
    }
  }

  @override
  void dispose() {
    _naslovController.removeListener(_onFieldChanged);
    _autorController.removeListener(_onFieldChanged);
    _opisController.removeListener(_onFieldChanged);
    _recenzijaController.removeListener(_onFieldChanged);

    _naslovController.dispose();
    _autorController.dispose();
    _opisController.dispose();
    _recenzijaController.dispose();
    super.dispose();
  }

  Future<void> pickSlika() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // učitava bytes direktno - radi i na webu i na mobitelu
      );

      if (result == null || result.files.isEmpty) return;

      final Uint8List? bytes = result.files.single.bytes;

      if (bytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nije moguće učitati odabranu sliku.")),
        );
        return;
      }

      setState(() {
        _slikaBase64 = base64Encode(bytes);
        _slikaUklonjena = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri odabiru slike.")),
      );
    }
  }

  void removeSlika() {
    setState(() {
      _slikaBase64 = null;
      _slikaUklonjena = true;
    });
  }

  /// Provjerava da li je korisnik zaista nešto promijenio u odnosu na
  /// originalnu knjigu. Ako nije, save() ne treba forsirati validaciju
  /// (bitno za starije knjige unesene prije nego su žanr/mood/ocjena
  /// postali obavezni — inače korisnik ne bi mogao izaći sa ekrana bez
  /// da "popravi" podatke koje uopšte nije ni namjeravao mijenjati).
  bool _hasChanges() {
    final k = widget.knjiga;

    if (_naslovController.text.trim() != (k.naslov ?? "").trim()) return true;
    if (_autorController.text.trim() != (k.autor ?? "").trim()) return true;
    if (_opisController.text.trim() != (k.opis ?? "").trim()) return true;
    if (_recenzijaController.text.trim() != (k.recenzija ?? "").trim()) {
      return true;
    }
    if (_ocjena.round() != (k.ocjena ?? 0)) return true;
    if (_isFavorite != (k.isFavorite ?? false)) return true;
    if (_selectedMood != k.mood) return true;

    final originalZanrIds =
        (k.zanrovi ?? []).where((z) => z.id != null).map((z) => z.id!).toSet();
    if (!setEquals(_selectedZanrIds, originalZanrIds)) return true;

    if (_slikaUklonjena) return true;
    if (_slikaBase64 != k.slika) return true;

    return false;
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ocjena == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Molimo odaberite ocjenu (1-5 zvjezdica).")),
      );
      return;
    }

    if (_selectedZanrIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Molimo odaberite bar jedan žanr (maksimalno $maxZanrova)."),
        ),
      );
      return;
    }

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Molimo odaberite raspoloženje uz knjigu.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      var provider = KnjigaProvider();

      final payload = {
        "naslov": _naslovController.text.trim(),
        "autor": _autorController.text.trim(),
        "opis": _opisController.text.trim(),
        "recenzija": _recenzijaController.text.trim(),
        "ocjena": _ocjena.round(),
        "isFavorite": _isFavorite,
        "mood": _selectedMood,
        "zanroviIds": _selectedZanrIds.toList(),
        // ako je slika uklonjena šaljemo prazan string, ako je promijenjena
        // šaljemo novi base64, inače ne diramo postojeću vrijednost
        if (_slikaUklonjena)
          "slikaBase64": ""
        else if (_slikaBase64 != null && _slikaBase64 != widget.knjiga.slika)
          "slikaBase64": _slikaBase64,
      };

      await provider.update(widget.knjiga.id!, payload);

      // osvježavamo lokalni objekat da se detalji ekran odmah prikaže ažuran
      widget.knjiga.naslov = _naslovController.text.trim();
      widget.knjiga.autor = _autorController.text.trim();
      widget.knjiga.opis = _opisController.text.trim();
      widget.knjiga.recenzija = _recenzijaController.text.trim();
      widget.knjiga.ocjena = _ocjena.round();
      widget.knjiga.isFavorite = _isFavorite;
      widget.knjiga.slika = _slikaUklonjena ? null : _slikaBase64;
      widget.knjiga.mood = _selectedMood;
      widget.knjiga.zanrovi = _sveZanrovi
          .where((z) => z.id != null && _selectedZanrIds.contains(z.id))
          .toList();

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri spremanju izmjena.")),
      );
    }
  }

  Widget buildZanroviPicker() {
    if (_loadingZanrovi) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_sveZanrovi.isEmpty) {
      return Text(
        "Nema dostupnih žanrova.",
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _sveZanrovi.map((zanr) {
        final isSelected =
            zanr.id != null && _selectedZanrIds.contains(zanr.id);

        return GestureDetector(
          onTap: () {
            if (zanr.id == null) return;
            setState(() {
              if (isSelected) {
                _selectedZanrIds.remove(zanr.id);
              } else {
                if (_selectedZanrIds.length >= maxZanrova) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("Možete odabrati najviše $maxZanrova žanra."),
                    ),
                  );
                  return;
                }
                _selectedZanrIds.add(zanr.id!);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primary : Colors.grey.shade300,
              ),
            ),
            child: Text(
              zanr.naziv ?? "",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildMoodPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moods.map((mood) {
        final text = mood["text"]!;
        final isSelected = _selectedMood == text;

        return GestureDetector(
          onTap: () {
            setState(() {
              // mood je obavezan, pa klik na već odabrani mood ga ne poništava
              _selectedMood = text;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary.withOpacity(0.15) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primary : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mood["emoji"]!, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? primaryDark : Colors.black87,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 18),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF25322A),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget buildSlikaPicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: pickSlika,
            child: Container(
              width: 130,
              height: 175,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2EE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: (_slikaBase64 != null && _slikaBase64!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        base64Decode(_slikaBase64!),
                        fit: BoxFit.cover,
                        width: 130,
                        height: 175,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded,
                            color: Colors.grey.shade500, size: 34),
                        const SizedBox(height: 8),
                        Text(
                          "Dodaj sliku",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          if (_slikaBase64 != null && _slikaBase64!.isNotEmpty)
            TextButton.icon(
              onPressed: removeSlika,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 18),
              label: const Text(
                "Ukloni sliku",
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildOcjenaPicker() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final zvjezdica = index + 1;
          final isFilled = zvjezdica <= _ocjena;

          return GestureDetector(
            onTap: () {
              setState(() {
                // ocjena je obavezna, pa klik na već odabranu zvjezdicu je ne poništava
                _ocjena = zvjezdica.toDouble();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                color: const Color(0xFFFFB74D),
                size: 36,
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Uredi knjigu"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              buildSlikaPicker(),
              _label("Naslov *"),
              TextFormField(
                controller: _naslovController,
                decoration: _inputDecoration("Unesite naslov knjige"),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Naslov je obavezan.";
                  }
                  if (value.trim().length < 2) {
                    return "Naslov je prekratak.";
                  }
                  return null;
                },
              ),
              _label("Autor *"),
              TextFormField(
                controller: _autorController,
                decoration: _inputDecoration("Unesite ime autora"),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Autor je obavezan.";
                  }
                  return null;
                },
              ),
              _label("Ocjena *"),
              buildOcjenaPicker(),
              _label("Opis *"),
              TextFormField(
                controller: _opisController,
                decoration: _inputDecoration("O čemu knjiga govori..."),
                maxLines: 4,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Opis je obavezan.";
                  }
                  if (value.trim().length > 1000) {
                    return "Opis je predugačak (max 1000 karaktera).";
                  }
                  return null;
                },
              ),
              _label("Recenzija *"),
              TextFormField(
                controller: _recenzijaController,
                decoration: _inputDecoration("Tvoj utisak o knjizi..."),
                maxLines: 4,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Recenzija je obavezna.";
                  }
                  if (value.trim().length > 1000) {
                    return "Recenzija je predugačka (max 1000 karaktera).";
                  }
                  return null;
                },
              ),
              _label("Žanrovi * (max $maxZanrova)"),
              buildZanroviPicker(),
              _label("Raspoloženje uz knjigu *"),
              buildMoodPicker(),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: primary,
                  title: const Text(
                    "Omiljena knjiga",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  secondary: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.redAccent : Colors.grey,
                  ),
                  value: _isFavorite,
                  onChanged: (value) {
                    setState(() => _isFavorite = value);
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isSaving || !_hasChanges()) ? null : save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSaving ? "Spremanje..." : "Sačuvaj izmjene"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
