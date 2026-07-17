import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:mybooks_mobile/authorization.dart';

import 'dart:convert';

import 'package:mybooks_mobile/models/knjiga.dart';

import 'package:mybooks_mobile/models/korisnik_znacka.dart';

import 'package:mybooks_mobile/models/statistika.dart';

import 'package:mybooks_mobile/models/zanr.dart';

import 'package:mybooks_mobile/models/znacka.dart';

import 'package:mybooks_mobile/providers/knjiga_provider.dart';

import 'package:mybooks_mobile/providers/statistika_provider.dart';

import 'package:mybooks_mobile/models/wish_knjiga.dart';

import 'package:mybooks_mobile/providers/korisnik_znacka_provider.dart';

import 'package:mybooks_mobile/providers/wishKnjiga_provider.dart';

import 'package:mybooks_mobile/providers/znacke_provider.dart';

import 'package:mybooks_mobile/screens/add_wish_screen.dart';

import 'package:mybooks_mobile/screens/login_screen.dart';

/// Zvijezda koja "živi" - blago pulsira sjajem i veličinom, svaka svojim
/// tempom (seed po knjizi), tako da cijelo sazviježđe djeluje živo i asinhrono.
/// `intensity` (0..1, obično = ocjena/5) diže fiksnu bazu sjaja i blur/spread,
/// tako da bolje ocijenjene knjige "gore" jače, nezavisno od pulsiranja.
///
/// `playing` kontroliše da li kontroler uopšte animira - kad je sekcija sa
/// sazviježđem zatvorena (ExpansionTile collapsed), `playing` treba biti
/// false da se izbjegne besmisleno trošenje CPU/GPU-a na desetine tickera
/// koji rade u pozadini i uzrokuju jank (npr. trzajući skrol) na ostatku
/// ekrana, uključujući sekcije poput Značke.
class _TwinklingStar extends StatefulWidget {
  final double size;
  final Color color;
  final int seed;
  final bool isSelected;
  final double intensity;
  final bool playing;
  final VoidCallback onTap;

