import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/zanr.dart';
import 'package:mybooks_mobile/models/znacka.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/korisnik_znacka_provider.dart';
import 'package:mybooks_mobile/providers/zanr_provider.dart';
import 'package:mybooks_mobile/providers/znacke_provider.dart';
import 'package:mybooks_mobile/screens/knjiga_detalji_screen.dart';
import 'package:mybooks_mobile/widgets/achievement_dialog.dart';

class KnjigeScreen extends StatefulWidget {
  const KnjigeScreen({super.key});

  @override
  State<KnjigeScreen> createState() => _KnjigeScreenState();
}

class _KnjigeScreenState extends State<KnjigeScreen> {
  List<Knjiga> knjige = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  List<Zanr> zanrovi = [];
  int? selectedZanrId;
  String? selectedSort = "najnovije"; // default sort
  Timer? _debounce;

  // opcije sortiranja — "value" ide backendu kao "Sort" filter parametar
  // MORA se poklapati tačno sa vrijednostima u KnjigaService.AddFilter (najnovije / ocjena / az / za)
  final List<Map<String, String>> sortOptions = [
    {"label": "Najnovije prvo", "value": "najnovije"},
    {"label": "Najviša ocjena", "value": "ocjena"},
    {"label": "Naslov (A-Ž)", "value": "az"},
    {"label": "Naslov (Ž-A)", "value": "za"},
  ];

  @override
  void initState() {
    super.initState();
    loadData();
    loadZanrovi();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadZanrovi() async {
    try {
      var provider = ZanrProvider();
      var result = await provider.get();

      setState(() {
        zanrovi = result.result;
      });
    } catch (e) {
      print("Zanrovi error: $e");
    }
  }

  Future<void> loadData({String? naslov}) async {
    setState(() => isLoading = true);

    try {
      var provider = KnjigaProvider();

      /*var result = await provider.get(
        filter: {
          if (naslov != null && naslov.isNotEmpty) "Naslov": naslov,
          if (selectedZanrId != null) "ZanrId": selectedZanrId,
        },
      );*/
      var result = await provider.get(
        filter: {
          "KorisnikId": Authorization.korisnik!.id,
          if (naslov != null && naslov.isNotEmpty) "Naslov": naslov,
          if (selectedZanrId != null) "ZanrId": selectedZanrId,
          if (selectedSort != null) "Sort": selectedSort,
        },
      );

      if (!mounted) return;

      setState(() {
        // .reversed ima smisla samo kao "najnovije prvo" fallback kad nema
        // eksplicitno odabranog sorta — inače pokvari sortove sa backenda (az/za/ocjena)
        knjige = selectedSort == null
            ? result.result.reversed.toList()
            : result.result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /*Future<void> toggleFavorite(Knjiga knjiga) async {
    bool newValue = !(knjiga.isFavorite ?? false);

    setState(() {
      knjiga.isFavorite = newValue;
    });

    var provider = KnjigaProvider();
    await provider.update(knjiga.id!, {
      "isFavorite": newValue,
    });
  }*/
  Future<void> toggleFavorite(Knjiga knjiga) async {
    bool newValue = !(knjiga.isFavorite ?? false);

    // značke prije
    var prije = await KorisnikZnackaProvider()
        .get(filter: {"idKorisnik": Authorization.korisnik!.id});

    var prijeIds = prije.result.map((x) => x.znackaId).toSet();

    setState(() {
      knjiga.isFavorite = newValue;
    });

    await KnjigaProvider().update(
      knjiga.id!,
      {
        "isFavorite": newValue,
      },
    );

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    // značke poslije
    var poslije = await KorisnikZnackaProvider()
        .get(filter: {"idKorisnik": Authorization.korisnik!.id});

    var poslijeIds = poslije.result.map((x) => x.znackaId).toSet();

    var noveIds = poslijeIds.difference(prijeIds);

    if (noveIds.isEmpty) return;

    var sve = await ZnackaProvider().get();

    List<Znacka> osvojene =
        sve.result.where((z) => noveIds.contains(z.id)).toList();

    if (!mounted) return;

    AchievementDialog.show(
      context,
      osvojene,
    );
  }

  Future<void> deleteKnjiga(Knjiga knjiga) async {
    var provider = KnjigaProvider();
    await provider.delete(knjiga.id!);

    setState(() {
      knjige.removeWhere((k) => k.id == knjiga.id);
    });
  }

  void showDeleteDialog(Knjiga knjiga) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Brisanje knjige"),
        content: const Text("Da li ste sigurni?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ne"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteKnjiga(knjiga);
            },
            child: const Text("Da", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: Colors.amber,
        ),
      ),
    );
  }

  Widget buildBookCard(Knjiga knjiga) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KnjigaDetaljiScreen(knjiga: knjiga),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼 IMAGE LEFT
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 85,
                      height: 110,
                      color: Colors.grey.shade300,
                      child: (knjiga.slika != null && knjiga.slika!.isNotEmpty)
                          ? Image.memory(
                              base64Decode(knjiga.slika!),
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.menu_book),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 📝 RIGHT CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          knjiga.naslov ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          knjiga.autor ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        buildStars(knjiga.ocjena ?? 0),

                        const SizedBox(height: 8),

                        // ❤️ FAVORITE
                        GestureDetector(
                          onTap: () => toggleFavorite(knjiga),
                          child: Icon(
                            (knjiga.isFavorite ?? false)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ❌ DELETE TOP RIGHT
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => showDeleteDialog(knjiga),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
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
          // klik na već odabranu opciju je poništava (nazad na default)
          selectedSort = (selectedSort == value) ? null : value;
        });
        loadData(naslov: searchController.text);
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
                    color: isSelected
                        ? const Color(0xFF6D8B74)
                        : Colors.black87,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Knjige"),
        backgroundColor: const Color(0xFF6D8B74),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 SEARCH + SORT
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }

                              _debounce = Timer(
                                const Duration(milliseconds: 400),
                                () {
                                  loadData(naslov: value);
                                },
                              );
                            },
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search),
                              hintText: "Pretraga po naslovu...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: buildSortButton(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: zanrovi.length + 1,
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final zanr = isAll ? null : zanrovi[index - 1];

                      final isSelected = isAll
                          ? selectedZanrId == null
                          : selectedZanrId == zanr!.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedZanrId = isAll ? null : zanr!.id;
                          });

                          loadData(naslov: searchController.text);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6D8B74)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            isAll ? "Svi" : zanr!.naziv ?? "",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
                // 📚 LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: knjige.length,
                    itemBuilder: (context, index) {
                      return buildBookCard(knjige[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}