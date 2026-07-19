import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';

import 'package:mybooks_mobile/models/znacka.dart';
import 'package:mybooks_mobile/models/zanr.dart';

import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/korisnik_znacka_provider.dart';
import 'package:mybooks_mobile/providers/zanr_provider.dart';
import 'package:mybooks_mobile/providers/znacke_provider.dart';

import 'package:file_picker/file_picker.dart';
//import 'package:confetti/confetti.dart';
import 'package:collection/collection.dart';
import 'package:mybooks_mobile/widgets/achievement_dialog.dart';
import 'package:mybooks_mobile/data/moods.dart';

import 'dart:io';
import 'dart:convert';

class AddKnjigaScreen extends StatefulWidget {
  const AddKnjigaScreen({super.key});

  @override
  State<AddKnjigaScreen> createState() => _AddKnjigaScreenState();
}

class _AddKnjigaScreenState extends State<AddKnjigaScreen> {
  // maksimalan broj žanrova koje korisnik može odabrati
  // (usklađeno sa EditKnjigaScreen)
  static const int maxZanrova = 3;

  final _formKey = GlobalKey<FormState>();

  File? selectedImage;

  String? base64Image;

  String? selectedMood;

  final naslovController = TextEditingController();

  final autorController = TextEditingController();

  final opisController = TextEditingController();

  final recenzijaController = TextEditingController();

  int ocjena = 0;

  bool isLoading = false;

  bool isFavorite = false;

  final ScrollController _scrollController = ScrollController();

  List<Zanr> zanrovi = [];

  List<int> selectedZanrovi = [];

  List<Znacka> sveZnacke = [];

  //late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();

    loadZanrovi();

    loadZnacke();

    // osvježavamo isFormValid (dugme "Spasi") svaki put kad korisnik nešto ukuca
    naslovController.addListener(_onFormFieldChanged);
    autorController.addListener(_onFormFieldChanged);
    opisController.addListener(_onFormFieldChanged);
    recenzijaController.addListener(_onFormFieldChanged);

