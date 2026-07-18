import 'package:flutter/material.dart';
import 'package:mybooks_mobile/authorization.dart';

import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/models/znacka.dart';

import 'package:mybooks_mobile/providers/citat_provider.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/providers/korisnik_znacka_provider.dart';
import 'package:mybooks_mobile/providers/znacke_provider.dart';
import 'package:mybooks_mobile/widgets/achievement_dialog.dart';

//import 'package:confetti/confetti.dart';

class AddCitatScreen extends StatefulWidget {
  const AddCitatScreen({super.key});

  @override
  State<AddCitatScreen> createState() => _AddCitatScreenState();
}

class _AddCitatScreenState extends State<AddCitatScreen> {
  final _formKey = GlobalKey<FormState>();

  final tekstController = TextEditingController();

  final stranicaController = TextEditingController();

  bool omiljeni = false;

  bool loading = false;

  List<Knjiga> knjige = [];

  Knjiga? selectedKnjiga;

  List<Znacka> sveZnacke = [];

  // late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();

    /* confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );*/

    loadKnjige();

    loadZnacke();
  }

  Future<void> loadKnjige() async {
    try {
      var result = await KnjigaProvider().get(
        filter: {
          "KorisnikId": Authorization.korisnik!.id,
        },
      );

      if (mounted) {
        setState(() {
          knjige = result.result;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadZnacke() async {
    try {
      var result = await ZnackaProvider().get();

      if (mounted) {
        setState(() {
          sveZnacke = result.result;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedKnjiga == null) return;

    setState(() {
      loading = true;
    });

    try {
      // ==============================
      // ZNAČKE PRIJE
      // ==============================

      var znackePrije = await KorisnikZnackaProvider().get(
        filter: {
          "idKorisnik": Authorization.korisnik!.id,
        },
      );

      var stareZnackeIds = znackePrije.result.map((x) => x.znackaId).toSet();

      // ==============================
      // DODAVANJE CITATA
      // ==============================

      await CitatProvider().insert({
        "idKnjiga": selectedKnjiga!.id,
        "tekstCitata": tekstController.text,
        "brojStranice": int.parse(stranicaController.text),
        "jeOmiljeni": omiljeni,
        "korisnikId": Authorization.korisnik!.id,
      });

      // čekanje backend ProvjeriZnacke

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      // ==============================
      // ZNAČKE POSLIJE
      // ==============================

      var znackePoslije = await KorisnikZnackaProvider().get(
        filter: {
          "idKorisnik": Authorization.korisnik!.id,
        },
      );

      var noveZnackeIds = znackePoslije.result
          .map((x) => x.znackaId)
          .toSet()
          .difference(stareZnackeIds);

      // ==============================
      // PRONAĐI OBJEKTE ZNAČKI
      // ==============================

      List<Znacka> osvojene = [];

      for (var id in noveZnackeIds) {
        var znacka = sveZnacke.firstWhere(
          (x) => x.id == id,
        );

        osvojene.add(znacka);
      }

      // ==============================
      // PRIKAŽI SVE ODJEDNOM
      // ==============================

      if (osvojene.isNotEmpty && mounted) {
        await AchievementDialog.show(
          context,
          osvojene,
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      String poruka = "Nevalidan unos. Provjeri podatke.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(poruka),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

/*Future<void> showMultipleAchievementDialog(
  List<Znacka> znacke,
) async {


  confettiController.play();



  await showDialog(

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



            content: SizedBox(

              width: double.maxFinite,


              child: Column(

                mainAxisSize: MainAxisSize.min,


                children: [





                  Container(

                    width: 110,

                    height: 110,


                    decoration: BoxDecoration(

                      shape: BoxShape.circle,


                      color: Colors.amber
                          .withOpacity(0.15),


                      boxShadow: [


                        BoxShadow(

                          color: Colors.amber
                              .withOpacity(0.6),


                          blurRadius: 30,


                          spreadRadius: 8,

                        )

                      ],

                    ),



                    child: const Center(

                      child: Text(

                        "🏆",

                        style: TextStyle(

                          fontSize: 65,

                        ),

                      ),

                    ),

                  ),





                  const SizedBox(height: 20),






                  Text(

                    znacke.length == 1

                    ? "Nova značka otključana 🎉"

                    : "Osvojio si ${znacke.length} nove značke 🎉",


                    textAlign: TextAlign.center,


                    style: const TextStyle(

                      fontSize: 21,

                      fontWeight: FontWeight.bold,

                    ),

                  ),





                  const SizedBox(height: 20),





                  SizedBox(

                    height: 220,


                    child: ListView.builder(


                      itemCount: znacke.length,


                      itemBuilder: (context,index){


                        var z = znacke[index];



                        return Container(

                          margin:
                              const EdgeInsets.only(
                                bottom: 12,
                              ),



                          padding:
                              const EdgeInsets.all(12),



                          decoration: BoxDecoration(

                            color:
                                Colors.amber
                                .withOpacity(0.08),


                            borderRadius:
                                BorderRadius.circular(15),


                            border: Border.all(

                              color:
                              Colors.amber
                              .withOpacity(0.4),

                            ),

                          ),





                          child: Row(

                            children: [



                              Text(

                                z.ikonica ?? "🏆",

                                style:
                                const TextStyle(

                                  fontSize: 40,

                                ),

                              ),




                              const SizedBox(width: 15),





                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,


                                  children: [


                                    Text(

                                      z.naziv ?? "",


                                      style:
                                      const TextStyle(

                                        fontSize: 17,

                                        fontWeight:
                                        FontWeight.bold,

                                      ),

                                    ),





                                    const SizedBox(height: 5),





                                    Text(

                                      z.opis ?? "",


                                      style:
                                      const TextStyle(

                                        fontSize: 13,

                                      ),

                                    ),



                                  ],

                                ),

                              )



                            ],

                          ),


                        );


                      },

                    ),

                  ),



                ],

              ),

            ),





            actionsAlignment:
            MainAxisAlignment.center,



            actions: [



              ElevatedButton(


                style:
                ElevatedButton.styleFrom(


                  backgroundColor:
                  const Color(0xFF1B5E20),


                  shape:
                  RoundedRectangleBorder(


                    borderRadius:
                    BorderRadius.circular(20),


                  ),


                  padding:
                  const EdgeInsets.symmetric(

                    horizontal: 30,

                    vertical: 12,

                  ),


                ),



                onPressed: (){


                  Navigator.pop(context);


                },



                child: const Text(

                  "Nastavi čitati 📚",

                  style:
                  TextStyle(

                    color: Colors.white,

                    fontSize: 16,

                  ),

                ),

              ),


            ],


          ),






          // 🎉 KONFETI



          Positioned.fill(


            child: IgnorePointer(


              child: ConfettiWidget(


                confettiController:
                confettiController,


                blastDirectionality:
                BlastDirectionality.explosive,


                numberOfParticles: 120,


                gravity: 0.20,


                emissionFrequency: 0.04,


                shouldLoop: false,


              ),

            ),

          )



        ],


      );


    },


  );


}*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dodaj citat",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<Knjiga>(
                value: selectedKnjiga,
                items: knjige.map((k) {
                  return DropdownMenuItem<Knjiga>(
                    value: k,
                    child: Text(
                      k.naslov ?? "",
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKnjiga = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Izaberi knjigu",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return "Izaberi knjigu";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: tekstController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Tekst citata",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Unesi citat";
                  }

                  if (value.trim().length < 20) {
                    return "Citat mora imati najmanje 20 znakova";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: stranicaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Broj stranice",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Unesi broj stranice";
                  }

                  if (int.tryParse(value) == null) {
                    return "Mora biti broj";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text(
                  "Omiljeni citat",
                ),
                value: omiljeni,
                onChanged: (value) {
                  setState(() {
                    omiljeni = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : save,
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Spasi",
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //confettiController.dispose();

    tekstController.dispose();

    stranicaController.dispose();

    super.dispose();
  }
}
