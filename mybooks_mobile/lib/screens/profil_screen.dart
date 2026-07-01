import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mybooks_mobile/models/knjiga.dart';
import 'package:mybooks_mobile/providers/knjiga_provider.dart';
import 'package:mybooks_mobile/models/wish_knjiga.dart';
import 'package:mybooks_mobile/providers/wishKnjiga_provider.dart';
import 'package:mybooks_mobile/screens/add_wish_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<WishKnjiga> wish = [];
  List<Knjiga> favorites = [];

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
                                  const Icon(Icons.favorite, color: Colors.red),
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
                                                child: (item.slika !=
                                                            null &&
                                                        item.slika!
                                                            .isNotEmpty)
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: Image.memory(
                                                          base64Decode(item
                                                              .slika!),
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
