import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/models/citat_statistika.dart';
import 'package:mybooks_mobile/models/statistika.dart';
import 'package:mybooks_mobile/providers/citatStatistika_provider.dart';
import 'package:mybooks_mobile/providers/statistika_provider.dart';
import 'package:mybooks_mobile/providers/citat_provider.dart';
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
  final int yearlyGoal = 30;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    try {
      var provider = StatistikaProvider();
      var result = await provider.getStatistika();

      var citatProvider = CitatStatistikaProvider(); // 🔥 OVO
      var citatResult = await citatProvider.getStatistika(); // 🔥 OVO
      print("CITAT STATISTIKA: ${citatResult.toJson()}");
      var citati = await CitatProvider().get();

      if (!mounted) return;

      setState(() {
        statistika = result;
        citatStatistika = citatResult;
        brojCitata = citati.result.length;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        statistika = null;
        citatStatistika = null;
        brojCitata = 0;
        isLoading = false;
      });
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

  List get booksPerMonth => statistika?.knjigePoMjesecima ?? [];

  List get genres => statistika?.topZanrovi ?? [];

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

  @override
  Widget build(BuildContext context) {
    final topGenre = (genres.isNotEmpty) ? genres.first.naziv ?? "-" : "-";
    final ukupnoKnjiga = statistika?.ukupnoKnjiga ?? 0;

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
                  const Text(
                    "Dobrodošla 👋",
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
                            const Expanded(
                              child: Text(
                                "Cilj čitanja 2026",
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
                  buildDailyChallengeCard(),
                  const SizedBox(height: 24),
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
                          "0",
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
                ],
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
}
