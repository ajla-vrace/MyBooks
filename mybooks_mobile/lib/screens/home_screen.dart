import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'package:mybooks_mobile/data/moods.dart';
import 'package:mybooks_mobile/models/citat_statistika.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/statistika.dart';
import 'package:mybooks_mobile/models/wish_knjiga.dart';
import 'package:mybooks_mobile/providers/citatStatistika_provider.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/statistika_provider.dart';
import 'package:mybooks_mobile/providers/citat_provider.dart';
import 'package:mybooks_mobile/providers/wishKnjiga_provider.dart';
import 'package:mybooks_mobile/screens/add_citat_screen.dart';
import 'package:mybooks_mobile/screens/add_knjiga_screen.dart';
import 'package:mybooks_mobile/models/znacka.dart';
import 'package:mybooks_mobile/providers/korisnik_znacka_provider.dart';
import 'package:mybooks_mobile/screens/knjiga_detalji_screen.dart';

// ============================================================
// 🎨 JEDINSTVENA PALETA BOJA
// Sve zelene nijanse u appu izvedene su iz ove dvije osnovne
// boje, kako ne bi bilo mješanja "brend" zelene i Material
// zelene (Colors.green) po ekranu.
// ============================================================
class AppColors {
  static const Color primary = Color(0xFF6D8B74);
  static const Color primaryLight = Color(0xFFA4B494);

  // pozadina/ivica "obične" (stat) kartice
  static const Color cardBorder = Color(0x406D8B74); // primary @ 25%

  // "uspjeh" / completed stanje — tamnija varijanta iste zelene,
  // NE Colors.green, da ostane u istoj paleti
  static Color successBg = primary.withOpacity(0.12);
  static const Color successBorder = primary;
  static const Color successIcon = primary;

  static const double radiusLg = 20;
  static const double radiusMd = 14;

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  int brojCitata = 0;
  Statistika? statistika;
  CitatStatistika? citatStatistika;
  int brojFavorita = 0;
  WishKnjiga? randomBook;
  bool loadingRandom = false;
  bool hasPicked = false;

  bool imaKnjiga = false;
  bool imaWishKnjiga = false;
  final currentYear = DateTime.now().year;
  Znacka? sljedecaZnacka;
  Knjiga? danasnjaKnjiga;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      var korisnikId = Authorization.korisnik!.id;

      var provider = StatistikaProvider();
      var result = await provider.getStatistika(korisnikId);

      var citatProvider = CitatStatistikaProvider();
      var citatResult = await citatProvider.getStatistika(korisnikId);

      var citati = await CitatProvider().get(
        filter: {"KorisnikId": korisnikId},
      );

      var znackaProvider = KorisnikZnackaProvider();
      var sljedeca = await znackaProvider.getSljedecaZnacka(korisnikId);

      var knjige = await KnjigaProvider().get(
        filter: {"KorisnikId": korisnikId},
      );
      var favoriti = knjige.result.where((x) => x.isFavorite == true).length;

      var wishKnjige = await WishKnjigaProvider().get(
        filter: {"KorisnikId": korisnikId},
      );

      var danas = await KnjigaProvider().get(
        filter: {
          "KorisnikId": korisnikId,
          "NaDanasnjiDan": true,
        },
      );
      print(
          "DANASNJA KNJIGA: ${danas.result.isNotEmpty ? danas.result.first.toJson() : 'PRAZNO'}");
      if (danas.result.isNotEmpty) {
        print("DATUM KREIRANJA: ${danas.result.first.datumKreiranja}");
      }
      if (!mounted) return;

