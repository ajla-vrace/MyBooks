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
  List<Citat> citati = [];
  List<Knjiga> knjige = [];

  bool isLoading = true;

  int? selectedBookId;

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

      var result = await provider.get(
        filter: {
          if (selectedBookId != null) "IdKnjiga": selectedBookId,
        },
      );

      setState(() {
        citati = result.result.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
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
    });
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
                /// QUOTE
                Column(
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
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Divider(color: Colors.grey.shade300),

                const SizedBox(height: 12),

                /// BOOK INFO
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 50,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: (citat.idKnjigaNavigation?.slika != null &&
                                citat.idKnjigaNavigation!.slika!.isNotEmpty)
                            ? Image.memory(
                                base64Decode(
                                  citat.idKnjigaNavigation!.slika!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.grey.shade400,
                                  size: 22,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            citat.idKnjigaNavigation?.naslov ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            citat.idKnjigaNavigation?.autor ?? "",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "str. ${citat.brojStranice ?? 0}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
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
                        size: 20,
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
              child: const Icon(
                Icons.close,
                size: 18,
                color: Colors.grey,
              ),
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
                MaterialPageRoute(
                  builder: (_) => const AddCitatScreen(),
                ),
              );

              if (result == true) {
                loadData();
              }
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
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: selectedBookId,
                        isExpanded: true,
                        hint: const Text("Sve knjige"),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text("Sve knjige"),
                          ),
                          ...knjige.map((book) {
                            return DropdownMenuItem<int?>(
                              value: book.id,
                              child: Text(book.naslov ?? ""),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedBookId = value;
                          });

                          loadData();
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

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
