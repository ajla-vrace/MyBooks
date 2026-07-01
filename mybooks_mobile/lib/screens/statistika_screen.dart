import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/models/statistika.dart';
import 'package:mybooks_mobile/providers/statistika_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isLoading = true;
  Statistika? statistika;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      var provider = StatistikaProvider();
      var result = await provider.getStatistika();

      setState(() {
        statistika = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color getGenreColor(int index) {
   final colors = [
      Color.fromARGB(255, 177, 196, 146), // muted green
      Color.fromARGB(255, 137, 152, 179), // soft blue-gray
      Color.fromARGB(255, 222, 165, 108), // warm sand
      Color.fromARGB(255, 127, 121, 112), // light gray-beige
      Color.fromARGB(255, 199, 199, 161), // sage gray
      Color.fromARGB(255, 206, 166, 157), // dusty rose
      Color.fromARGB(255, 169, 169, 129), // olive gray
      Color.fromARGB(255, 162, 119, 156), // muted purple-gray
    ];

    return colors[index % colors.length];
  }

  Widget buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBooksChart() {
    final data = statistika?.knjigePoMjesecima ?? [];

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData:  FlGridData(show: true),
          titlesData: FlTitlesData(
            rightTitles:  AxisTitles(),
            topTitles:  AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();

                  if (index >= data.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(data[index].mjesec ?? ""),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            data.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (data[index].broj ?? 0).toDouble(),
                  width: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGenreChart() {
    final genres = statistika?.topZanrovi ?? [];

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          sections: genres.asMap().entries.map((entry) {
            final index = entry.key;
            final g = entry.value;

            return PieChartSectionData(
              color: getGenreColor(index),
              value: (g.postotak ?? 0).toDouble(),
              title: "${g.postotak?.toStringAsFixed(0)}%",
              radius: 90,
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
    final genres = statistika?.topZanrovi ?? [];

    return Column(
      children: genres.asMap().entries.map((entry) {
        final index = entry.key;
        final g = entry.value;

        return ListTile(
          leading: CircleAvatar(
            radius: 8,
            backgroundColor: getGenreColor(index),
          ),
          title: Text(g.naziv ?? ""),
          trailing: Text(
            "${g.broj} knjiga (${g.postotak?.toStringAsFixed(0)}%)",
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistika")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : statistika == null
              ? const Center(child: Text("Nema podataka"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          buildInfoCard(
                            "Knjige",
                            "${statistika!.ukupnoKnjiga ?? 0}",
                            Icons.menu_book,
                          ),
                          const SizedBox(width: 12),
                          buildInfoCard(
                            "Prosjek",
                            (statistika!.prosjecnaOcjena ?? 0)
                                .toStringAsFixed(1),
                            Icons.star,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Broj knjiga po mjesecima",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      buildBooksChart(),

                      const SizedBox(height: 30),

                      const Text(
                        "Top žanrovi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      buildGenreChart(),
                      const SizedBox(height: 15),
                      buildGenreLegend(),
                    ],
                  ),
                ),
    );
  }
}