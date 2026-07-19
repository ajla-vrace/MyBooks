import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/screens/my_home_page.dart';
import 'package:mybooks_mobile/screens/tutorial_screen.dart';
import 'package:provider/provider.dart';

import 'package:mybooks_mobile/models/zanr.dart';
import 'package:mybooks_mobile/providers/zanr_provider.dart';
import 'package:mybooks_mobile/providers/korisnik_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final imeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ciljController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool loading = false;

  List<Zanr> zanrovi = [];
  Zanr? selectedZanr;

  @override
  void initState() {
    super.initState();
    loadGenres();
  }

  Future<void> loadGenres() async {
    try {
      var provider = ZanrProvider();

      var result = await provider.get();

      setState(() {
        zanrovi = result.result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška: $e"),
        ),
      );
    }
  }

  InputDecoration decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF6D8B74),
          width: 2,
        ),
      ),
    );
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      var provider = KorisnikProvider();

      var response = await provider.insert({
        "ime": imeController.text.trim(),
        "email": emailController.text.trim(),
        "lozinka": passwordController.text,
        "godisnjiCilj": int.parse(ciljController.text),
        "omiljeniZanrId": selectedZanr!.id,
      });

      if (!mounted) return;

      if (response != null) {
        // 🔑 Automatska prijava — isti obrazac kao u LoginScreen.login(),
        // samo što ovdje korisnika dobijamo direktno iz insert() odgovora,
        // pa nema potrebe da ga ponovo tražimo login pozivom.
        Authorization.korisnik = response;
        print("NOVI KORISNIK ID: ${Authorization.korisnik?.id}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registracija uspješna 🎉"),
            backgroundColor: Colors.green,
          ),
        );

        // Nakon tutorijala ide direktno na MyHomePage jer je korisnik
        // već ulogovan (Authorization.korisnik je setovan iznad).
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TutorialScreen(
              nextScreen: MyHomePage(),
            ),
          ),
        );
      }
    } catch (e) {
      String poruka = "Račun sa ovim emailom već postoji.";
      print("eee to stringgg ");
      print(e.toString());
      if (e.toString().contains("Korisnik sa ovim emailom već postoji")) {
        poruka = "Račun sa ovim emailom već postoji.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(poruka),
         // backgroundColor: Colors.grey,
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // 📏 manji appbar — nema potrebe za standardnom visinom kad nema naslova
        toolbarHeight: 36,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // 📏 GLAVNA IZMJENA: top padding sa 28 na 4 — to je maknulo
          // najveći "prazan" prostor koji si vidio iznad ikonice.
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  // 📏 header ikonica malo manja (25→18 padding, 70→56 size)
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D8B74).withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 56,
                    color: Color(0xFF6D8B74),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Kreiraj račun 📚",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Napravi svoju digitalnu biblioteku.",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                // 📏 razmak prije prvog polja: 35 → 22
                const SizedBox(height: 22),
                TextFormField(
                  controller: imeController,
                  decoration: decoration(
                    label: "Ime i prezime",
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Unesite ime i prezime";
                    }

                    if (RegExp(r'[0-9]').hasMatch(value)) {
                      return "Ime ne može sadržavati brojeve";
                    }

                    return null;
                  },
                ),
                // 📏 razmak između polja: 20 → 14 (samo malo smanjeno, ne previše)
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  decoration: decoration(
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Unesite email";
                    }

                    if (!value.contains("@")) {
                      return "Email nije ispravan";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: decoration(
                    label: "Lozinka",
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Unesite lozinku";
                    }

                    if (value.length < 6) {
                      return "Minimalno 6 znakova";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: decoration(
                    label: "Potvrdi lozinku",
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Potvrdite lozinku";
                    }

                    if (value != passwordController.text) {
                      return "Lozinke nisu iste";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: ciljController,
                  keyboardType: TextInputType.number,
                  decoration: decoration(
                    label: "Godišnji cilj čitanja",
                    icon: Icons.flag_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Unesite cilj";
                    }

                    if (int.tryParse(value) == null) {
                      return "Unesite samo broj";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<Zanr>(
                  value: selectedZanr,
                  decoration: decoration(
                    label: "Omiljeni žanr",
                    icon: Icons.auto_stories_outlined,
                  ),
                  items: zanrovi
                      .map((z) => DropdownMenuItem<Zanr>(
                            value: z,
                            child: Text(z.naziv ?? ""),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedZanr = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Izaberite žanr";
                    }

                    return null;
                  },
                ),
                // 📏 razmak prije dugmeta: 35 → 22
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: loading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D8B74),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Registruj se",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    imeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ciljController.dispose();

    super.dispose();
  }
}