      setState(() {
        statistika = result;
        citatStatistika = citatResult;
        sljedecaZnacka = sljedeca;
        brojCitata = citati.result.length;
        brojFavorita = favoriti;
        imaKnjiga = knjige.result.isNotEmpty;
        imaWishKnjiga = wishKnjige.result.isNotEmpty;
        danasnjaKnjiga = danas.result.isNotEmpty ? danas.result.first : null;
        isLoading = false;
      });
    } catch (e) {
      print("GREŠKA HOME LOAD DATA: $e");

      if (!mounted) return;

      setState(() {
        statistika = null;
        citatStatistika = null;
        brojCitata = 0;
        imaKnjiga = false;
        imaWishKnjiga = false;
        isLoading = false;
      });
    }
  }

  Future<void> pickRandomBook() async {
    setState(() {
      loadingRandom = true;
      hasPicked = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final result =
        await WishKnjigaProvider().getRandom(Authorization.korisnik!.id);

    setState(() {
      randomBook = result;
      loadingRandom = false;
    });
  }

  List<CitatPoDanu> get citatiPoDanima => citatStatistika?.citatiPoDanima ?? [];

  String getMoodEmoji(String? moodText) {
    if (moodText == null) return "📖";

    final found = moods.firstWhereOrNull(
      (m) => m["text"] == moodText,
    );

    return found?["emoji"] ?? "📖";
  }

  // ============================================================
  // 🌱 HERO / CTA KARTICE — namjerno upadljive, uvijek isti
  // gradient (primary -> primaryLight) da se odmah prepoznaju
  // kao "akcione" kartice na ekranu.
  // ============================================================

  Widget buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Tvoja biblioteka je još prazna",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Nemaš nijednu dodanu knjigu ni osvojenu značku. Dodaj svoju prvu knjigu i osvoji prvu značku — započni svoj čitalački put! 🏆",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddKnjigaScreen(),
                  ),
                ).then((_) {
                  loadData();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Dodaj prvu knjigu",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTodayMemoryCard() {
    if (danasnjaKnjiga == null) {
      return const SizedBox();
    }

    final datum = danasnjaKnjiga!.datumKreiranja;
    final ocjena = danasnjaKnjiga!.ocjena ?? 0;
    final isFav = danasnjaKnjiga!.isFavorite ?? false;
    final mood = danasnjaKnjiga!.mood;

    int godine = 0;
    if (datum != null) {
      godine = DateTime.now().year - datum.year;
    }

    String vremenskiTekst;
    if (godine == 1) {
      vremenskiTekst = "Prije godinu dana";
    } else if (godine > 1 && godine < 5) {
      vremenskiTekst = "Prije $godine godine";
    } else {
      vremenskiTekst = "Prije $godine godina";
    }

    Widget bookThumb;
    if (danasnjaKnjiga!.slika != null && danasnjaKnjiga!.slika!.isNotEmpty) {
      try {
        bookThumb = Image.memory(
          base64Decode(danasnjaKnjiga!.slika!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.auto_stories,
            size: 24,
            color: AppColors.primary,
          ),
        );
      } catch (_) {
        bookThumb = const Icon(
          Icons.auto_stories,
          size: 24,
          color: AppColors.primary,
        );
      }
    } else {
      bookThumb = const Icon(
        Icons.auto_stories,
        size: 24,
        color: AppColors.primary,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Na današnji dan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (godine > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: Colors.white.withOpacity(0.75),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vremenskiTekst,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: bookThumb,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            danasnjaKnjiga!.naslov ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          if (danasnjaKnjiga!.autor != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              danasnjaKnjiga!.autor!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (ocjena > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < ocjena.round()
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: const Color(0xFFFFD166),
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (mood != null && mood.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getMoodEmoji(mood),
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mood,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (isFav)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child:  Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                              color: Colors.red,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Favorit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KnjigaDetaljiScreen(
                              knjiga: danasnjaKnjiga!,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Detalji",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTodayMemoryCard2() {
    if (danasnjaKnjiga == null) {
      return const SizedBox();
    }

    final datum = danasnjaKnjiga!.datumKreiranja;
    final ocjena = danasnjaKnjiga!.ocjena ?? 0;
    final mood = danasnjaKnjiga!.mood;

    int godine = 0;
    if (datum != null) {
      godine = DateTime.now().year - datum.year;
    }

    String vremenskiTekst;
    if (godine == 1) {
      vremenskiTekst = "Prije godinu dana";
    } else if (godine > 1 && godine < 5) {
      vremenskiTekst = "Prije $godine godine";
    } else {
      vremenskiTekst = "Prije $godine godina";
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Na današnji dan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (godine > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 12, color: Colors.white.withOpacity(0.75)),
                          const SizedBox(width: 4),
                          Text(
                            vremenskiTekst,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            danasnjaKnjiga!.naslov ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          if (danasnjaKnjiga!.autor != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              danasnjaKnjiga!.autor!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (ocjena > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < ocjena.round()
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: const Color(0xFFFFD166),
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (mood != null && mood.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getMoodEmoji(mood),
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mood,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KnjigaDetaljiScreen(
                                knjiga: danasnjaKnjiga!,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Detalji",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 11,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTodayMemoryCard1() {
    if (danasnjaKnjiga == null) {
      return const SizedBox();
    }

    final datum = danasnjaKnjiga!.datumKreiranja;
    final ocjena = danasnjaKnjiga!.ocjena ?? 0;
    final isFav = danasnjaKnjiga!.isFavorite ?? false;
    final mood = danasnjaKnjiga!.mood;

    int godine = 0;
    if (datum != null) {
      godine = DateTime.now().year - datum.year;
    }

    String vremenskiTekst;
    if (godine == 1) {
      vremenskiTekst = "Prije godinu dana";
    } else if (godine > 1 && godine < 5) {
      vremenskiTekst = "Prije $godine godine";
    } else {
      vremenskiTekst = "Prije $godine godina";
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("✨", style: TextStyle(fontSize: 11)),
                          SizedBox(width: 4),
                          Text(
                            "Na današnji dan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isFav) ...[
                      const Icon(
                        Icons.favorite,
                        size: 15,
                        color: Color(0xFFFF8FA3),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (godine > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 11,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              vremenskiTekst,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            danasnjaKnjiga!.naslov ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          if (danasnjaKnjiga!.autor != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              danasnjaKnjiga!.autor!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (ocjena > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < ocjena.round()
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: const Color(0xFFFFD166),
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (mood != null && mood.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          getMoodEmoji(mood),
                          style: const TextStyle(fontSize: 17),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mood,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSljedecaZnackaCard() {
    final znacka = sljedecaZnacka!;

    final napredak = znacka.trenutniNapredak ?? 0;
    final prag = znacka.prag;

    final progress = prag == 0 ? 0.0 : napredak / prag;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                znacka.ikonica ?? "🏆",
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🎯 Sljedeća značka",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      znacka.naziv,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            znacka.opis ?? "",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$napredak / $prag  •  još ${prag - napredak}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (prag - napredak == 1)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "🔥 Skoro si tu! Još samo jedan korak.",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildRandomWishBook() {
    Widget content = const SizedBox();

    if (!hasPicked) {
      content = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "✨ Knjiga za tebe",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ne znaš što čitati?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Prepusti izbor aplikaciji i otkrij svoju sljedeću knjigu 📚",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: pickRandomBook,
              child: const Text(
                "🎯 Predloži knjigu",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    if (loadingRandom) {
      content = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1.15),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withOpacity(0.25 + (value - 0.85)),
                          blurRadius: 30,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4DD0E1).withOpacity(0.35),
                              blurRadius: 35,
                              spreadRadius: 6,
                            ),
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology_alt,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              const Text(
                "Preporuka za tebe…",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Analiziram tvoje wish knjige",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (randomBook != null) {
      content = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "🎯 Tvoja preporuka",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              randomBook!.naslov ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "✍️ ${randomBook!.autor ?? "Nepoznat"}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  hasPicked = false;
                  randomBook = null;
                });
              },
              child: const Text(
                "🔄 Pokušaj ponovo",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: content,
    );
  }

  // ============================================================
  // 📊 STAT / STATUS KARTICE — bijele, tanka zelena ivica.
  // "Uspjeh/gotovo" stanje = tamnija nijansa iste zelene
  // (AppColors.successBg/successBorder), ne Colors.green.
  // ============================================================

  Widget buildGodisnjiCiljCard() {
    final ukupnoKnjiga = statistika?.ukupnoKnjiga ?? 0;
    final yearlyGoal = Authorization.korisnik?.godisnjiCilj ?? 30;

    final progress =
        ukupnoKnjiga >= yearlyGoal ? 1.0 : ukupnoKnjiga / yearlyGoal;

    final int remaining =
        ukupnoKnjiga >= yearlyGoal ? 0 : yearlyGoal - ukupnoKnjiga;

    final int percentage = (progress * 100).round();
    final bool achieved = progress >= 1;

    String motivationText;

    if (ukupnoKnjiga == 0) {
      motivationText = "Svaka velika biblioteka počinje prvom knjigom. 📖";
    } else if (progress < 0.25) {
      motivationText = "Odličan početak! Nastavi graditi svoju biblioteku. 🌱";
    } else if (progress < 0.50) {
      motivationText = "Već si na dobrom putu. Samo tako! 💪";
    } else if (progress < 0.75) {
      motivationText = "Više od pola cilja je iza tebe. 📚";
    } else if (progress < 1) {
      motivationText = "Još samo $remaining knjiga do godišnjeg cilja! 🚀";
    } else {
      motivationText = "🎉 Čestitamo! Ostvarila si svoj godišnji cilj!";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: achieved ? AppColors.successBg : Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(
          color: achieved ? AppColors.successBorder : AppColors.cardBorder,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                achieved ? Icons.emoji_events : Icons.flag,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Cilj čitanja $currentYear",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$percentage%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "$ukupnoKnjiga od $yearlyGoal pročitanih knjiga",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            motivationText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          if (achieved) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Bravo! Ostvarila si svoj godišnji cilj čitanja! 🎉",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget buildDailyChallengeCard() {
    final dodanoDanas = citatStatistika?.dodanoDanas ?? false;
    final streak = citatStatistika?.trenutniNiz ?? 0;
    final best = citatStatistika?.najduziNiz ?? 0;

    String message;

    if (!dodanoDanas) {
      message = "Dodaj danasnji citat i nastavi svoj streak 🔥";
    } else if (streak == 1) {
      message = "Odličan početak! Prvi dan streaka 💪";
    } else if (streak < 5) {
      message = "Zadržavaš ritam! Ne prekidaj niz 📚";
    } else if (streak < 10) {
      message = "Wow! Već ozbiljan streak 🚀";
    } else {
      message = "Legenda si čitanja 📖🔥";
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dodanoDanas ? AppColors.successBg : Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(
          color: dodanoDanas ? AppColors.successBorder : AppColors.cardBorder,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                dodanoDanas ? Icons.check_circle : Icons.local_fire_department,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                "Dnevni izazov citata",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                "🔥 $streak",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "Best streak: $best",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      dodanoDanas ? Colors.grey.shade300 : AppColors.primary,
                ),
                onPressed: dodanoDanas
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddCitatScreen(),
                          ),
                        ).then((_) {
                          loadData();
                        });
                      },
                child: Text(
                  dodanoDanas ? "Danas gotovo" : "Dodaj citat",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget getPriorityIcon(String? priority) {
    switch (priority) {
      case "Visok":
        return const Icon(Icons.local_fire_department, color: Colors.red);
      case "Srednji":
        return const Icon(Icons.flash_on, color: Colors.orange);
      case "Nizak":
        return const Icon(Icons.eco, color: AppColors.primary);
      default:
        return const Icon(Icons.book, color: Colors.grey);
    }
  }

  Map<String, int> get heatmapData {
    final map = <String, int>{};

    for (var item in citatStatistika?.citatiPoDanima ?? []) {
      if (item.datum == null) continue;

      final key = item.datum!.toIso8601String().split("T")[0];
      final value = (item.broj ?? 0) as num;
      map[key] = (map[key] ?? 0) + value.toInt();
    }

    return map;
  }

  Color heatColor(int value) {
    if (value == 0) return Colors.grey.shade200;
    if (value == 1) return const Color(0xFF9BE9A8);
    if (value == 2) return const Color(0xFF40C463);
    if (value == 3) return const Color(0xFF30A14E);
    return const Color(0xFF216E39);
  }

  List<DateTime> get last365Days {
    final today = DateTime.now();
    return List.generate(365, (i) {
      return today.subtract(Duration(days: 364 - i));
    });
  }

  Widget buildMonthLabels() {
    final days = last365Days;

    return SizedBox(
      height: 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(52, (weekIndex) {
            final date = days[(weekIndex * 7).clamp(0, days.length - 1)];

            String text = "";

            if (date.day <= 7) {
              const months = [
                "Jan",
                "Feb",
                "Mar",
                "Apr",
                "Maj",
                "Jun",
                "Jul",
                "Aug",
                "Sep",
                "Okt",
                "Nov",
                "Dec"
              ];

              text = months[date.month - 1];
            }

            return SizedBox(
              width: 14,
              child: Text(
                text,
                style: const TextStyle(fontSize: 10),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: const Color.fromARGB(221, 253, 253, 253),
        title: const Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dobrodošla, ${Authorization.korisnik?.ime}👋",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Pregled tvoje biblioteke",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 22),
                  buildGodisnjiCiljCard(),
                  const SizedBox(height: 24),

                  // 🌱 Empty state — samo kad korisnik nema NIJEDNU knjigu.
                  if (!imaKnjiga) ...[
                    buildEmptyStateCard(),
                    const SizedBox(height: 24),
                  ],

                  if (danasnjaKnjiga != null) ...[
                    buildTodayMemoryCard(),
                    const SizedBox(height: 24),
                  ],

                  if (imaKnjiga) ...[
                    buildDailyChallengeCard(),
                    const SizedBox(height: 24),
                  ],

                  if (sljedecaZnacka != null) ...[
                    buildSljedecaZnackaCard(),
                    const SizedBox(height: 24),
                  ],

                  if (imaWishKnjiga) ...[
                    buildRandomWishBook(),
                    const SizedBox(height: 24),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: buildInfoCard(
                          "Knjige",
                          "${statistika?.ukupnoKnjiga ?? 0}",
                          Icons.menu_book,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildInfoCard(
                          "Ocjena",
                          (statistika?.prosjecnaOcjena ?? 0).toStringAsFixed(1),
                          Icons.star,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: buildInfoCard(
                          "Citati",
                          "$brojCitata",
                          Icons.format_quote,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildInfoCard(
                          "Favoriti",
                          "$brojFavorita",
                          Icons.favorite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
