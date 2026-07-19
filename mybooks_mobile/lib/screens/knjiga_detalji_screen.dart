import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/data/moods.dart';
import 'package:mybooks_mobile/screens/edit_knjiga_screen.dart';

class KnjigaDetaljiScreen extends StatefulWidget {
  final Knjiga knjiga;

  const KnjigaDetaljiScreen({
    super.key,
    required this.knjiga,
  });

  @override
  State<KnjigaDetaljiScreen> createState() => _KnjigaDetaljiScreenState();
}

class _KnjigaDetaljiScreenState extends State<KnjigaDetaljiScreen>
    with SingleTickerProviderStateMixin {
  static const Color primary = Color(0xFF6D8B74);
  static const Color primaryDark = Color(0xFF4E6B54);

  late AnimationController _heartController;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.8,
      upperBound: 1.15,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  Future<void> toggleFavorite() async {
    bool newValue = !(widget.knjiga.isFavorite ?? false);

    setState(() {
      widget.knjiga.isFavorite = newValue;
    });

    _heartController.forward(from: 0.8).then((_) {
      _heartController.animateTo(1.0,
          duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    });

    try {
      var provider = KnjigaProvider();
      await provider.update(widget.knjiga.id!, {
        "isFavorite": newValue,
      });
    } catch (e) {
      setState(() {
        widget.knjiga.isFavorite = !newValue;
      });
    }
  }

  // Otvara ekran za uređivanje knjige. Ako se korisnik vrati sa
  // izmjenama (result == true), osvježavamo prikaz — pretpostavka je
  // da EditKnjigaScreen mijenja isti Knjiga objekat (widget.knjiga) ili
  // vraća true kad su izmjene sačuvane na backendu. Ako tvoj
  // EditKnjigaScreen vraća ažurirani Knjiga objekat umjesto bool-a,
  // javi mi pa prilagodim da se ovdje osvježe konkretna polja iz njega.
  Future<void> editKnjiga() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditKnjigaScreen(knjiga: widget.knjiga),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<void> deleteKnjiga() async {
    setState(() => isDeleting = true);

    try {
      var provider = KnjigaProvider();
      await provider.delete(widget.knjiga.id!);

      if (!mounted) return;
      Navigator.pop(context, true); // javlja prethodnom ekranu da osvježi listu
    } catch (e) {
      if (!mounted) return;
      setState(() => isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri brisanju knjige.")),
      );
    }
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Brisanje knjige"),
        content: Text(
          "Da li ste sigurni da želite obrisati \"${widget.knjiga.naslov ?? ''}\"?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ne"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // zatvori dialog
              await deleteKnjiga();
            },
            child: const Text("Da", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget buildStars(num rating, {double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        if (index < rating.floor()) {
          icon = Icons.star_rounded;
        } else if (index < rating) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, color: const Color(0xFFFFB74D), size: size);
      }),
    );
  }

  /// Pronalazi mood mapu na osnovu teksta spremljenog u knjizi.
  Map<String, String>? get _matchedMood {
    final moodText = widget.knjiga.mood;
    if (moodText == null || moodText.isEmpty) return null;
    try {
      return moods.firstWhere((m) => m["text"] == moodText);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final knjiga = widget.knjiga;
    final isFav = knjiga.isFavorite ?? false;
    final mood = _matchedMood;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Knjiga detalji"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // ===== GRADIENT HEADER =====
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, primaryDark],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        left: -40,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✏️ EDIT — lijevo od srca, ista visina, isti stil
                Positioned(
                  top: 12,
                  right: 60,
                  child: Material(
                    color: Colors.white.withOpacity(0.18),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: editKnjiga,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // ❤️ FAVORITE — gornji desni ugao, ispod app bara
                Positioned(
                  top: 12,
                  right: 12,
                  child: ScaleTransition(
                    scale: _heartController,
                    child: Material(
                      color: Colors.white.withOpacity(0.18),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: toggleFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ===== FLOATING COVER =====
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Hero(
                      tag: 'knjiga-slika-${knjiga.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: (knjiga.slika != null &&
                                  knjiga.slika!.isNotEmpty)
                              ? Image.memory(
                                  base64Decode(knjiga.slika!),
                                  height: 190,
                                  width: 136,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 190,
                                  width: 136,
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    size: 55,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== CONTENT =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 108, 20, 30),
              child: Column(
                children: [
                  Text(
                    knjiga.naslov ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF25322A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    knjiga.autor ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildStars(knjiga.ocjena ?? 0),
                      const SizedBox(width: 8),
                      Text(
                        "${(knjiga.ocjena ?? 0).toStringAsFixed(1)}/5",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                  // ===== MOOD =====
                  if (mood != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mood["emoji"]!,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            mood["text"]!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ===== ŽANROVI =====
                  if (knjiga.zanrovi != null && knjiga.zanrovi!.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: knjiga.zanrovi!.map((z) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primary.withOpacity(.15),
                                primary.withOpacity(.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: primary.withOpacity(.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_offer_rounded,
                                  size: 14, color: primary),
                              const SizedBox(width: 6),
                              Text(
                                z.naziv ?? "",
                                style: const TextStyle(
                                  color: primaryDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 28),

                  // ===== OPIS =====
                  _sectionCard(
                    icon: Icons.menu_book_rounded,
                    title: "Opis",
                    child: Text(
                      knjiga.opis?.isNotEmpty == true
                          ? knjiga.opis!
                          : "Nije unesen opis knjige.",
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ===== RECENZIJA =====
                  _sectionCard(
                    icon: Icons.rate_review_rounded,
                    title: "Recenzija",
                    child: Stack(
                      children: [
                        Positioned(
                          top: -10,
                          right: -6,
                          child: Icon(
                            Icons.format_quote_rounded,
                            size: 60,
                            color: primary.withOpacity(.08),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            knjiga.recenzija?.isNotEmpty == true
                                ? knjiga.recenzija!
                                : "Recenzija nije unesena.",
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== OBRIŠI KNJIGU =====
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isDeleting ? null : showDeleteDialog,
                      icon: isDeleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Icon(Icons.delete_outline_rounded,
                              color: Colors.red),
                      label: Text(
                        isDeleting ? "Brisanje..." : "Obriši knjigu",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF25322A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}