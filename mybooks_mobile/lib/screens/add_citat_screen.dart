import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/providers/citat_provider.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';

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

  @override
  void initState() {
    super.initState();
    loadKnjige();
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

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      var provider = CitatProvider();

      var request = {
        "idKnjiga": selectedKnjiga!.id,
        "tekstCitata": tekstController.text,
        "brojStranice": int.parse(stranicaController.text),
        "jeOmiljeni": omiljeni,
        "korisnikId": Authorization.korisnik!.id,
      };

      await provider.insert(request);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dodaj citat")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 📚 KNJIGA DROPDOWN
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

              const SizedBox(height: 10),

              // 📖 TEKST CITATA
              TextFormField(
                controller: tekstController,
                decoration: const InputDecoration(labelText: "Tekst citata"),
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

              const SizedBox(height: 10),

              // 📄 BROJ STRANICE
              TextFormField(
                controller: stranicaController,
                decoration: const InputDecoration(labelText: "Broj stranice"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Unesi broj stranice";
                  }

                  final number = int.tryParse(v);
                  if (number == null) {
                    return "Mora biti broj";
                  }
                  if (number <= 0) {
                    return "Broj stranice mora biti veći od 0";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 10),

              // ❤️ OMILJENI
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
                    ? const CircularProgressIndicator()
                    : const Text("Spasi"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
