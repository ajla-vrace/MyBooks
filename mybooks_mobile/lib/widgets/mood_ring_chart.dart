import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mybooks_mobile/models/statistika.dart';

class MoodRingChart extends StatelessWidget {
  final List<MoodStatistika> moods;

  const MoodRingChart({
    super.key,
    required this.moods,
  });


  // ============================
  // ZAJEDNIČKI STILOVI
  // ============================

  static const TextStyle centerMoodStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF263238),
  );

  static const TextStyle rowMoodStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF37474F),
  );

  static const TextStyle valueStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF455A64),
  );


  @override
  Widget build(BuildContext context) {

    if (moods.isEmpty) {
      return const Center(
        child: Text(
          "Nema podataka",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }


    final ukupno = moods.fold<int>(
      0,
      (sum, e) => sum + (e.broj ?? 0),
    );


    final maxCount = moods
        .map((e) => e.broj ?? 0)
        .reduce((a, b) => a > b ? a : b);


    final winners =
        moods.where((e) => (e.broj ?? 0) == maxCount).toList();


    final hasDominantMood = winners.length == 1;

    final topMood =
        hasDominantMood ? winners.first : null;



    return Column(
      children: [

        SizedBox(
          width: 240,
          height: 240,

          child: Stack(
            alignment: Alignment.center,

            children: [

              CustomPaint(
                size: const Size(240,240),

                painter: MoodRingPainter(
                  moods: moods,
                  total: ukupno,
                ),
              ),



              // CENTAR RINGA

              Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  if(hasDominantMood) ...[


                    Text(
                      getEmoji(topMood!.mood ?? ""),
                      style: const TextStyle(
                        fontSize: 42,
                      ),
                    ),


                    const SizedBox(height: 6),


                    Text(
                      topMood.mood ?? "",

                      textAlign: TextAlign.center,

                      style: centerMoodStyle,
                    ),


                    const SizedBox(height: 4),


                    Text(
                      "${((topMood.broj! / ukupno) * 100).toStringAsFixed(0)}%",

                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),


                  ] else ...[


                    const Text(
                      "🌈",

                      style: TextStyle(
                        fontSize: 42,
                      ),
                    ),


                    const SizedBox(height: 8),


                    const Text(
                      "Raznolike\nemocije",

                      textAlign: TextAlign.center,

                      style: centerMoodStyle,
                    ),

                  ]

                ],
              )
            ],
          ),
        ),



        const SizedBox(height: 24),



        // LEGENDA

        ...moods.asMap().entries.map((entry){

          final index = entry.key;

          final mood = entry.value;


          final percent = ukupno == 0
              ? 0
              : ((mood.broj ?? 0) / ukupno * 100);



          return Padding(

            padding:
                const EdgeInsets.symmetric(vertical: 6),


            child: Row(

              children: [


                Container(

                  width: 12,
                  height: 12,

                  decoration: BoxDecoration(

                    color: getColor(index),

                    shape: BoxShape.circle,

                  ),
                ),



                const SizedBox(width: 12),



                Text(

                  getEmoji(mood.mood ?? ""),

                  style: const TextStyle(
                    fontSize: 20,
                  ),

                ),



                const SizedBox(width: 8),



                Expanded(

                  child: Text(

                    mood.mood ?? "",

                    style: rowMoodStyle,

                  ),

                ),



                Text(

                  "${mood.broj} (${percent.toStringAsFixed(0)}%)",

                  style: valueStyle,

                )

              ],
            ),
          );


        }).toList(),

      ],
    );
  }





  // ============================
  // BOJE MOODOVA
  // ============================

  static Color getColor(int index){

    final colors = [

      const Color(0xFF81C784), // sretna
      const Color(0xFFFFB74D), // topla
      const Color(0xFFBA68C8), // inspiracija
      const Color(0xFF64B5F6), // mir
      const Color(0xFFE57373), // tuga
      const Color(0xFFFF8A65), // šok
      const Color(0xFF9575CD), // razmišljanje
      const Color(0xFFF06292), // ljubav
      const Color(0xFF90A4AE), // neutralna
      const Color(0xFFA1887F), // razočaranje

    ];


    return colors[index % colors.length];

  }




  static String getEmoji(String mood){

    switch(mood){

      case "Oduševljena":
        return "😊";

      case "Dirnuta":
        return "😢";

      case "Inspirisana":
        return "🤩";

      case "Opuštena":
        return "😌";

      case "Tužna":
        return "😭";

      case "Šokirana":
        return "😱";

      case "Natjerala me na razmišljanje":
        return "🤔";

      case "Nova omiljena":
        return "😍";

      case "Ravnodušna":
        return "😐";

      case "Razočarana":
        return "😤";


      default:
        return "📚";
    }

  }

}






class MoodRingPainter extends CustomPainter {


  final List<MoodStatistika> moods;

  final int total;



  MoodRingPainter({

    required this.moods,

    required this.total,

  });





  @override
  void paint(Canvas canvas, Size size){


    final rect = Offset.zero & size;



    final paint = Paint()

      ..style = PaintingStyle.stroke

      ..strokeWidth = 24

      ..strokeCap = StrokeCap.round;



    double start = -pi / 2;



    for(int i = 0; i < moods.length; i++){


      final sweep =
          ((moods[i].broj ?? 0) / total) * 2 * pi;



      paint.color =
          MoodRingChart.getColor(i);



      canvas.drawArc(

        rect.deflate(20),

        start,

        sweep,

        false,

        paint,

      );



      start += sweep;

    }

  }




  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate
  ) => true;

}