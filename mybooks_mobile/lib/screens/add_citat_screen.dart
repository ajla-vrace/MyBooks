import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/znacka.dart';
import 'package:mybooks_mobile/providers/citat_provider.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/korisnik_znacka_provider.dart';
import 'package:mybooks_mobile/providers/znacke_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:collection/collection.dart';

class AddCitatScreen extends StatefulWidget {
  const AddCitatScreen({super.key});

  @override
  State<AddCitatScreen> createState() => _AddCitatScreenState();
}

class _AddCitatScreenState extends State<AddCitatScreen> {
  final _formKey = GlobalKey<FormState>();

  final tekstController = TextEditingController();
  final stranicaController = TextEditingController();

  bool omiljeni = false;
  bool loading = false;

  List<Knjiga> knjige = [];
  Knjiga? selectedKnjiga;

  List<Znacka> sveZnacke = [];

  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();

    loadKnjige();
    loadZnacke();

    confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> loadKnjige() async {
    var provider = KnjigaProvider();

    var result = await provider.get(
      filter: {
        "KorisnikId": Authorization.korisnik!.id,
      },
    );

    setState(() {
      knjige = result.result;
    });
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

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedKnjiga == null) return;

    setState(() {
      loading = true;
    });

    try {
      // -----------------------------------
      // ZNAČKE PRIJE DODAVANJA CITATA
      // -----------------------------------

      var znackePrije = await KorisnikZnackaProvider().get(
        filter: {
          "idKorisnik": Authorization.korisnik!.id,
        },
      );

      var stariIds = znackePrije.result.map((x) => x.znackaId).toSet();

      // -----------------------------------
      // DODAVANJE CITATA
      // -----------------------------------

      var provider = CitatProvider();

      await provider.insert({
        "idKnjiga": selectedKnjiga!.id,
        "tekstCitata": tekstController.text,
        "brojStranice": int.parse(
          stranicaController.text,
        ),
        "jeOmiljeni": omiljeni,
        "korisnikId": Authorization.korisnik!.id,
      });

      // -----------------------------------
      // ZNAČKE POSLIJE DODAVANJA CITATA
      // -----------------------------------

      // malo čekanje da backend završi ProvjeriZnacke
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      var znackePoslije = await KorisnikZnackaProvider().get(
        filter: {
          "idKorisnik": Authorization.korisnik!.id,
        },
      );

      var noviIds = znackePoslije.result.map((x) => x.znackaId).toSet();

      // pronađi samo novu značku
      var novaZnackaId = noviIds.difference(stariIds).firstOrNull;

      if (novaZnackaId != null) {
        if (sveZnacke.isEmpty) {
          await loadZnacke();
        }

        var novaZnacka = sveZnacke.firstWhere(
          (x) => x.id == novaZnackaId,
        );

        if (!mounted) return;

        // prvo pokaži achievement
        await showAchievementDialog(
          novaZnacka,
        );
      }

      if (!mounted) return;

      // tek nakon zatvaranja dialoga idi nazad
      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Greška: $e",
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    confettiController.dispose();

    tekstController.dispose();
    stranicaController.dispose();

    super.dispose();
  }

  Future<void> showAchievementDialog(
    Znacka znacka,
  ) async {
    confettiController.play();

    await showDialog(
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
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        znacka.ikonica ?? "🏅",
                        style: const TextStyle(
                          fontSize: 60,
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
                      fontSize: 19,
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
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
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Nastavi čitati 📚",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            // 🎉 KONFETI PREKO CIJELOG PROZORA

            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 80,
                  gravity: 0.25,
                  emissionFrequency: 0.05,
                  shouldLoop: false,
                ),
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
        title: const Text("Dodaj citat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<Knjiga>(
                value: selectedKnjiga,
                items: knjige.map((k) {
                  return DropdownMenuItem(
                    value: k,
                    child: Text(k.naslov ?? ""),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKnjiga = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Izaberi knjigu",
                ),
                validator: (v) => v == null ? "Izaberi knjigu" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: tekstController,
                decoration: const InputDecoration(
                  labelText: "Tekst citata",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Unesi citat";
                  }

                  if (v.length < 5) {
                    return "Citat mora imati barem 5 znakova";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: stranicaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Broj stranice",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Unesi broj stranice";
                  }

                  if (int.tryParse(v) == null) {
                    return "Mora biti broj";
                  }

                  return null;
                },
              ),
              SwitchListTile(
                title: const Text("Omiljeni"),
                value: omiljeni,
                onChanged: (v) {
                  setState(() {
                    omiljeni = v;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : save,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Spasi"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
