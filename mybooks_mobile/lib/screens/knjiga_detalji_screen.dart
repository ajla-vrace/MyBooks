import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';

class KnjigaDetaljiScreen extends StatefulWidget {
  final Knjiga knjiga;

  const KnjigaDetaljiScreen({
    super.key,
    required this.knjiga,
  });

  @override
  State<KnjigaDetaljiScreen> createState() => _KnjigaDetaljiScreenState();
}

class _KnjigaDetaljiScreenState extends State<KnjigaDetaljiScreen> {
  Future<void> toggleFavorite() async {
    bool newValue = !(widget.knjiga.isFavorite ?? false);

    setState(() {
      widget.knjiga.isFavorite = newValue;
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

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.knjiga.naslov ?? "Detalji knjige"),
        backgroundColor: const Color(0xFF6D8B74),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 280,
              decoration: const BoxDecoration(
                color: Color(0xFF6D8B74),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (widget.knjiga.slika != null &&
                            widget.knjiga.slika!.isNotEmpty)
                        ? Image.memory(
                            base64Decode(widget.knjiga.slika!),
                            height: 220,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 220,
                            width: 160,
                            color: Colors.white,
                            child: const Icon(
                              Icons.menu_book,
                              size: 70,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE + FAVORITE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.knjiga.naslov ?? "",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: toggleFavorite,
                        icon: Icon(
                          widget.knjiga.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// AUTHOR
                  Text(
                    widget.knjiga.autor ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      buildStars(widget.knjiga.ocjena ?? 0),
                      const Spacer(),
                      GestureDetector(
                        onTap: toggleFavorite,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          /*child: Icon(
                            widget.knjiga.isFavorite == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            key: ValueKey(widget.knjiga.isFavorite),
                            color: Colors.red,
                            size: 30,
                          ),*/
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// =========================
                  /// 🏷 ŽANROVI
                  /// =========================
                  if (widget.knjiga.zanrovi != null &&
                      widget.knjiga.zanrovi!.isNotEmpty) ...[
                    const Text(
                      "Žanr",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.knjiga.zanrovi!.map((z) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6D8B74).withOpacity(.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF6D8B74),
                            ),
                          ),
                          child: Text(
                            z.naziv ?? "",
                            style: const TextStyle(
                              color: Color(0xFF6D8B74),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                  ],

                  /// =========================
                  /// 📖 OPIS
                  /// =========================
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF6D8B74),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Opis",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.knjiga.opis?.isNotEmpty == true
                        ? widget.knjiga.opis!
                        : "Nije unesen opis knjige.",
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// =========================
                  /// 📝 RECENZIJA
                  /// =========================
                  Row(
                    children: [
                      Icon(
                        Icons.rate_review_rounded,
                        color: Color(0xFF6D8B74),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Recenzija",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.knjiga.recenzija?.isNotEmpty == true
                          ? widget.knjiga.recenzija!
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
