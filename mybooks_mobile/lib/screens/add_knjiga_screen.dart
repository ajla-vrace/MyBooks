import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/zanr_provider.dart';
import 'package:mybooks_mobile/models/zanr.dart';
import 'package:file_picker/file_picker.dart';

class AddKnjigaScreen extends StatefulWidget {
  const AddKnjigaScreen({super.key});

  @override
  State<AddKnjigaScreen> createState() => _AddKnjigaScreenState();
}

class _AddKnjigaScreenState extends State<AddKnjigaScreen> {
  final _formKey = GlobalKey<FormState>();
  File? selectedImage;
  String? base64Image;

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

  @override
  void initState() {
    super.initState();
    loadZanrovi();
  }

  Future<void> loadZanrovi() async {
    try {
      var provider = ZanrProvider();
      var result = await provider.get();
      setState(() => zanrovi = result.result);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    naslovController.dispose();
    autorController.dispose();
    opisController.dispose();
    recenzijaController.dispose();
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

    setState(() => isLoading = true);

    try {
      var provider = KnjigaProvider();

      await provider.insert({
        "naslov": naslovController.text,
        "autor": autorController.text,
        "opis": opisController.text,
        "ocjena": ocjena,
        "status": "U toku",
        "recenzija": recenzijaController.text,
        "slikaBase64": base64Image,
        "zanroviIds": selectedZanrovi,
        "isFavorite": isFavorite,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Knjiga uspješno dodana 🎉"),
          backgroundColor: Colors.green,
        ),
      );
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
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1B5E20)),
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
                      state.didChange(ocjena); // 👈 bitno za validator
                    });
                  },
                );
              }),
            ),
            if (state.hasError)
              Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
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
              children: zanrovi.map((z) {
                final selected = selectedZanrovi.contains(z.id);

                return FilterChip(
                  label: Text(z.naziv ?? ""),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedZanrovi.add(z.id!);
                      } else {
                        selectedZanrovi.remove(z.id);
                      }
                      state.didChange(selectedZanrovi); // 👈 bitno
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
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
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
                      border: Border.all(color: Colors.grey.shade300),
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
                            children: const [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text("Odaberi sliku"),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Favorite"),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() => isFavorite = !isFavorite);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (isLoading || !isFormValid) ? null : save,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Spasi"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
