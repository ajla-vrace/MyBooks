import 'package:flutter/material.dart';
import 'package:mybooks_mobile/models/wish_knjiga.dart';
import 'package:mybooks_mobile/providers/wishKnjiga_provider.dart';
import 'package:mybooks_mobile/screens/add_wish_screen.dart';

class WishKnjigaScreen extends StatefulWidget {
  const WishKnjigaScreen({super.key});

  @override
  State<WishKnjigaScreen> createState() => _WishKnjigaScreenState();
}

class _WishKnjigaScreenState extends State<WishKnjigaScreen> {
  List<WishKnjiga> wish = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      var provider = WishKnjigaProvider();
      var result = await provider.get();

      setState(() {
        wish = result.result.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> openAddScreen() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddWishKnjigaScreen(),
      ),
    );

    if (result == true) {
      loadData();
    }
  }

  Future<void> deleteWish(int id) async {
    try {
      var provider = WishKnjigaProvider();
      await provider.delete(id);

      setState(() {
        wish.removeWhere((e) => e.id == id);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Obrisano")),
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
        title: const Text("Brisanje"),
        content: const Text("Da li želiš obrisati ovu knjigu?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ne"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteWish(item.id!);
            },
            child: const Text(
              "Da",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wish lista"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: openAddScreen,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wish.isEmpty
              ? const Center(
                  child: Text(
                    "Nema wish knjiga 📚",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: wish.length,
                  itemBuilder: (context, index) {
                    var item = wish[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TITLE + DELETE
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.naslov ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => confirmDelete(item),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            item.autor ?? "",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// NOTE (QUOTE STYLE)
                          if ((item.napomena ?? "").isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.napomena ?? "",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),

                          /// PRIORITY BADGE
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: getPriorityColor(item.prioritet),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.prioritet ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}