import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/models/znacka.dart';
import 'dart:io';
import 'dart:convert';

import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/korisnik_znacka_provider.dart';
import 'package:mybooks_mobile/providers/zanr_provider.dart';
import 'package:mybooks_mobile/models/zanr.dart';

import 'package:file_picker/file_picker.dart';
import 'package:mybooks_mobile/data/moods.dart';

import 'package:mybooks_mobile/providers/znacke_provider.dart';

import 'package:confetti/confetti.dart';
import 'package:collection/collection.dart';

class AddKnjigaScreen extends StatefulWidget {
  const AddKnjigaScreen({super.key});

  @override
  State<AddKnjigaScreen> createState() => _AddKnjigaScreenState();
}

class _AddKnjigaScreenState extends State<AddKnjigaScreen> {
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

  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();

    loadZanrovi();

    loadZnacke();

    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
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
    confettiController.dispose();

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

    setState(() {
      isLoading = true;
    });

    try {
      // ZNAČKE PRIJE

      var znackePrije = await KorisnikZnackaProvider()
          .get(filter: {"idKorisnik": Authorization.korisnik!.id});

      var stareZnackeIds = znackePrije.result.map((x) => x.znackaId).toSet();

      // DODAVANJE KNJIGE

      await KnjigaProvider().insert({
        "naslov": naslovController.text,
        "autor": autorController.text,
        "opis": opisController.text,
        "ocjena": ocjena,
        "status": "U toku",
        "recenzija": recenzijaController.text,
        "slikaBase64": base64Image,
        "zanroviIds": selectedZanrovi,
        "isFavorite": isFavorite,
        "mood": selectedMood,
        "korisnikId": Authorization.korisnik!.id
      });

      // sačekaj dok backend provjeri značke

      await Future.delayed(const Duration(milliseconds: 500));

      // ZNAČKE POSLIJE

      var znackePoslije = await KorisnikZnackaProvider()
          .get(filter: {"idKorisnik": Authorization.korisnik!.id});

      var noveZnackeIds = znackePoslije.result.map((x) => x.znackaId).toSet();

      // razlika = nova osvojena značka

      var novaZnackaId = noveZnackeIds.difference(stareZnackeIds).firstOrNull;

      if (novaZnackaId != null) {
        var badge = sveZnacke.firstWhereOrNull((x) => x.id == novaZnackaId);

        if (badge != null) {
          showAchievementDialog(badge);
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Knjiga uspješno dodana 🎉"),
        backgroundColor: Colors.green,
      ));

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

      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Greška: $e")));
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAchievementDialog(
    Znacka znacka,
  ) {
    confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 8,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        znacka.ikonica ?? "🏆",
                        style: const TextStyle(
                          fontSize: 65,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Nova značka otključana 🎉",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    znacka.naziv ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    znacka.opis ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Nastavi čitati 📚",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),

            // KONFETI

            Positioned(
              top: -100,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 80,
                gravity: 0.15,
                emissionFrequency: 0.05,
              ),
            ),
          ],
        );
      },
    );
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
    return naslovController.text.isNotEmpty &&
        autorController.text.isNotEmpty &&
        opisController.text.isNotEmpty &&
        recenzijaController.text.isNotEmpty &&
        ocjena > 0 &&
        selectedZanrovi.isNotEmpty;
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
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text("Odaberi sliku")
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: naslovController,
                decoration: inputStyle("Naslov"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: autorController,
                decoration: inputStyle("Autor"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: opisController,
                maxLines: 3,
                decoration: inputStyle("Opis"),
              ),
              const SizedBox(height: 20),
              const Text(
                "Ocjena",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              buildStars(),
              const SizedBox(height: 10),
              TextFormField(
                controller: recenzijaController,
                maxLines: 3,
                decoration: inputStyle("Recenzija"),
              ),
              const SizedBox(height: 20),
              const Text(
                "Žanrovi",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildZanrovi(),
              const SizedBox(height: 25),
              const Text(
                "Kako si se osjećala?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: moods.map((mood) {
                  final selected = selectedMood == mood["text"];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMood = mood["text"];
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
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(mood["text"]!)
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (isLoading || !isFormValid) ? null : save,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
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
