import 'package:flutter/material.dart';
import '../models/znacka.dart';


class ZnackaBadge extends StatelessWidget {

  final Znacka znacka;
  final bool unlocked;
  final double size;


  const ZnackaBadge({
    super.key,

    required this.znacka,

    required this.unlocked,

    this.size = 75,
  });



  Color getNivoColor(){

    switch(znacka.nivo){

      case 1:
        return const Color(0xFFCD7F32);

      case 2:
        return const Color(0xFF9E9E9E);

      case 3:
        return const Color(0xFFFFC107);

      case 4:
        return const Color(0xFF29B6F6);

      case 5:
        return const Color(0xFF66BB6A);

      case 6:
        return const Color(0xFFAB47BC);

      default:
        return const Color(0xFF1B5E20);
    }
  }



  @override
  Widget build(BuildContext context) {


    final boja = getNivoColor();


    return Column(

      mainAxisSize: MainAxisSize.min,

      children: [

        Container(

          width:size,

          height:size,


          decoration:BoxDecoration(

            shape:BoxShape.circle,


            color:

              unlocked

              ? boja.withOpacity(0.15)

              : Colors.grey.withOpacity(0.15),



            border:Border.all(

              color:

                unlocked

                ? boja

                : Colors.grey.shade400,


              width:1.8,

            ),



            boxShadow:

              unlocked

              ? [

                  BoxShadow(

                    color:
                      boja.withOpacity(0.45),

                    blurRadius:20,

                    spreadRadius:2,

                  ),

                ]

              : [],

          ),



          child:Center(

            child:Opacity(

              opacity:
                unlocked ? 1 : 0.25,


              child:Text(

                znacka.ikonica ?? "🏆",


                style:TextStyle(

                  fontSize:size * 0.55,

                ),

              ),

            ),

          ),

        ),


        const SizedBox(height:6),


        SizedBox(

          width:size + 20,

          child:Text(

            znacka.naziv ?? "",


            textAlign:TextAlign.center,


            maxLines:2,

            overflow:
              TextOverflow.ellipsis,


            style:TextStyle(

              fontSize:12,

              fontWeight:
                FontWeight.bold,


              color:

                unlocked

                ? Colors.black

                : Colors.grey,

            ),

          ),

        ),

      ],

    );
  }
}