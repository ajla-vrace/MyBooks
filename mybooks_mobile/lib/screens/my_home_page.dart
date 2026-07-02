import 'package:flutter/material.dart';
import 'package:mybooks_mobile/screens/home_screen.dart';
import 'package:mybooks_mobile/screens/citati_screen.dart';
import 'package:mybooks_mobile/screens/knjige_screen.dart';
import 'package:mybooks_mobile/screens/statistika_screen.dart';
import 'package:mybooks_mobile/screens/profil_screen.dart';
import 'package:mybooks_mobile/screens/add_knjiga_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    KnjigeScreen(),
    //SizedBox(), // PLUS dugme placeholder
    AddKnjigaScreen(), // 👈 OVO
    CitatiScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6D8B74),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Knjige",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: "Citati",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
