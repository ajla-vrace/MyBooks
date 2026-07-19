import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/zanr.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/zanr_provider.dart';
import 'package:mybooks_mobile/screens/knjiga_detalji_screen.dart';

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

  Future<void> toggleFavorite(Knjiga knjiga) async {
    final novaVrijednost = !(knjiga.isFavorite ?? false);

    // optimistički update — UI se odmah promijeni, ne čeka se odgovor servera
    setState(() {
      knjiga.isFavorite = novaVrijednost;
    });

    try {
      var provider = KnjigaProvider();

      // Backend validira Naslov (i ostala obavezna polja) na svaki update
      // zahtjev, pa moramo poslati cijeli payload knjige, a ne samo
      // isFavorite — inače stiže greška tipa "Naslov je obavezan".
      await provider.update(knjiga.id!, {
        "naslov": knjiga.naslov,
        "autor": knjiga.autor,
        "opis": knjiga.opis,
        "recenzija": knjiga.recenzija,
        "ocjena": knjiga.ocjena,
        "isFavorite": novaVrijednost,
        "mood": knjiga.mood,
        "zanroviIds": (knjiga.zanrovi ?? [])
            .where((z) => z.id != null)
            .map((z) => z.id!)
            .toList(),
        if (knjiga.slika != null) "slika": knjiga.slika,
      });
    } catch (e) {
      // ako update ne uspije, vraćamo staro stanje
      if (!mounted) return;
      setState(() {
        knjiga.isFavorite = !novaVrijednost;
      });
    }
  }

  Widget buildBookCard(Knjiga knjiga) {
    final bool isFav = knjiga.isFavorite ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // cijela kartica (osim srca) otvara detalje knjige.
            // behavior: opaque -> reaguje na tap svugdje unutar svojih
            // granica, ne samo tamo gdje ima slike/teksta/boje.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KnjigaDetaljiScreen(knjiga: knjiga),
                  ),
                );

                if (!mounted) return;

                if (result == true) {
                  // izmjena (edit) ili brisanje — treba ponovo dovući listu sa servera
                  loadData(naslov: searchController.text);
                } else {
                  // korisnik se samo vratio nazad (npr. nakon togglanja favorita
                  // na detalj ekranu) — knjiga objekat je isti po referenci i već
                  // mutiran, samo treba rebuildati karticu da se vidi promjena
                  setState(() {});
                }
              },
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // tanka akcent traka — vizuelni potpis brenda na svakoj kartici
                    Container(
                      width: 5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF6D8B74), Color(0xFFA4B494)],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 72,
                          height: 100,
                          color: const Color(0xFFEFF2EE),
                          child: (knjiga.slika != null &&
                                  knjiga.slika!.isNotEmpty)
                              ? Image.memory(
                                  base64Decode(knjiga.slika!),
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.grey.shade400,
                                ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              // ostavlja prostor da naslov ne ide ispod srca
                              padding: const EdgeInsets.only(right: 22),
                              child: Text(
                                knjiga.naslov ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF263238),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              knjiga.autor ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildStars(knjiga.ocjena ?? 0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // srce — zaseban tap koji samo mijenja favorit, ne otvara detalje
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => toggleFavorite(knjiga),
                child: Padding(
                  // veći tap-target (44x44 preporuka) nego što sama ikonica izgleda
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 18,
                    color: isFav ? Colors.red : Colors.grey.shade400,
                  ),
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
                const SizedBox(height: 12),
                // 📚 LIST
                Expanded(
                  child: knjige.isEmpty
                      ? Center(
                          child: Text(
                            "Nema pronađenih knjiga",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.builder(
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