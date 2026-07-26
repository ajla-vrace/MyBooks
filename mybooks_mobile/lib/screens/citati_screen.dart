import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/models/citat.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/providers/citat_provider.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/screens/add_citat_screen.dart';

class CitatiScreen extends StatefulWidget {
  const CitatiScreen({super.key});

  @override
  State<CitatiScreen> createState() => _CitatiScreenState();
}

class _CitatiScreenState extends State<CitatiScreen> {
  List<Citat> citati = []; // filtrirani
  List<Citat> allCitati = []; // SVI citati (za citat dana)
  List<Knjiga> knjige = [];

  bool isLoading = true;
  int? selectedBookId;
  String? selectedSort = "najnoviji"; // default sort

  Citat? citatDana;

  // opcije sortiranja — "value" ide backendu kao "Sort" filter parametar
  // MORA se poklapati tačno sa vrijednostima u CitatService.AddFilter
  final List<Map<String, String>> sortOptions = [
    {"label": "Najnoviji prvo", "value": "najnoviji"},
    {"label": "Najstariji prvo", "value": "najstariji"},
  ];

  @override
  void initState() {
    super.initState();
    loadBooks();
    loadData();
  }

  Future<void> loadBooks() async {
    try {
      var provider = KnjigaProvider();

      var result = await provider.get(
        filter: {
          "KorisnikId": Authorization.korisnik!.id,
        },
      );

      print("KORISNIK ID: ${Authorization.korisnik!.id}");
      print("BROJ KNJIGA DROPDOWN: ${result.result.length}");

      for (var k in result.result) {
        print("${k.id} - ${k.naslov}");
      }

      if (!mounted) return;

      setState(() {
        knjige = result.result;
      });
    } catch (e) {
      print("LOAD BOOKS ERROR: $e");
    }
  }

  Future<void> loadData() async {
    try {
      var provider = CitatProvider();

      // ⭐ SVI CITATI (za daily quote) — bez sorta, uvijek isti redoslijed
      var allResult = await provider.get(
        filter: {"KorisnikId": Authorization.korisnik!.id, },

      );

      // ⭐ FILTRIRANI CITATI (za listu)
      var filteredResult = await provider.get(
        filter: {
          "KorisnikId": Authorization.korisnik!.id,
          if (selectedBookId != null) "IdKnjiga": selectedBookId,
           "Sort": selectedSort ?? "najnoviji"
        },
      );

      setState(() {
        allCitati = allResult.result.toList();

        // .reversed samo kad nema eksplicitnog sorta — inače kvari
        // poredak koji backend već vrati (najnovije/najstarije/omiljeni)
        citati = selectedSort == null
            ? filteredResult.result.toList()
            : filteredResult.result;

        isLoading = false;
      });

      generateCitatDana();
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// ⭐ STABILAN CITAT DANA (NEZAVISAN OD FILTERA)
  void generateCitatDana() {
    if (allCitati.isEmpty) {
      citatDana = null;
      return;
    }

    if (allCitati.length < 2) {
      citatDana = allCitati.first;
      return;
    }

    final today = DateTime.now();

    final seed = today.year * 10000 + today.month * 100 + today.day;

    final index = seed % allCitati.length;

    citatDana = allCitati[index];
  }

  Future<void> toggleFavorite(Citat citat) async {
    var provider = CitatProvider();
    bool newValue = !(citat.jeOmiljeni ?? false);

    await provider.update(citat.id!, {
     // "jeOmiljeni": newValue,
      "idKnjiga": citat.idKnjiga,
            "tekstCitata": citat.tekstCitata,
            "brojStranice": citat.brojStranice,
            "jeOmiljeni": newValue,
    });

    setState(() {
      citat.jeOmiljeni = newValue;
    });
  }

  Future<void> deleteCitat(int id) async {
    var provider = CitatProvider();
    await provider.delete(id);

    setState(() {
      citati.removeWhere((c) => c.id == id);
      allCitati.removeWhere((c) => c.id == id);
    });

    generateCitatDana();
  }

  void confirmDelete(Citat citat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Brisanje citata"),
        content: const Text("Jeste li sigurni?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ne"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteCitat(citat.id!);
            },
            child: const Text(
              "Da",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// ⭐ CITAT DANA UI
  Widget buildCitatDana() {
    if (citatDana == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D8B74), Color(0xFFA4B494)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.white),
              SizedBox(width: 6),
              Text(
                "Citat dana",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "\"${citatDana!.tekstCitata ?? ""}\"",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "- ${citatDana!.idKnjigaNavigation?.autor ?? "Nepoznat"}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCitatCard(Citat citat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 42,
                  color: Color(0xFF6D8B74),
                ),
                const SizedBox(height: 6),
                Text(
                  citat.tekstCitata ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            citat.idKnjigaNavigation?.naslov ?? "",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (citat.brojStranice != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bookmark_border,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Str. ${citat.brojStranice}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => toggleFavorite(citat),
                      child: Icon(
                        citat.jeOmiljeni == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == "edit") {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddCitatScreen(
                        citat: citat,
                      ),
                    ),
                  );

                  if (result == true) {
                    loadData();
                  }
                }

                if (value == "delete") {
                  confirmDelete(citat);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text("Uredi"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "delete",
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text("Obriši"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSortButton() {
    return PopupMenuButton<String>(
      tooltip: "Sortiraj",
      icon: Icon(
        Icons.sort_rounded,
        color: selectedSort != null
            ? const Color(0xFF6D8B74)
            : Colors.grey.shade700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) {
        setState(() {
          selectedSort = value;
        });
        loadData();
      },
      itemBuilder: (context) {
        return sortOptions.map((option) {
          final isSelected = selectedSort == option["value"];

          return PopupMenuItem<String>(
            value: option["value"],
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 18,
                  color: isSelected
                      ? const Color(0xFF6D8B74)
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 10),
                Text(
                  option["label"]!,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected ? const Color(0xFF6D8B74) : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("DROPDOWN LIST:");
    for (var k in knjige) {
      print(k.naslov);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citati"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCitatScreen()),
              );

              if (result == true) loadData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// FILTER + SORT
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int?>(
                          value: selectedBookId,
                          isExpanded: true,
                          hint: const Text("Sve knjige"),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Sve knjige"),
                            ),
                            ...knjige.map(
                              (b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.naslov ?? ""),
                              ),
                            )
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedBookId = value;
                            });
                            loadData();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      buildSortButton(),
                    ],
                  ),
                ),

                /// ⭐ CITAT DANA (NEZAVISAN OD FILTERA)
                if (citatDana != null) buildCitatDana(),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: citati.length,
                    itemBuilder: (context, index) {
                      return buildCitatCard(citati[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}