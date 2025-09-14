import 'package:flutter/material.dart';
import 'package:indrive_car_condition/screens/history_screen.dart';
import 'package:indrive_car_condition/screens/landing_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectIndex = 0;

  List<Widget> screens = [
    const LandingScreen(),
    const HistoryScreen(),
  ];

  void onTap(int index) {
    setState(() {
      _selectIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: screens[_selectIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectIndex,
          onTap: onTap,
          selectedItemColor: Color(0xff32D583),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.download), label: 'Загрузить'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined), label: 'История'),
          ],
        ));
  }
}
