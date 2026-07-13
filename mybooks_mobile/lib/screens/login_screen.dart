import 'package:flutter/material.dart';
import 'package:mybooks_mobile/screens/registracija_screen.dart';
import 'package:provider/provider.dart';

import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/providers/korisnik_provider.dart';
import 'package:mybooks_mobile/screens/my_home_page.dart';
import 'package:mybooks_mobile/screens/registracija_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final lozinkaController = TextEditingController();

  bool loading = false;
  bool showPassword = false;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        lozinkaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unesite email i lozinku."),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      var provider = Provider.of<KorisnikProvider>(
        context,
        listen: false,
      );

      var korisnik = await provider.login(
        emailController.text.trim(),
        lozinkaController.text,
      );

      if (korisnik != null) {
        Authorization.korisnik = korisnik;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MyHomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pogrešan email ili lozinka."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška: $e"),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 20,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D8B74).withOpacity(.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 75,
                    color: Color(0xFF6D8B74),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Dobrodošla nazad 👋",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Prijavi se i nastavi svoje čitalačko putovanje.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration(
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: lozinkaController,
                  obscureText: !showPassword,
                  decoration: inputDecoration(
                    label: "Lozinka",
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      icon: Icon(
                        showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D8B74),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Prijavi se",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Nemaš račun?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Registruj se",
                        style: TextStyle(
                          color: Color(0xFF6D8B74),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Text(
                  "MyBooks © 2026",
                  style: TextStyle(
                    color: Colors.grey.shade500,
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
    emailController.dispose();
    lozinkaController.dispose();
    super.dispose();
  }
}