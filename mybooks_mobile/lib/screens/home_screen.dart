import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
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
  //final int yearlyGoal = 30;
  int brojFavorita = 0;
  WishKnjiga? randomBook;
  bool loadingRandom = false;
  bool hasPicked = false;

  bool imaKnjiga = false;
  bool imaWishKnjiga = false;
  final currentYear = DateTime.now().year;

  Knjiga? danasnjaKnjiga;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  /*@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }*/

  Future<void> loadData() async {
    try {
      var korisnikId = Authorization.korisnik!.id;

      // statistika
      var provider = StatistikaProvider();

      var result = await provider.getStatistika(
        korisnikId,
      );

      // statistika citata
      var citatProvider = CitatStatistikaProvider();

      var citatResult = await citatProvider.getStatistika(
        korisnikId,
      );

      print("CITAT STATISTIKA: ${citatResult.toJson()}");

      for (var c in citatResult.citatiPoDanima ?? []) {
        print("${c.datum} -> ${c.broj}");
      }

      // broj citata korisnika
      var citati = await CitatProvider().get(
        filter: {
          "KorisnikId": korisnikId,
        },
      );

      // provjera ima li korisnik knjiga
      var knjige = await KnjigaProvider().get(
        filter: {
          "KorisnikId": korisnikId,
        },
      );
      var favoriti = knjige.result.where((x) => x.isFavorite == true).length;
      // provjera ima li korisnik wish knjiga
      var wishKnjige = await WishKnjigaProvider().get(
        filter: {
          "KorisnikId": korisnikId,
        },
      );
      var danas = await KnjigaProvider().get(
        filter: {
          "KorisnikId": korisnikId,
          "NaDanasnjiDan": true,
        },
      );
      if (!mounted) return;

      setState(() {
        statistika = result;

        citatStatistika = citatResult;

        brojCitata = citati.result.length;
        brojFavorita = favoriti;
        // 🔥 provjere za prikaz kartica
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
    // mala "spin" animacija

    final result =
        await WishKnjigaProvider().getRandom(Authorization.korisnik!.id);

    setState(() {
      randomBook = result;
      loadingRandom = false;
    });
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

  List get booksPerMonth => statistika?.knjigePoMjesecima ?? [];

  List get genres => statistika?.topZanrovi ?? [];
  List get authors => statistika?.topAutori ?? [];
  List<CitatPoDanu> get citatiPoDanima => citatStatistika?.citatiPoDanima ?? [];

  String getMoodEmoji(String? moodText) {
    if (moodText == null) return "📖";

    final found = moods.firstWhereOrNull(
      (m) => m["text"] == moodText,
    );

    return found?["emoji"] ?? "📖";
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

    // ispravna gramatika: godinu / godine / godina
    String vremenskiTekst;
    if (godine == 1) {
      vremenskiTekst = "Prije godinu dana";
    } else if (godine > 1 && godine < 5) {
      vremenskiTekst = "Prije $godine godine";
    } else {
      vremenskiTekst = "Prije $godine godina";
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6D8B74),
              Color(0xFF4F6F58),
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // suptilan dekorativni krug u pozadini
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
                      child:  Row(
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
                    // vremenska oznaka SAMO ako je proslih godina
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
                        borderRadius: BorderRadius.circular(14),
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
                        color: Color(0xFF6D8B74),
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

                // MOOD — kompaktan red
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

  Widget buildBooksChart() {
    if (booksPerMonth.isEmpty) return const SizedBox();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          alignment: BarChartAlignment.spaceAround,
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

  @override
  Widget build(BuildContext context) {
    final topGenre = (genres.isNotEmpty) ? genres.first.naziv ?? "-" : "-";
    final ukupnoKnjiga = statistika?.ukupnoKnjiga ?? 0;
    final yearlyGoal = Authorization.korisnik?.godisnjiCilj ?? 30;

    final progress =
        ukupnoKnjiga >= yearlyGoal ? 1.0 : ukupnoKnjiga / yearlyGoal;

    final int remaining =
        ukupnoKnjiga >= yearlyGoal ? 0 : yearlyGoal - ukupnoKnjiga;

    final int percentage = (progress * 100).round();

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6D8B74),
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
                    style: TextStyle(
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
                  //const SizedBox(height: 20),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          progress >= 1 ? Colors.green.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: progress >= 1
                            ? Colors.green
                            : const Color(0xFF6D8B74).withOpacity(0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
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
                            Icon(
                              progress >= 1 ? Icons.emoji_events : Icons.flag,
                              color: progress >= 1
                                  ? Colors.green
                                  : const Color(0xFF6D8B74),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Cilj čitanja $currentYear",
                                style: TextStyle(
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
                                color:
                                    const Color(0xFF6D8B74).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$percentage%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6D8B74),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1
                                  ? Colors.green
                                  : const Color(0xFF6D8B74),
                            ),
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
                        if (progress >= 1) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.celebration,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Bravo! Ostvarila si svoj godišnji cilj čitanja! 🎉",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  /*buildDailyChallengeCard(),
                  const SizedBox(height: 24),*/
                  if (danasnjaKnjiga != null) ...[
                    buildTodayMemoryCard(),
                    const SizedBox(height: 24),
                  ],
                  if (imaKnjiga) ...[
                    buildDailyChallengeCard(),
                    const SizedBox(height: 24),
                  ],
                  /*buildRandomWishBook(),
                  const SizedBox(height: 24),*/
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: buildInfoCard(
                      "Top žanr",
                      topGenre,
                      Icons.auto_awesome,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (booksPerMonth.isNotEmpty) ...[
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📚 Knjige po mjesecima",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (booksPerMonth.isNotEmpty)
                              buildBooksChart()
                            else
                              const Text("Nema podataka"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (genres.isNotEmpty) ...[
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "🏆 Najčitaniji žanrovi",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (genres.isNotEmpty) ...[
                              buildGenreChart(),
                              const SizedBox(height: 15),
                              buildGenreLegend(),
                            ] else
                              const Text("Nema podataka"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const SizedBox(height: 24),
                  if (authors.isNotEmpty) ...[
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "✍️ Top autori",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildTopAutori(statistika?.topAutori ?? []),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (citatiPoDanima.isNotEmpty) ...[
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "🔥 Tvoja čitalačka aktivnost (zadnjih 365 dana)",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            //buildMonthLabels(),
                            //const SizedBox(height: 8),
                            // buildGitHubHeatmap(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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
            colors: [Color(0xFF6D8B74), Color(0xFFA4B494)],
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
                foregroundColor: const Color(0xFF6D8B74),
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
                          color: const Color(0xFF6D8B74)
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
                              color: const Color(0xFF6D8B74).withOpacity(0.25),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology_alt,
                          size: 60,
                          color: Color(0xFF6D8B74),
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
                "Analiziram tvoje knjige i raspoloženje čitanja",
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
            colors: [Color(0xFF6D8B74), Color(0xFFA4B494)],
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
            // const SizedBox(height: 12),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getPriorityIcon(randomBook!.prioritet),
                const SizedBox(width: 6),
                Text(
                  randomBook!.prioritet ?? "-",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),*/
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6D8B74),
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

  Widget getPriorityIcon(String? priority) {
    switch (priority) {
      case "Visok":
        return const Icon(Icons.local_fire_department, color: Colors.red);

      case "Srednji":
        return const Icon(Icons.flash_on, color: Colors.orange);

      case "Nizak":
        return const Icon(Icons.eco, color: Colors.green);

      default:
        return const Icon(Icons.book, color: Colors.grey);
    }
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
        color: dodanoDanas ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dodanoDanas
              ? Colors.green
              : const Color(0xFF6D8B74).withOpacity(0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                dodanoDanas ? Icons.check_circle : Icons.local_fire_department,
                color: dodanoDanas ? Colors.green : Colors.orange,
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
                      dodanoDanas ? Colors.grey : const Color(0xFF6D8B74),
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
                          loadData(); // 🔥 refresh nakon dodavanja
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 206, 217, 210),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
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
}