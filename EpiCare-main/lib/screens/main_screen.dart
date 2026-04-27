import 'package:epilepsy_care_app/models/contact.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'emergency_screen.dart';
import 'profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Contact> contacts = [];
  late List<Widget> _screens =  [];
  @override
  void initState() {
    super.initState();

    _screens=[
      HomeScreen(),
      StatsScreen(),
      EmergencyScreen(),
      ProfileScreen(),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items:  [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "statistics".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: "emergency".tr()),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "profile".tr()),
        ],
      ),
    );
  }
}
