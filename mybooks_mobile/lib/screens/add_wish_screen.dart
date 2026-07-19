import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'dart:io';
import 'dart:convert';
import 'package:mybooks_mobile/providers/wishKnjiga_provider.dart';
import 'package:file_picker/file_picker.dart';

class AddWishKnjigaScreen extends StatefulWidget {
  const AddWishKnjigaScreen({super.key});

  @override
  State<AddWishKnjigaScreen> createState() => _AddWishKnjigaScreenState();
}

class _AddWishKnjigaScreenState extends State<AddWishKnjigaScreen> {
  final _formKey = GlobalKey<FormState>();

  final naslovController = TextEditingController();
  final autorController = TextEditingController();
  final napomenaController = TextEditingController();

  String? prioritet;
  bool isLoading = false;

  File? selectedImage;
  String? base64Image;

  // Napomena nije obavezna - forma je validna kad su naslov, autor i
  // prioritet popunjeni. Ovo se osvježava live dok korisnik kuca/bira.
  bool get isFormValid =>
      naslovController.text.trim().isNotEmpty &&
      autorController.text.trim().isNotEmpty &&
      prioritet != null;

  @override
  void initState() {
    super.initState();
    // rebuild na svaku promjenu teksta da se dugme uživo omogući/onemogući
    naslovController.addListener(_onFieldChanged);
    autorController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    naslovController.removeListener(_onFieldChanged);
    autorController.removeListener(_onFieldChanged);
    naslovController.dispose();
    autorController.dispose();
    napomenaController.dispose();
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
    if (!_formKey.currentState!.validate() || !isFormValid) return;

    setState(() => isLoading = true);

    try {
      var provider = WishKnjigaProvider();

      var request = {
        "naslov": naslovController.text.trim(),
        "autor": autorController.text.trim(),
        "napomena": napomenaController.text.trim(),
        "prioritet": prioritet,
        "slikaBase64": base64Image, // 👈 DODANO
        "korisnikId": Authorization.korisnik!.id,
      };

      await provider.insert(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wish knjiga uspješno dodana")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? label : "$label (opciono)",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? "Obavezno polje" : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dodaj Wish knjigu")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🖼️ IMAGE PICKER
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
                        :  Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Dodaj sliku"),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              input("Naslov", naslovController),
              const SizedBox(height: 12),

              input("Autor", autorController),
              const SizedBox(height: 12),

              input(
                "Napomena",
                napomenaController,
                maxLines: 3,
                required: false,
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: prioritet,
                decoration: InputDecoration(
                  labelText: "Prioritet",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "Visok", child: Text("Visok")),
                  DropdownMenuItem(value: "Srednji", child: Text("Srednji")),
                  DropdownMenuItem(value: "Nizak", child: Text("Nizak")),
                ],
                onChanged: (value) {
                  setState(() {
                    prioritet = value;
                  });
                },
                validator: (v) =>
                    v == null ? "Izaberi prioritet" : null,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF1B5E20),
                    disabledBackgroundColor: Colors.grey.shade300,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}