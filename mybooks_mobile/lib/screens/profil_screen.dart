import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/zanr.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/models/wish_knjiga.dart';
import 'package:mybooks_mobile/providers/wishKnjiga_provider.dart';
import 'package:mybooks_mobile/screens/add_wish_screen.dart';

/// Zvijezda koja "živi" - blago pulsira sjajem i veličinom, svaka svojim
/// tempom (seed po knjizi), tako da cijelo sazviježđe djeluje živo i asinhrono.
/// `intensity` (0..1, obično = ocjena/5) diže fiksnu bazu sjaja i blur/spread,
/// tako da bolje ocijenjene knjige "gore" jače, nezavisno od pulsiranja.
class _TwinklingStar extends StatefulWidget {
  final double size;
  final Color color;
  final int seed;
  final bool isSelected;
  final double intensity;
  final VoidCallback onTap;

  const _TwinklingStar({
    required this.size,
    required this.color,
    required this.seed,
    required this.onTap,
    this.isSelected = false,
    this.intensity = 0.6,
  });

  @override
  State<_TwinklingStar> createState() => _TwinklingStarState();
}

class _TwinklingStarState extends State<_TwinklingStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final rnd = Random(widget.seed);
    // različit period pulsiranja po zvijezdi (0.9s - 1.9s) da ne trepere sinhrono
    final durationMs = 900 + rnd.nextInt(1000);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    // random početna faza da ne krenu sve istovremeno
    _controller.value = rnd.nextDouble();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TickerMode force-enabled: ExpansionTile inače gasi tickere dok je
    // skupljen, ovo garantuje da animacija radi čim je sekcija otvorena.
    return TickerMode(
      enabled: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value); // 0..1
          final intensity = widget.intensity.clamp(0.0, 1.0);

          // fiksna baza sjaja raste sa ocjenom (intensity), pulsiranje je
          // dodatni sloj preko toga - bolje ocijenjene knjige uvijek sijaju
          // jače, slabije ocijenjene su suptilnije čak i na vrhuncu pulsa
          final glow = (0.35 + intensity * 0.45) + t * 0.25;
          final glowSpread = 0.7 + intensity * 0.8;
          final scale = 0.92 + t * 0.16;
          final selBoost = widget.isSelected ? 1.6 : 1.0;

          return GestureDetector(
            onTap: widget.onTap,
            child: Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(
                        (0.85 * glow * selBoost).clamp(0.0, 1.0),
                      ),
                      blurRadius: widget.size * 2.2 * selBoost * glowSpread,
                      spreadRadius: widget.size * 0.25 * selBoost * glowSpread,
                    ),
                    if (widget.isSelected)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: widget.size * 0.9,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Icon(
                  Icons.star,
                  size: widget.size,
                  color: Color.lerp(widget.color, Colors.white, 0.2 * t),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Iscrtava tanke linije koje povezuju zvijezde istog žanra (u "lanac",
/// ne sve-sa-svima, da ne napravi paučinu kod veće biblioteke).
class _GenreLinesPainter extends CustomPainter {
  final List<Knjiga> books;
  final Offset Function(Knjiga) centerOf;
  final Color Function(String?) colorForGenre;

  _GenreLinesPainter({
    required this.books,
    required this.centerOf,
    required this.colorForGenre,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Map<String, List<Knjiga>> byGenre = {};
    for (final b in books) {
      final g = b.zanrovi.isNotEmpty ? b.zanrovi.first.naziv : null;
      if (g == null || g.isEmpty) continue;
      byGenre.putIfAbsent(g, () => []).add(b);
    }

    byGenre.forEach((genre, group) {
      if (group.length < 2) return;
      final boja = colorForGenre(genre);
      final paint = Paint()
        ..color = boja.withOpacity(0.22)
        ..strokeWidth = 1.0;
      for (int i = 0; i < group.length - 1; i++) {
        canvas.drawLine(centerOf(group[i]), centerOf(group[i + 1]), paint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant _GenreLinesPainter oldDelegate) => true;
}

/// Centar galaksije - veći, "mirniji" i jače usijan sjaj od zvijezda, da se
/// odmah vizuelno izdvoji kao gravitaciono središte oko kojeg sve orbitira.
class _GalaxyCore extends StatefulWidget {
  final double size;

  const _GalaxyCore({required this.size});

  @override
  State<_GalaxyCore> createState() => _GalaxyCoreState();
}

class _GalaxyCoreState extends State<_GalaxyCore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // sporiji, "dubinski" damar - jasno drugačiji tempo od zvijezda
    // (koje pulsiraju 0.9s-1.9s) da core djeluje stabilno i moćno
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TickerMode(
      enabled: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value); // 0..1
          final glow = 0.75 + t * 0.35;
          final scale = 0.97 + t * 0.06;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFD1B3FF),
                    Color(0xFF7C4DFF),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.white.withOpacity((0.8 * glow).clamp(0.0, 1.0)),
                    blurRadius: widget.size * 1.3,
                    spreadRadius: widget.size * 0.28,
                  ),
                  BoxShadow(
                    color: const Color(0xFFB388FF)
                        .withOpacity((0.65 * glow).clamp(0.0, 1.0)),
                    blurRadius: widget.size * 0.8,
                    spreadRadius: widget.size * 0.1,
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: const Color(0xFF4A148C),
                size: widget.size * 0.48,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<WishKnjiga> wish = [];
  List<Knjiga> favorites = [];
  List<Knjiga> procitane = [];
  String? selectedStarKey;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      var wishProvider = WishKnjigaProvider();
      var wishResult = await wishProvider.get();

      var knjigaProvider = KnjigaProvider();
      var knjigaResult = await knjigaProvider.get();

      setState(() {
        wish = wishResult.result.reversed.toList();
        favorites = knjigaResult.result.where((k) => k.isFavorite).toList();
        // Sve knjige u tabeli su već pročitane, pa se ne filtrira po statusu.
        procitane = knjigaResult.result;
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

  /// Boja za konkretan naziv žanra - živopisna, "neon" paleta za svemirski osjećaj.
  /// NAPOMENA: ako `Zanr` model nema polje `naziv`, prilagodi poziv ove funkcije.
  Color colorForGenre(String? naziv) {
    switch (naziv) {
      case "Roman":
        return const Color(0xFFFFD54F); // toplo zlatna
      case "Fantastika":
        return const Color(0xFFBA68C8); // ljubičasta
      case "Triler":
        return const Color(0xFFFF5252); // vatreno crvena
      case "Naučna fantastika":
        return const Color(0xFF40C4FF); // električno plava
      case "Biografija":
        return const Color(0xFFFFAB40); // toplo narandžasta
      case "Poezija":
        return const Color(0xFFFF4081); // pink/magenta
      case "Horor":
        return const Color(0xFF69F0AE); // toksično zelena
      case "Misterija":
        return const Color(0xFF7C4DFF); // indigo
      case "Drama":
        return const Color(0xFF18FFFF); // cyan
      case "Avantura":
        return const Color(0xFFEEFF41); // limun/žuto-zelena
      default:
        if (naziv == null || naziv.isEmpty) return Colors.white70;
        final hash = naziv.hashCode;
        final hue = (hash % 360).abs().toDouble();
        // visoka zasićenost i svjetlina -> "neon" izgled i za nepoznate žanrove
        return HSVColor.fromAHSV(1, hue, 0.75, 1.0).toColor();
    }
  }

  /// Boja zvijezde na osnovu prvog žanra knjige.
  Color getGenreColor(List<Zanr> zanrovi) {
    if (zanrovi.isEmpty) return Colors.white70;
    return colorForGenre(zanrovi.first.naziv);
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

  /// Jedinstveni ključ za knjigu (koristi se za odabranu zvijezdu i seed pozicije).
  String starKeyFor(Knjiga book) =>
      (book.id ?? book.naslov.hashCode).toString();

  /// Izračunava centar svake zvijezde na platnu, bez preklapanja.
  ///
  /// Koraci:
  /// 1. Knjige se grupišu po ocjeni (1-5) u "prstenove" - bolja ocjena znači
  ///    manji radijus (bliže centru), po uzoru na orbite.
  /// 2. Unutar prstena, ugao se raspoređuje ravnomjerno (2π/n po knjizi) +
  ///    mali seeded jitter, umjesto čistog nasumičnog ugla - to samo po sebi
  ///    drastično smanjuje šansu da dvije zvijezde padnu na skoro isto mjesto.
  /// 3. Minimalni radijus je veći od poluprečnika centralne ikonice galaksije
  ///    plus margina, pa nijedna zvijezda ne može fizički pasti na "core".
  /// 4. Relaksacioni prolaz (nekoliko desetina iteracija) na kraju razmakne
  ///    svaki par zvijezda (i zvijezdu-core) koji se i dalje sudaraju.
  Map<String, Offset> computeStarLayout(
    List<Knjiga> books,
    double canvasW,
    double canvasH,
  ) {
    final centerX = canvasW / 2;
    final centerY = canvasH / 2;
    final outerRadius = (min(canvasW, canvasH) / 2) - 30;
    const coreRadius = 30.0; // mora pratiti coreSize u buildGalaxyCore (60px)
    final minRadius = coreRadius + 40; // sigurna udaljenost od centra

    final Map<int, List<Knjiga>> byRating = {};
    for (final b in books) {
      final r = (b.ocjena ?? 0).clamp(1, 5).round();
      byRating.putIfAbsent(r, () => []).add(b);
    }
    for (final list in byRating.values) {
      list.sort((a, b) => starKeyFor(a).compareTo(starKeyFor(b)));
    }

    final Map<String, Offset> centers = {};
    final Map<String, double> sizes = {};

    for (int rating = 5; rating >= 1; rating--) {
      final group = byRating[rating];
      if (group == null || group.isEmpty) continue;

      final normalized = (5 - rating) / 4; // 0 = najbolja, 1 = najlošija
      final ringRadius = minRadius + normalized * (outerRadius - minRadius);
      final n = group.length;

      for (int i = 0; i < n; i++) {
        final book = group[i];
        final rnd = Random(book.id ?? book.naslov.hashCode);
        // ravnomjeran raspored po prstenu + mali jitter da ne bude "u ravnalo"
        final baseAngle = (2 * pi * i / n) + rnd.nextDouble() * 0.35;
        // blaga cik-cak varijacija radijusa unutar prstena
        final radiusJitter = (rnd.nextDouble() - 0.5) * 22;
        final radius =
            (ringRadius + radiusJitter).clamp(minRadius, outerRadius);

        final key = starKeyFor(book);
        centers[key] = Offset(
          centerX + radius * cos(baseAngle),
          centerY + radius * sin(baseAngle),
        );
        sizes[key] = 12.0 + (rating * 7);
      }
    }

    // relaksacija: razmakni sve što se i dalje preklapa
    final keys = centers.keys.toList();
    const iterations = 24;
    for (int iter = 0; iter < iterations; iter++) {
      bool anyOverlap = false;

      for (int i = 0; i < keys.length; i++) {
        final k1 = keys[i];
        var c1 = centers[k1]!;
        final s1 = sizes[k1]!;

        // sudar sa centralnim "core"
        final toCenter = c1 - Offset(centerX, centerY);
        final distToCenter = toCenter.distance;
        final minDist = coreRadius + s1 / 2 + 6;
        if (distToCenter < minDist) {
          anyOverlap = true;
          final dir = distToCenter < 0.001
              ? const Offset(1, 0)
              : toCenter / distToCenter;
          c1 = Offset(centerX, centerY) + dir * minDist;
          centers[k1] = c1;
        }

        for (int j = i + 1; j < keys.length; j++) {
          final k2 = keys[j];
          final c2 = centers[k2]!;
          final s2 = sizes[k2]!;
          final delta = c2 - c1;
          final dist = delta.distance;
          final minSep = (s1 + s2) / 2 + 4;

          if (dist < 0.001) {
            anyOverlap = true;
            centers[k2] = c2 + const Offset(6, 4);
          } else if (dist < minSep) {
            anyOverlap = true;
            final push = (minSep - dist) / 2;
            final dir = delta / dist;
            centers[k1] = c1 - dir * push;
            centers[k2] = c2 + dir * push;
            c1 = centers[k1]!;
          }
        }
      }

      if (!anyOverlap) break;
    }

    return centers;
  }

  /// Jedna zvijezda u sazviježđu - veličina i sjaj zavise od ocjene, boja od
  /// žanra, pozicija dolazi iz unaprijed izračunatog layouta (bez preklapanja).
  /// Klik otvara/zatvara inline karticu.
  Widget buildStar(Knjiga book, Offset center) {
    final ocjena = (book.ocjena ?? 0).clamp(1, 5);
    final size = 12.0 + (ocjena * 7); // ocjena 1-5 -> veličina cca 19-47
    final intensity = ocjena / 5; // veća ocjena -> jači sjaj
    final boja = getGenreColor(book.zanrovi);
    final key = starKeyFor(book);

    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: _TwinklingStar(
        size: size,
        color: boja,
        seed: book.id ?? book.naslov.hashCode,
        intensity: intensity,
        isSelected: selectedStarKey == key,
        onTap: () {
          setState(() {
            selectedStarKey = selectedStarKey == key ? null : key;
          });
        },
      ),
    );
  }

  /// Mala kartica sa detaljima knjige koja se pojavljuje odmah pored kliknute zvijezde.
  Widget buildInfoCard(
    Knjiga book,
    Offset center,
    double containerWidth,
    double containerHeight,
  ) {
    final ocjena = book.ocjena ?? 0;
    final boja = getGenreColor(book.zanrovi);

    const cardWidth = 170.0;
    const cardHeight = 92.0;

    // pokušaj postaviti karticu desno od zvijezde, inače lijevo
    double left = center.dx + 20;
    if (left + cardWidth > containerWidth) left = center.dx - cardWidth - 20;
    if (left < 4) left = 4;

    double top = center.dy - cardHeight / 2;
    if (top + cardHeight > containerHeight)
      top = containerHeight - cardHeight - 4;
    if (top < 4) top = 4;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B).withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: boja, width: 1.2),
          boxShadow: [
            BoxShadow(color: boja.withOpacity(0.4), blurRadius: 12),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    book.naslov ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => selectedStarKey = null),
                  child:
                      const Icon(Icons.close, color: Colors.white54, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.star, color: boja, size: 14),
                const SizedBox(width: 4),
                Text(
                  "$ocjena / 5",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            if (book.zanrovi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                book.zanrovi.map((z) => z.naziv).join(", "),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Centar galaksije - blista kao "core" oko kojeg orbitiraju knjige.
  /// NAPOMENA: `coreSize` ovdje mora ostati usklađen sa `coreRadius` u
  /// `computeStarLayout` (coreRadius = coreSize / 2), inače će razmak koji
  /// štiti core od preklapanja biti pogrešan.
  Widget buildGalaxyCore(double canvasW, double canvasH) {
    final centerX = canvasW / 2;
    final centerY = canvasH / 2;
    const coreSize = 60.0;

    return Positioned(
      left: centerX - coreSize / 2,
      top: centerY - coreSize / 2,
      child: const _GalaxyCore(size: coreSize),
    );
  }

  /// Pozadina nalik svemiru: tamni gradijent + "nebula" mrlje + sitne pozadinske zvjezdice.
  Widget buildGalaxyBackground(double width, double height) {
    final bgStars =
        Random(1234); // fiksni seed - iste pozadinske zvjezdice svaki put

    return Stack(
      children: [
        // bazni gradijent - duboki svemir
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF05060F),
                Color(0xFF1B0E2E),
                Color(0xFF0D1B2A),
              ],
            ),
          ),
        ),

        // nebula mrlje
        Positioned(
          left: -40,
          top: -30,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6A1B9A).withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: -30,
          bottom: -20,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1565C0).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 40,
          top: 10,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEC407A).withOpacity(0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // sitne pozadinske zvjezdice (statička "prašina")
        ...List.generate(45, (i) {
          final dx = bgStars.nextDouble() * width;
          final dy = bgStars.nextDouble() * height;
          final dotSize = 1.0 + bgStars.nextDouble() * 1.8;
          final opacity = 0.25 + bgStars.nextDouble() * 0.55;
          return Positioned(
            left: dx,
            top: dy,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Legenda boja - koji žanr je koja boja, na osnovu svih pročitanih knjiga.
  Widget buildGenreLegend() {
    final genres = <String>{};
    for (final b in procitane) {
      for (final z in b.zanrovi) {
        if (z.naziv != null && z.naziv!.isNotEmpty) {
          genres.add(z.naziv!);
        }
      }
    }

    if (genres.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: genres.map((g) {
          final boja = colorForGenre(g);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: boja,
                  boxShadow: [
                    BoxShadow(color: boja.withOpacity(0.7), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                g,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0xFF1B5E20), Colors.white],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 45, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "MyBooks User",
                      style: TextStyle(
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
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: ListView(
                          children: [
                            /// ❤️ FAVORITES
                            ExpansionTile(
                              leading:
                                  const Icon(Icons.favorite,  color: Color(0xFF1B5E20)),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Favorites",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Tvoje omiljene knjige",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              children: favorites.isEmpty
                                  ? const [
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          "Nema omiljenih knjiga ❤️",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    ]
                                  : favorites.map((book) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),

                                          // 🔥 BORDER
                                          border: Border.all(
                                            color: const Color(0xFF1B5E20)
                                                .withOpacity(0.25),
                                            width: 1.2,
                                          ),

                                          // 💫 SHADOW
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // ICON / COVER
                                            Container(
                                              width: 45,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1B5E20)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.menu_book,
                                                color: Color(0xFF1B5E20),
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            // TEXT
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    book.naslov ?? "",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    book.autor ?? "",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // REMOVE
                                            IconButton(
                                              icon: const Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  removeFavorite(book),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                            ),

                            const SizedBox(height: 10),

                            /// 📌 WISHLIST
                            ExpansionTile(
                              leading: const Icon(Icons.bookmark,
                                  color: Color(0xFF1B5E20)),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Wish lista",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Knjige koje želiš pročitati",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              children: [
                                /// ➕ DUGME
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 12, 12, 6),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: const Text("Dodaj wish knjigu"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF1B5E20),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AddWishKnjigaScreen(),
                                          ),
                                        );
                                        loadData();
                                      },
                                    ),
                                  ),
                                ),

                                /// EMPTY STATE I LISTA
                                if (wish.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      "Wish lista prazna 📌",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                else
                                  ...wish.map((item) {
                                    return Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
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
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey.shade200,
                                                ),
                                                child: (item.slika != null &&
                                                        item.slika!.isNotEmpty)
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.memory(
                                                          base64Decode(
                                                              item.slika!),
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.naslov ?? "",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(item.autor ?? ""),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: getPriorityColor(
                                                                item.prioritet)
                                                            .withOpacity(0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        border: Border.all(
                                                          color: getPriorityColor(
                                                              item.prioritet),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        item.prioritet ?? "",
                                                        style: TextStyle(
                                                          color: getPriorityColor(
                                                              item.prioritet),
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
                                  }),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// ⭐ SAZVIJEŽĐE PROČITANIH KNJIGA
                            ExpansionTile(
                              leading: const Icon(Icons.travel_explore,
                                  color: Color(0xFF1B5E20)),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sazviježđe knjiga",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "🔭 Istraži galaksiju svojih pročitanih knjiga",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              children: [
                                procitane.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          "Još nema pročitanih knjiga ⭐",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        height: 260,
                                        width: double.infinity,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final viewportW =
                                                constraints.maxWidth;
                                            final viewportH =
                                                constraints.maxHeight;

                                            // platno je veće od vidljivog
                                            // okvira - raste sa brojem knjiga
                                            // da zvijezde imaju više prostora
                                            // i manje se guraju na malim
                                            // ekranima; korisnik zumira/
                                            // pomjera pogled po njemu
                                            final canvasW = viewportW +
                                                procitane.length * 26;
                                            final canvasH = viewportH +
                                                procitane.length * 16;

                                            Knjiga? selected;
                                            for (final b in procitane) {
                                              if (starKeyFor(b) ==
                                                  selectedStarKey) {
                                                selected = b;
                                                break;
                                              }
                                            }

                                            // layout se računa jednom po
                                            // veličini platna (deterministički
                                            // po id-u knjige) - garantuje da
                                            // se zvijezde ne preklapaju
                                            final layout = computeStarLayout(
                                                procitane, canvasW, canvasH);

                                            return InteractiveViewer(
                                              constrained: false,
                                              minScale: 1.0,
                                              maxScale: 3.5,
                                              boundaryMargin:
                                                  const EdgeInsets.all(40),
                                              child: SizedBox(
                                                width: canvasW,
                                                height: canvasH,
                                                child: Stack(
                                                  children: [
                                                    buildGalaxyBackground(
                                                        canvasW, canvasH),
                                                    CustomPaint(
                                                      size: Size(
                                                          canvasW, canvasH),
                                                      painter:
                                                          _GenreLinesPainter(
                                                        books: procitane,
                                                        centerOf: (b) =>
                                                            layout[starKeyFor(
                                                                b)] ??
                                                            Offset(canvasW / 2,
                                                                canvasH / 2),
                                                        colorForGenre:
                                                            colorForGenre,
                                                      ),
                                                    ),
                                                    buildGalaxyCore(
                                                        canvasW, canvasH),
                                                    ...procitane.map((book) =>
                                                        buildStar(
                                                            book,
                                                            layout[starKeyFor(
                                                                book)]!)),
                                                    if (selected != null)
                                                      buildInfoCard(
                                                          selected,
                                                          layout[starKeyFor(
                                                              selected)]!,
                                                          canvasW,
                                                          canvasH),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                if (procitane.isNotEmpty)
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
                                    child: Text(
                                      "🔭 Uštipni da zumiraš, prevuci da razgledaš galaksiju",
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ),
                                buildGenreLegend(),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// 🏅 ZNAČKE (uskoro - trenutno samo placeholder)
                            ExpansionTile(
                              leading: Icon(Icons.workspace_premium,
                                  color: Color(0xFF1B5E20)),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Značke",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Nagrade za tvoje čitalačke podvige",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    "Značke uskoro stižu 🏅",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            const ListTile(
                              leading: Icon(Icons.settings),
                              title: Text("Settings"),
                            ),
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