  const _TwinklingStar({
    required this.size,
    required this.color,
    required this.seed,
    required this.onTap,
    this.isSelected = false,
    this.intensity = 0.6,
    this.playing = true,
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
    if (widget.playing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _TwinklingStar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // pokreni/zaustavi animaciju kad se promijeni vidljivost sekcije -
    // sprječava da desetine zvijezda animiraju u pozadini dok je
    // ExpansionTile zatvoren
    if (widget.playing && !oldWidget.playing) {
      _controller.repeat(reverse: true);
    } else if (!widget.playing && oldWidget.playing) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
  bool shouldRepaint(covariant _GenreLinesPainter oldDelegate) =>
      oldDelegate.books != books;
}

/// Centar galaksije - veći, "mirniji" i jače usijan sjaj od zvijezda, da se
/// odmah vizuelno izdvoji kao gravitaciono središte oko kojeg sve orbitira.
///
/// `playing` (vidi napomenu kod `_TwinklingStar`) kontroliše da li animacija
/// uopšte radi - kad je sazviježđe skupljeno, core ne animira.
class _GalaxyCore extends StatefulWidget {
  final double size;
  final bool playing;

  const _GalaxyCore({required this.size, this.playing = true});

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
    );
    if (widget.playing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _GalaxyCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing && !oldWidget.playing) {
      _controller.repeat(reverse: true);
    } else if (!widget.playing && oldWidget.playing) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
                  color: Colors.white.withOpacity((0.8 * glow).clamp(0.0, 1.0)),
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
  List<Znacka> sveZnacke = [];
  List<int> otkljucaneZnacke = [];
  List<KorisnikZnacka> znacke = [];
  Statistika? statistika;
  String? selectedStarKey;

  // Da li je sekcija sa sazviježđem trenutno otvorena - animacije zvijezda
  // i core-a se pale/gase u zavisnosti od ovoga, umjesto da rade
  // neprestano u pozadini (što je uzrokovalo trzajući skrol drugdje na
  // ekranu, npr. u sekciji Značke).
  bool constellationExpanded = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
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

      var sveZnackeResult = await sveZnackeProvider.get();

      var statistikaProvider = StatistikaProvider();
      var statistikaResult =
          await statistikaProvider.getStatistika(Authorization.korisnik!.id);

      setState(() {
        wish = wishResult.result.reversed.toList();
        favorites = knjigaResult.result.where((k) => k.isFavorite).toList();
        // Sve knjige u tabeli su već pročitane, pa se ne filtrira po statusu.
        procitane = knjigaResult.result;
        sveZnacke = sveZnackeResult.result;
        znacke = znackaResult.result;
        otkljucaneZnacke = znackaResult.result.map((x) => x.znackaId!).toList();
        statistika = statistikaResult;
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

  /// Ista "porodica" boja kao `colorForGenre`, ali prigušena za svijetlu
  /// pozadinu (koristi se u Naprednoj statistici/DNK-u). `colorForGenre`
  /// je namjerno neon-zasićena za tamnu svemirsku pozadinu sazviježđa, pa
  /// tu istu paletu na bijeloj kartici djeluje presirovo - ovdje se ista
  /// boja (isti hue) samo spusti na nižu zasićenost i svjetlinu.
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
        playing: constellationExpanded,
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
      child: _GalaxyCore(size: coreSize, playing: constellationExpanded),
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

  Widget buildZanrovskiDnk() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Žanrovski DNK 🧬",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          if (statistika == null ||
              statistika!.zanrovskiDNK == null ||
              statistika!.zanrovskiDNK!.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Nema dovoljno podataka za statistiku 🧬",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: statistika!.zanrovskiDNK!
                    .map((z) => buildDnkRow(z))
                    .toList(),
              ),
            ),
        ],
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

    // Isti padding, veličina naslova i visina traka kao Žanrovski DNK,
    // da obje sekcije vizuelno budu istog "gabarita".
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Histogram ocjena ⭐",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
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
                          fontWeight: FontWeight.w600, fontSize: 13),
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
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF1B5E20)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 25,
                    child: Text(
                      "${e.broj}",
                      textAlign: TextAlign.end,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Jedan red žanrovskog DNK-a: naziv žanra, procenat + broj knjiga i
  /// animirana traka napunjena prema procentu zastupljenosti tog žanra.
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

  /// Boja po nivou značke - fiksna "tier" skala, ista za sve porodice
  /// znački (knjige, citati...) jer je vezana za `nivo`, a ne za `Tip`.
  /// NAPOMENA: pretpostavljam da `Znacka` ima polje `nivo` (int?, 1-5).
  /// Ako se polje zove drugačije, samo prilagodi `znacka.nivo` pozive niže.
  Color colorForNivo(int? nivo) {
    switch (nivo) {
      case 1:
        return const Color(0xFFCD7F32); // bronza
      case 2:
        return const Color(0xFF9E9E9E); // srebro
      case 3:
        return const Color(0xFFFFC107); // zlato
      case 4:
        return const Color(0xFF29B6F6); // platina
      case 5:
        return const Color(0xFF66BB6A); // smaragd
      case 6:
        return const Color(0xFFAB47BC); // dijamant/ljubičasta
      default:
        return const Color(0xFF1B5E20); // fallback - značke bez nivoa
    }
  }

  /// Naziv nivoa za naslov sekcije u prikazu značke po nivoima.
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

  /// Jedna značka: obojena prema nivou ako je otključana, siva ako nije.
  /// Klik otvara isti popup sa opisom i datumom otključavanja kao i prije.
  Widget buildZnackaBadge(Znacka znacka) {
    final bool otkljucana = otkljucaneZnacke.contains(znacka.id);
    final boja = colorForNivo(znacka.nivo);

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
                position.dy - 170,
                position.dx + 120,
                position.dy,
              ),
              items: [
                PopupMenuItem(
                  enabled: false,
                  child: SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              znacka.ikonica ?? "🏅",
                              style: const TextStyle(fontSize: 28),
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
                          znacka.opis ?? "Nema opisa",
                          style: const TextStyle(fontSize: 13),
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
                            color: boja.withOpacity(0.35),
                            blurRadius: 6,
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Opacity(
                    opacity: otkljucana ? 1 : 0.25,
                    child: Text(
                      znacka.ikonica ?? "🏅",
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 90,
                child: Text(
                  znacka.naziv ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: otkljucana ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sve značke grupisane po nivou (1-5), svaki nivo sa svojim naslovom
  /// i bojom - otključane značke nose boju svog nivoa, zaključane su sive.
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
                          // čuva scroll poziciju liste po PageStorageKey-u i
                          // sprječava da Flutter pomiješa stanje ExpansionTile
                          // widgeta prilikom rebuilda (npr. resize prozora)
                          key: const PageStorageKey('profile_list'),
                          children: [
                            /// ❤️ FAVORITES
                            ExpansionTile(
                              key: const PageStorageKey('tile_favorites'),
                              leading: const Icon(Icons.favorite,
                                  color: Color(0xFF1B5E20)),
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
                              key: const PageStorageKey('tile_wishlist'),
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
                              key: const PageStorageKey('tile_constellation'),
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
                              // animacije zvijezda/core-a se pale samo dok je
                              // sekcija otvorena - kad se zatvori, prestaju
                              // odmah da rade u pozadini
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  constellationExpanded = expanded;
                                  if (!expanded) {
                                    selectedStarKey = null;
                                  }
                                });
                              },
                              children: [
                                procitane.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          "Još nema pročitanih knjiga ⭐",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    // RepaintBoundary izolira konstantno
                                    // animirano sazviježđe od ostatka
                                    // ListView-a, tako da njegovi repaintovi
                                    // ne izazivaju dodatni rad (i jank) na
                                    // ostalim sekcijama, npr. pri skrolu
                                    : RepaintBoundary(
                                        child: Container(
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
                                                              Offset(
                                                                  canvasW / 2,
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

                            /// 🧬 NAPREDNA STATISTIKA
                            ExpansionTile(
                              key: const PageStorageKey('tile_stats'),
                              leading: const Icon(Icons.insights,
                                  color: Color(0xFF1B5E20)),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Napredna statistika",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Dublji uvid u tvoje čitalačke navike",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              children: [
                                /*Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 8, 14, 4),
                                  child: Text(
                                    "Žanrovski DNK 🧬",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                if (statistika == null ||
                                    statistika!.zanrovskiDNK == null ||
                                    statistika!.zanrovskiDNK!.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(14, 4, 14, 12),
                                    child: Text(
                                      "Nema dovoljno podataka za statistiku 🧬",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        14, 6, 14, 12),
                                    child: Column(
                                      children: statistika!.zanrovskiDNK!
                                          .map((z) => buildDnkRow(z))
                                          .toList(),
                                    ),
                                  ),*/
                                const SizedBox(height: 30),
                                buildZanrovskiDnk(),
                                const SizedBox(height: 30),
                                buildHistogramOcjena(),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// 🏅 ZNAČKE
                            ExpansionTile(
                              //maintainState: true,
                              key: const PageStorageKey('tile_badges'),
                              leading: const Icon(
                                Icons.workspace_premium,
                                color: Color(0xFF1B5E20),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Značke",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Nagrade za tvoje čitalačke podvige",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                // RepaintBoundary izolira ovaj (skup, jer
                                // sadrži dosta blurane BoxShadow grafike po
                                // znački) podstablo od ostatka ListView-a, da
                                // skrolanje tokom/nakon otvaranja sekcije ne
                                // izazove trzajuće iscrtavanje cijele liste
                                /*RepaintBoundary(
                                  child: buildZnackeByNivo(),
                                ),*/
                                buildZnackeByNivo(),
                              ],
                            ),

                            const SizedBox(height: 20),

                            const ListTile(
                              leading: Icon(Icons.settings),
                              title: Text("Settings"),
                            ),

                            const Divider(),

                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: const Text(
                                "Odjava",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
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
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
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
                              },
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