    /*confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );*/
  }

  void _onFormFieldChanged() {
    if (mounted) setState(() {});
  }

  Future<void> loadZnacke() async {
    try {
      var provider = ZnackaProvider();

      var result = await provider.get();

      sveZnacke = result.result;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadZanrovi() async {
    try {
      var provider = ZanrProvider();

      var result = await provider.get();

      if (mounted) {
        setState(() {
          zanrovi = result.result;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    // confettiController.dispose();

    naslovController.removeListener(_onFormFieldChanged);
    autorController.removeListener(_onFormFieldChanged);
    opisController.removeListener(_onFormFieldChanged);
    recenzijaController.removeListener(_onFormFieldChanged);

    naslovController.dispose();

    autorController.dispose();

    opisController.dispose();

    recenzijaController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      final bytes = await file.readAsBytes();

      setState(() {
        selectedImage = file;

        base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> save() async {
    final valid = _formKey.currentState!.validate();

    if (!valid) return;

    if (ocjena == 0) return;

    if (selectedZanrovi.isEmpty) return;

    if (selectedMood == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Osiguraj da su značke učitane prije nego što ih koristimo
      // (loadZnacke() se poziva u initState() bez await, pa ako
      // korisnik brzo popuni formu, sveZnacke može biti prazna)
      if (sveZnacke.isEmpty) {
        await loadZnacke();
      }

      // ===============================
      // ZNAČKE PRIJE
      // ===============================

      var znackePrije = await KorisnikZnackaProvider()
          .get(filter: {"idKorisnik": Authorization.korisnik!.id});

      var stareZnackeIds = znackePrije.result.map((x) => x.znackaId).toSet();

      // ===============================
      // DODAVANJE KNJIGE
      // ===============================

      await KnjigaProvider().insert({
        "naslov": naslovController.text.trim(),
        "autor": autorController.text.trim(),
        "opis": opisController.text.trim(),
        "ocjena": ocjena,
        "status": "U toku",
        "recenzija": recenzijaController.text.trim(),
        "slikaBase64": base64Image,
        "zanroviIds": selectedZanrovi,
        "isFavorite": isFavorite,
        "mood": selectedMood,
        "korisnikId": Authorization.korisnik!.id
      });

      // Backend (KnjigaService.Insert) sinhrono await-uje ProvjeriZnacke
      // prije vraćanja odgovora, pa dodatni delay ovdje nije potreban.

      // ===============================
      // ZNAČKE POSLIJE
      // ===============================

      var znackePoslije = await KorisnikZnackaProvider()
          .get(filter: {"idKorisnik": Authorization.korisnik!.id});

      var noveZnackeIds = znackePoslije.result.map((x) => x.znackaId).toSet();

      var osvojeneIds = noveZnackeIds.difference(stareZnackeIds);

      var noveZnacke =
          sveZnacke.where((x) => osvojeneIds.contains(x.id)).toList();

      // VAŽNO: mora se "await"-ovati AchievementDialog.show() da bi se
      // reset forme / SnackBar / scroll animacija izvršili TEK nakon što
      // se dijalog sa konfetama zaista zatvori. Bez await-a, rebuild
      // pozadinskog ekrana (setState pri resetu forme) se dešavao dok je
      // dijalog i njegov ConfettiWidget još bio aktivan iznad njega, što
      // je izazivalo "ConfettiController used after being disposed".
      if (noveZnacke.isNotEmpty && mounted) {
        await AchievementDialog.show(
          context,
          noveZnacke,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Knjiga uspješno dodana 🎉"),
        backgroundColor: Colors.green,
      ));

      // RESET FORME

      _formKey.currentState?.reset();

      naslovController.clear();

      autorController.clear();

      opisController.clear();

      recenzijaController.clear();

      setState(() {
        ocjena = 0;

        selectedZanrovi.clear();

        selectedImage = null;

        base64Image = null;

        isFavorite = false;

        selectedMood = null;
      });

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Greška: $e"),
        ));
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF1B5E20),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  bool get isFormValid {
    return naslovController.text.trim().length >= 2 &&
        autorController.text.trim().isNotEmpty &&
        opisController.text.trim().isNotEmpty &&
        opisController.text.trim().length <= 1000 &&
        recenzijaController.text.trim().isNotEmpty &&
        recenzijaController.text.trim().length <= 1000 &&
        ocjena > 0 &&
        selectedZanrovi.isNotEmpty &&
        selectedZanrovi.length <= maxZanrova &&
        selectedMood != null;
  }

  Widget buildStars() {
    return FormField<int>(
      initialValue: ocjena,
      validator: (value) {
        if (value == null || value == 0) {
          return "Izaberi ocjenu";
        }

        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < ocjena ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      ocjena = index + 1;

                      state.didChange(ocjena);
                    });
                  },
                );
              }),
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              )
          ],
        );
      },
    );
  }

  Widget buildZanrovi() {
    return FormField<List<int>>(
      initialValue: selectedZanrovi,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Izaberi barem jedan žanr";
        }

        if (value.length > maxZanrova) {
          return "Možeš odabrati najviše $maxZanrova žanra";
        }

        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: zanrovi.map((z) {
                final selected = selectedZanrovi.contains(z.id);

                return FilterChip(
                  label: Text(z.naziv ?? ""),
                  selected: selected,
                  onSelected: (value) {
                    if (value && selectedZanrovi.length >= maxZanrova) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Možeš odabrati najviše $maxZanrova žanra.",
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (value) {
                        selectedZanrovi.add(z.id!);
                      } else {
                        selectedZanrovi.remove(z.id);
                      }

                      state.didChange(selectedZanrovi);
                    });
                  },
                );
              }).toList(),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              )
          ],
        );
      },
    );
  }

  Widget buildMood() {
    return FormField<String>(
      initialValue: selectedMood,
      validator: (value) {
        if (value == null) {
          return "Izaberi raspoloženje";
        }

        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: moods.map((mood) {
                final selected = selectedMood == mood["text"];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = mood["text"];

                      state.didChange(selectedMood);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1B5E20).withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1B5E20)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mood["emoji"]!,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(mood["text"]!)
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dodaj knjigu"),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          // Bez ovoga se validator poruke nikad ne prikazuju, jer se
          // validate() poziva samo unutar save(), a save() se ne pokreće
          // dok je dugme onemogućeno (forma nevalidna). Sa
          // onUserInteraction, svako polje se validira čim ga korisnik
          // dotakne/promijeni, pa se crvena poruka odmah pojavi ispod
          // njega - bez da odmah po otvaranju ekrana sve bude crveno.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: 150,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              const Text("Odaberi sliku")
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: naslovController,
                decoration: inputStyle("Naslov *"),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Naslov je obavezan.";
                  }

                  if (value.trim().length < 2) {
                    return "Naslov treba imati min. 2 karaktera.";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: autorController,
                decoration: inputStyle("Autor *"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Autor je obavezan.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: opisController,
                maxLines: 3,
                maxLength: 1000,
                decoration: inputStyle("Opis *"),
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
              const SizedBox(height: 20),
              const Text(
                "Ocjena *",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildStars(),
              const SizedBox(height: 10),
              TextFormField(
                controller: recenzijaController,
                maxLines: 3,
                maxLength: 1000,
                decoration: inputStyle("Recenzija *"),
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
              const SizedBox(height: 20),
              Text(
                "Žanrovi * (max $maxZanrova)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              buildZanrovi(),
              const SizedBox(height: 25),
              const Text(
                "Kako si se osjećala? *",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildMood(),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text("Favorite"),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFF1B5E20),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (isLoading || !isFormValid) ? null : save,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Spasi"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}