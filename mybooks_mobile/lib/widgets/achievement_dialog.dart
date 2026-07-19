import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/znacka.dart';

class AchievementDialog {
  static Future<void> show(
    BuildContext context,
    List<Znacka> znacke,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AchievementDialogContent(znacke: znacke),
    );
  }
}

class _AchievementDialogContent extends StatefulWidget {
  final List<Znacka> znacke;

  const _AchievementDialogContent({required this.znacke});

  @override
  State<_AchievementDialogContent> createState() =>
      _AchievementDialogContentState();
}

class _AchievementDialogContentState
    extends State<_AchievementDialogContent> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _controller.play();
  }

  @override
  void dispose() {
    // Kontroler je vezan za State ovog widgeta, pa Flutter garantuje da
    // se dispose() ovdje poziva TEK kad je widget zaista uklonjen iz
    // stabla (nakon eventualne exit animacije dijaloga). Djeca
    // (uključujući ConfettiWidget) se uvijek dispose-uju PRIJE roditelja,
    // pa je redoslijed uvijek ispravan - za razliku od ručnog dispose-a
    // pozvanog izvana nakon proizvoljnog broja frame-ova.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Center(
            child: Text(
              "Nove značke otključane 🎉",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.znacke.map((znacka) {
              return Container(
                margin: const EdgeInsets.only(
                  bottom: 15,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withOpacity(0.15),
                      ),
                      child: Center(
                        child: Text(
                          znacka.ikonica ?? "🏆",
                          style: const TextStyle(
                            fontSize: 35,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            znacka.naziv ?? "",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            znacka.opis ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Nastavi čitati 📚",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
        Positioned(
          top: -100,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 100,
            gravity: 0.15,
            emissionFrequency: 0.05,
          ),
        )
      ],
    );
  }
}