import 'dart:convert';
import 'package:flutter/material.dart';
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
  List<Citat> citati = [];        // filtrirani
  List<Citat> allCitati = [];     // SVI citati (za citat dana)
  List<Knjiga> knjige = [];

  bool isLoading = true;
  int? selectedBookId;

  Citat? citatDana;

  @override
  void initState() {
    super.initState();
    loadBooks();
    loadData();
  }

  Future<void> loadBooks() async {
    try {
      var provider = KnjigaProvider();
      var result = await provider.get();

      setState(() {
        knjige = result.result;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadData() async {
    try {
      var provider = CitatProvider();

      // ⭐ SVI CITATI (za daily quote)
      var allResult = await provider.get();

      // ⭐ FILTRIRANI CITATI (za listu)
      var filteredResult = await provider.get(
        filter: {
          if (selectedBookId != null) "IdKnjiga": selectedBookId,
        },
      );

      setState(() {
        allCitati = allResult.result.reversed.toList();
        citati = filteredResult.result.reversed.toList();
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

    final seed =
        today.year * 10000 + today.month * 100 + today.day;

    final index = seed % allCitati.length;

    citatDana = allCitati[index];
  }

  Future<void> toggleFavorite(Citat citat) async {
    var provider = CitatProvider();
    bool newValue = !(citat.jeOmiljeni ?? false);

    await provider.update(citat.id!, {
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
                      child: Text(
                        citat.idKnjigaNavigation?.naslov ?? "",
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => confirmDelete(citat),
              child: const Icon(Icons.close, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                /// FILTER
                Padding(
                  padding: const EdgeInsets.all(12),
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