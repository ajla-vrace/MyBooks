import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/znacka.dart';


class AchievementDialog {


 static Future<void> show(
  BuildContext context,
  List<Znacka> znacke,
) async{

    final controller = ConfettiController(
      duration: const Duration(seconds: 3),
    );


    controller.play();



    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (context){

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
                    fontSize:21,
                    fontWeight: FontWeight.bold,
                  ),

                ),

              ),



              content: Column(

                mainAxisSize: MainAxisSize.min,

                children:

                znacke.map((znacka){


                  return Container(

                    margin: const EdgeInsets.only(
                      bottom:15,
                    ),


                    padding: const EdgeInsets.all(12),


                    decoration: BoxDecoration(

                      color: Colors.amber.withOpacity(0.08),

                      borderRadius:
                      BorderRadius.circular(15),


                      border: Border.all(

                        color:
                        Colors.amber.withOpacity(0.4),

                      ),

                    ),



                    child: Row(

                      children: [


                        Container(

                          width:60,
                          height:60,

                          decoration: BoxDecoration(

                            shape: BoxShape.circle,

                            color:
                            Colors.amber.withOpacity(0.15),

                          ),


                          child: Center(

                            child: Text(

                              znacka.ikonica ?? "🏆",

                              style:
                              const TextStyle(
                                fontSize:35,
                              ),

                            ),

                          ),

                        ),



                        const SizedBox(width:15),



                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,


                            children:[


                              Text(

                                znacka.naziv ?? "",

                                style:
                                const TextStyle(

                                  fontSize:17,

                                  fontWeight:
                                  FontWeight.bold,

                                ),

                              ),



                              const SizedBox(height:5),



                              Text(

                                znacka.opis ?? "",

                                style:
                                const TextStyle(
                                  fontSize:14,
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



              actions:[


                Center(

                  child:

                  TextButton(

                    onPressed:(){

                      Navigator.pop(context);

                    },

                    child:

                    const Text(
                      "Nastavi čitati 📚",
                      style:
                      TextStyle(
                        fontSize:16,
                      ),
                    ),

                  ),

                )


              ],


            ),




            Positioned(

              top:-100,

              child:

              ConfettiWidget(

                confettiController:
                controller,


                blastDirectionality:
                BlastDirectionality.explosive,


                numberOfParticles:
                100,


                gravity:
                0.15,


                emissionFrequency:
                0.05,


              ),

            )


          ],

        );


      },

    ).then((_){

      controller.dispose();

    });


  }


}