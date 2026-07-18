import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';
import 'dart:convert';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/korisnik_znacka.dart';
import 'package:mybooks_mobile/models/statistika.dart';
import 'package:mybooks_mobile/models/znacka.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/statistika_provider.dart';
import 'package:mybooks_mobile/models/wish_knjiga.dart';
import 'package:mybooks_mobile/providers/korisnik_znacka_provider.dart';
import 'package:mybooks_mobile/providers/wishKnjiga_provider.dart';
import 'package:mybooks_mobile/providers/znacke_provider.dart';
import 'package:mybooks_mobile/screens/add_wish_screen.dart';
import 'package:mybooks_mobile/screens/galaksija_screen.dart';
import 'package:mybooks_mobile/screens/login_screen.dart';
import 'package:mybooks_mobile/models/citat_statistika.dart';
import 'package:mybooks_mobile/providers/citatStatistika_provider.dart';
import 'package:mybooks_mobile/models/statistika.dart';
import 'package:mybooks_mobile/providers/statistika_provider.dart';
import 'package:mybooks_mobile/widgets/mood_ring_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  List<WishKnjiga> wish = [];
  List<Knjiga> favorites = [];
  List<Knjiga> procitane = [];
  List<Znacka> sveZnacke = [];
  List<int> otkljucaneZnacke = [];
  List<KorisnikZnacka> znacke = [];
  Statistika? statistika;

  bool isLoading = true;

  CitatStatistika? citatStatistika;

  List<CitatPoDanu> get citatiPoDanima => citatStatistika?.citatiPoDanima ?? [];

  List get booksPerMonth => statistika?.knjigePoMjesecima ?? [];
  List get genres => statistika?.topZanrovi ?? [];
  List get authors => statistika?.topAutori ?? [];

  // Umjesto ExpansionTile sekcija koje su dijelile isti scroll (i pravile
  // probleme kod velikog broja stavki - wishlist, značke, statistika),
  // svaka sekcija je sada svoj tab sa NEZAVISNIM scrollom.
  late final TabController _tabController;

  // Scroll kontroler za heatmap čitalačke aktivnosti - koristi se da mapa
  // pri otvaranju automatski skrola do današnjeg dana.
  final ScrollController _heatmapScrollController = ScrollController();
  bool _heatmapScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heatmapScrollController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      var wishProvider = WishKnjigaProvider();
      var wishResult = await wishProvider.get(
        filter: {"korisnikId": Authorization.korisnik!.id},
      );

      var knjigaProvider = KnjigaProvider();
      var knjigaResult = await knjigaProvider.get(
        filter: {"korisnikId": Authorization.korisnik!.id},
      );

      var znackaProvider = KorisnikZnackaProvider();

      var znackaResult = await znackaProvider.get(
        filter: {"idKorisnik": Authorization.korisnik!.id},
      );
      var sveZnackeProvider = ZnackaProvider();

      //var sveZnackeResult = await sveZnackeProvider.get();
      var sveZnackeResult = await sveZnackeProvider
          .get(filter: {"korisnikId": Authorization.korisnik!.id});

      var statistikaProvider = StatistikaProvider();
      var statistikaResult =
          await statistikaProvider.getStatistika(Authorization.korisnik!.id);

      // statistika citata (za heatmap čitalačke aktivnosti)
      var citatStatistikaProvider = CitatStatistikaProvider();
      var citatStatistikaResult = await citatStatistikaProvider
          .getStatistika(Authorization.korisnik!.id);

      setState(() {
        wish = wishResult.result.reversed.toList();
        favorites = knjigaResult.result.where((k) => k.isFavorite).toList();
        // Sve knjige u tabeli su već pročitane, pa se ne filtrira po statusu.
        procitane = knjigaResult.result;
        sveZnacke = sveZnackeResult.result;
        znacke = znackaResult.result;
        otkljucaneZnacke = znackaResult.result.map((x) => x.znackaId!).toList();
        statistika = statistikaResult;
        citatStatistika = citatStatistikaResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getPriorityColor(String? p) {
    switch (p) {
      case "Visok":
        return Colors.red;
      case "Srednji":
        return Colors.orange;
      case "Nizak":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getGenreColor(int index) {
    final colors = [
      const Color(0xFF6D8B74),
      const Color(0xFFA4B494),
      const Color(0xFFD8C3A5),
      const Color(0xFFB7B7A4),
      const Color(0xFF8AA29E),
      const Color(0xFFE6B89C),
    ];
    return colors[index % colors.length];
  }

  Color colorForGenre(String? naziv) {
    switch (naziv) {
      case "Roman":
        return const Color(0xFFFFD54F);
      case "Fantastika":
        return const Color(0xFFBA68C8);
      case "Triler":
        return const Color(0xFFFF5252);
      case "Naučna fantastika":
        return const Color(0xFF40C4FF);
      case "Biografija":
        return const Color(0xFFFFAB40);
      case "Poezija":
        return const Color(0xFFFF4081);
      case "Horor":
        return const Color(0xFF69F0AE);
      case "Misterija":
        return const Color(0xFF7C4DFF);
      case "Drama":
        return const Color(0xFF18FFFF);
      case "Avantura":
        return const Color(0xFFEEFF41);
      default:
        if (naziv == null || naziv.isEmpty) return Colors.white70;
        final hash = naziv.hashCode;
        final hue = (hash % 360).abs().toDouble();
        return HSVColor.fromAHSV(1, hue, 0.75, 1.0).toColor();
    }
  }

  Color colorForGenreMuted(String? naziv) {
    final boja = colorForGenre(naziv);
    if (boja == Colors.white70) return Colors.grey.shade400;
    final hsv = HSVColor.fromColor(boja);
    return hsv
        .withSaturation((hsv.saturation * 0.55).clamp(0.0, 1.0))
        .withValue((hsv.value * 0.75).clamp(0.0, 1.0))
        .toColor();
  }

  Future<void> removeFavorite(Knjiga knjiga) async {
    try {
      var provider = KnjigaProvider();

      await provider.update(knjiga.id!, {
        "isFavorite": false,
      });

      setState(() {
        knjiga.isFavorite = false;
        favorites.removeWhere((k) => k.id == knjiga.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Knjiga je uklonjena iz favorita."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  void confirmDelete(WishKnjiga item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Brisanje knjige"),
        content: Text(
          'Jeste li sigurni da želite ukloniti "${item.naslov}" sa wish liste?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Odustani"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteWish(item.id!);
            },
            child: const Text(
              "Obriši",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteWish(int id) async {
    try {
      var provider = WishKnjigaProvider();
      await provider.delete(id);

      setState(() {
        wish.removeWhere((item) => item.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Knjiga je uklonjena sa wish liste."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  Widget buildZanrovskiDnk() {
    if (statistika == null ||
        statistika!.zanrovskiDNK == null ||
        statistika!.zanrovskiDNK!.isEmpty) {
      return const SizedBox();
    }

    return buildStatCard(
      title: "Žanrovski DNK",
      emoji: "🧬",
      child: Column(
        children: statistika!.zanrovskiDNK!.map((z) => buildDnkRow(z)).toList(),
      ),
    );
  }

  Widget buildMoodChart() {
    if (statistika?.moodStatistika == null ||
        statistika!.moodStatistika!.isEmpty) {
      return const SizedBox();
    }

    return buildStatCard(
      title: "Kako knjige utiču na tebe",
      emoji: "💙",
      child: MoodRingChart(
        moods: statistika!.moodStatistika!,
      ),
    );
  }

  Widget buildBooksChart() {
    if (booksPerMonth.isEmpty) return const SizedBox();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= booksPerMonth.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      booksPerMonth[index].mjesec ?? "",
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            booksPerMonth.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (booksPerMonth[index].broj ?? 0).toDouble(),
                  width: 22,
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF6D8B74),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGenreChart() {
    if (genres.isEmpty) return const SizedBox();

    return SizedBox(
      height: 240,
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 55,
          sections: genres.asMap().entries.map((entry) {
            final index = entry.key;
            final g = entry.value;

            return PieChartSectionData(
              color: getGenreColor(index),
              value: (g.postotak ?? 0).toDouble(),
              title: "${g.postotak?.toStringAsFixed(0)}%",
              radius: 70,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildGenreLegend() {
    if (genres.isEmpty) return const SizedBox();

    return Column(
      children: genres.asMap().entries.map((entry) {
        final index = entry.key;
        final g = entry.value;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 7,
            backgroundColor: getGenreColor(index),
          ),
          title: Text(g.naziv ?? ""),
          trailing: Text(
            "${g.broj} knjiga",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget buildTopAutori(List topAutori) {
    if (topAutori.isEmpty) return const SizedBox();

    final max =
        topAutori.map((e) => e.brojKnjiga ?? 0).reduce((a, b) => a > b ? a : b);

    return Column(
      children: topAutori.map((a) {
        final percent = (a.brojKnjiga ?? 0) / max;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  a.imeAutora ?? "",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent.toDouble(),
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFF6D8B74),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text("${a.brojKnjiga}"),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildStatCard({
    required String title,
    required Widget child,
    String? emoji,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (emoji != null)
                    Text(
                      emoji,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  if (emoji != null) const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHistogramOcjena() {
    if (statistika?.histogramOcjena == null ||
        statistika!.histogramOcjena!.isEmpty) {
      return const SizedBox();
    }

    final maxBroj = statistika!.histogramOcjena!
        .map((e) => e.broj ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return buildStatCard(
      title: "Histogram ocjena",
      emoji: "⭐",
      child: Column(
        children: [
          ...statistika!.histogramOcjena!.map((e) {
            double widthFactor = maxBroj == 0 ? 0 : (e.broj! / maxBroj);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      "${e.ocjena}★",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: widthFactor,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 25,
                    child: Text(
                      "${e.broj}",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildDnkRow(TopZanr zanr) {
    final boja = colorForGenreMuted(zanr.naziv);
    final postotak = (zanr.postotak ?? 0).clamp(0, 100).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: boja,
                  boxShadow: [
                    BoxShadow(color: boja.withOpacity(0.6), blurRadius: 5),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  zanr.naziv ?? "Nepoznato",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                "${postotak.toStringAsFixed(1)}%  ·  ${zanr.broj ?? 0} knj.",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      height: 8,
                      width: constraints.maxWidth * (postotak / 100),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [boja.withOpacity(0.7), boja],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color colorForNivo(int? nivo) {
    switch (nivo) {
      case 1:
        return const Color(0xFFCD7F32);
      case 2:
        return const Color(0xFF9E9E9E);
      case 3:
        return const Color(0xFFFFC107);
      case 4:
        return const Color(0xFF29B6F6);
      case 5:
        return const Color(0xFF66BB6A);
      case 6:
        return const Color(0xFFAB47BC);
      default:
        return const Color(0xFF1B5E20);
    }
  }

  String nivoLabel(int? nivo) {
    switch (nivo) {
      case 1:
        return "Nivo 1";
      case 2:
        return "Nivo 2";
      case 3:
        return "Nivo 3";
      case 4:
        return "Nivo 4";
      case 5:
        return "Nivo 5";
      case 6:
        return "Nivo 6";
      default:
        return "Ostalo";
    }
  }

  Widget buildZnackaBadge(Znacka znacka) {
    final bool otkljucana = otkljucaneZnacke.contains(znacka.id);

    final boja = colorForNivo(znacka.nivo);

    final int trenutni = znacka.trenutniNapredak ?? 0;
    final int prag = znacka.prag ?? 1;

    final double progress = (trenutni / prag).clamp(0.0, 1.0);

    DateTime? datum;

    if (otkljucana) {
      final korisnikZnacka = znacke.firstWhere(
        (x) => x.znackaId == znacka.id,
      );

      datum = korisnikZnacka.datumOtkljucavanja;
    }

    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            final RenderBox box = context.findRenderObject() as RenderBox;

            final Offset position = box.localToGlobal(Offset.zero);

            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                position.dx - 40,
                position.dy - 230,
                position.dx + 120,
                position.dy,
              ),
              items: [
                PopupMenuItem(
                  enabled: false,
                  child: SizedBox(
                    width: 230,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              znacka.ikonica ?? "🏅",
                              style: const TextStyle(
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                znacka.naziv ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          znacka.opis ?? "",
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          otkljucana ? "✓ $prag/$prag" : "$trenutni/$prag",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: otkljucana ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            otkljucana ? Colors.green : boja,
                          ),
                        ),
                        if (otkljucana && datum != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            "🏆 Otključano\n"
                            "${datum.day}."
                            "${datum.month}."
                            "${datum.year}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                )
              ],
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: otkljucana
                      ? boja.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  border: Border.all(
                    color: otkljucana ? boja : Colors.grey.shade400,
                    width: 1.5,
                  ),
                  boxShadow: otkljucana
                      ? [
                          BoxShadow(
                            color: boja.withOpacity(0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: boja.withOpacity(0.25),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Opacity(
                    opacity: otkljucana ? 1 : 0.25,
                    child: Text(
                      znacka.ikonica ?? "🏅",
                      style: const TextStyle(
                        fontSize: 42,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 90,
                height: 34,
                child: Text(
                  znacka.naziv ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.bold,
                    color: otkljucana ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${trenutni >= prag ? prag : trenutni}/$prag",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: otkljucana ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      otkljucana ? Colors.green : boja,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget buildZnackeSummary() {
    final ukupno = sveZnacke.length;
    final osvojeno = otkljucaneZnacke.length;

    final double progress =
        ukupno == 0 ? 0 : (osvojeno / ukupno).clamp(0.0, 1.0);

    final preostalo = ukupno - osvojeno;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF8E1),
            Colors.white,
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFC107).withOpacity(0.15),
                ),
                child: const Center(
                  child: Text(
                    "🏆",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Moje značke",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "$osvojeno/$ukupno",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFFFFC107),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            preostalo == 0
                ? "🎉 Sve značke su osvojene!"
                : "Još $preostalo znački čeka ✨",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    final potvrda = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Odjava"),
          content: const Text(
            "Da li ste sigurni da se želite odjaviti?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Odustani"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "Odjavi se",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (potvrda == true) {
      Authorization.korisnik = null;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  Widget buildZnackeByNivo() {
    if (sveZnacke.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Nema dostupnih znački 🏅",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final Map<int, List<Znacka>> byNivo = {};
    for (final z in sveZnacke) {
      final n = z.nivo ?? 0;
      byNivo.putIfAbsent(n, () => []).add(z);
    }

    final nivoi = byNivo.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nivoi.map((nivo) {
        final grupa = byNivo[nivo]!;
        final boja = colorForNivo(nivo == 0 ? null : nivo);

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: boja,
                      boxShadow: [
                        BoxShadow(color: boja.withOpacity(0.6), blurRadius: 5),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    nivoLabel(nivo == 0 ? null : nivo),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 18,
                runSpacing: 20,
                children:
                    grupa.map((znacka) => buildZnackaBadge(znacka)).toList(),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, int> get heatmapData {
    final map = <String, int>{};

    for (var item in citatiPoDanima) {
      if (item.datum == null) continue;

      final key = item.datum!.toIso8601String().split("T")[0];
      final value = (item.broj ?? 0);
      map[key] = (map[key] ?? 0) + value;
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

  Widget buildGitHubHeatmap() {
    final days = last365Days;
    final weeks = (days.length / 7).ceil();
    final todayIndex = days.length - 1;

    const months = [
      "",
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

    const double cellWidth = 14;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_heatmapScrolledToEnd && _heatmapScrollController.hasClients) {
        final maxScroll = _heatmapScrollController.position.maxScrollExtent;
        final viewportWidth =
            _heatmapScrollController.position.viewportDimension;

        final todayWeekOffset = (todayIndex ~/ 7) * cellWidth;

        final target =
            (todayWeekOffset - viewportWidth * 0.6).clamp(0.0, maxScroll);

        _heatmapScrollController.jumpTo(target);
        _heatmapScrolledToEnd = true;
      }
    });

    return SizedBox(
      height: 170,
      child: Scrollbar(
        controller: _heatmapScrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: _heatmapScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(weeks, (weekIndex) {
                  final firstIndex = weekIndex * 7;

                  if (firstIndex >= days.length) {
                    return const SizedBox(width: cellWidth);
                  }

                  final firstDay = days[firstIndex];

                  return SizedBox(
                    width: cellWidth,
                    child: Text(
                      firstDay.day <= 7 ? months[firstDay.month] : "",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(weeks, (weekIndex) {
                  return Column(
                    children: List.generate(7, (dayIndex) {
                      final index = weekIndex * 7 + dayIndex;

                      if (index >= days.length) {
                        return const SizedBox(
                          width: 10,
                          height: 10,
                        );
                      }

                      final date = days[index];
                      final isToday = index == todayIndex;

                      final key =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

                      final value = heatmapData[key] ?? 0;

                      return Tooltip(
                        message:
                            "${date.day}.${date.month}.${date.year}\n$value citata",
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: value == 0
                                ? Colors.grey.shade200
                                : heatColor(value),
                            borderRadius: BorderRadius.circular(2),
                            border: isToday
                                ? Border.all(
                                    color: const Color(0xFF1B5E20),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFavoritesTab() {
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          "Nema omiljenih knjiga ❤️",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final book = favorites[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1B5E20).withOpacity(0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.naslov ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.autor ?? "",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => removeFavorite(book),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSettingsTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.settings,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "⚙️ Postavke",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Stiže uskoro ✨",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWishlistTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Dodaj wish knjigu"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddWishKnjigaScreen(),
                  ),
                );
                loadData();
              },
            ),
          ),
        ),
        Expanded(
          child: wish.isEmpty
              ? const Center(
                  child: Text(
                    "Wish lista prazna 📌",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: wish.map((item) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 55,
                                height: 78,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                child: (item.slika != null &&
                                        item.slika!.isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          base64Decode(item.slika!),
                                          fit: BoxFit.cover,
                                          width: 55,
                                          height: 78,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.menu_book_rounded,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.naslov ?? "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(item.autor ?? ""),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getPriorityColor(item.prioritet)
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color:
                                              getPriorityColor(item.prioritet),
                                        ),
                                      ),
                                      child: Text(
                                        item.prioritet ?? "",
                                        style: TextStyle(
                                          color:
                                              getPriorityColor(item.prioritet),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 20,
                          child: GestureDetector(
                            onTap: () => confirmDelete(item),
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget buildConstellationTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFD1B3FF),
                          Color(0xFF7C4DFF),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(color: Color(0x557C4DFF), blurRadius: 24),
                      ],
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      size: 30,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sazviježđe pročitanih knjiga",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    procitane.isEmpty
                        ? "Još nema pročitanih knjiga ⭐"
                        : "🔭 Istraži galaksiju od ${procitane.length} pročitanih knjiga",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_full),
                    label: const Text("Otvori galaksiju"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: procitane.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ConstellationScreen(procitane: procitane),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        buildZanrovskiDnk(),
        const SizedBox(height: 20),
        buildHistogramOcjena(),
        const SizedBox(height: 20),
        if (booksPerMonth.isNotEmpty)
          buildStatCard(
            title: "Knjige po mjesecima",
            emoji: "📚",
            child: buildBooksChart(),
          ),
        const SizedBox(height: 20),
        if (genres.isNotEmpty)
          buildStatCard(
            title: "Najčitaniji žanrovi",
            emoji: "🏆",
            child: Column(
              children: [
                buildGenreChart(),
                const SizedBox(height: 15),
                buildGenreLegend(),
              ],
            ),
          ),
        const SizedBox(height: 20),
        if (authors.isNotEmpty)
          buildStatCard(
            title: "Top autori",
            emoji: "✍️",
            child: buildTopAutori(authors),
          ),
        const SizedBox(height: 20),
        if (citatiPoDanima.isNotEmpty)
          buildStatCard(
            title: "Tvoja čitalačka aktivnost (365 dana)",
            emoji: "🔥",
            child: buildGitHubHeatmap(),
          ),
        const SizedBox(height: 20),
        buildMoodChart(),
      ],
    );
  }

  Widget buildBadgesTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        buildZnackeSummary(),
        const SizedBox(height: 8),
        buildZnackeByNivo(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 109, 139, 116),
        title: const Text("Profil"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Color.fromARGB(255, 109, 139, 116),
                    Color.fromARGB(255, 150, 170, 155),
                    Color.fromARGB(255, 220, 230, 223),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const SizedBox(height: 10),
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFFFF8E1),
                      child: Icon(
                        Icons.person,
                        size: 45,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Authorization.korisnik?.ime ?? "Čitalac",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Reader 📚",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              labelColor: const Color(0xFF1B5E20),
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: const Color(0xFF1B5E20),
                              tabs: const [
                                Tab(
                                    icon: Icon(Icons.favorite),
                                    text: "Favorites"),
                                Tab(
                                    icon: Icon(Icons.bookmark),
                                    text: "Wishlist"),
                                Tab(
                                  icon: Icon(Icons.travel_explore),
                                  text: "Sazviježđe",
                                ),
                                Tab(
                                    icon: Icon(Icons.insights),
                                    text: "Statistika"),
                                Tab(
                                  icon: Icon(Icons.workspace_premium),
                                  text: "Značke",
                                ),
                                Tab(
                                  icon: Icon(Icons.settings),
                                  text: "Postavke",
                                ),
                              ],
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  buildFavoritesTab(),
                                  buildWishlistTab(),
                                  buildConstellationTab(),
                                  buildStatsTab(),
                                  buildBadgesTab(),
                                  buildSettingsTab(),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
