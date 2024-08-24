import 'package:flutter/material.dart';

class BottomNavigator extends StatefulWidget {
  final Widget child;
  final int selectedIndex;

  const BottomNavigator({super.key, required this.child, required this.selectedIndex});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int selectedIndex = 0;

  void _optionSelected(int index) {
    
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/register');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 2: 
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.lightBlue[300],
      elevation: 2,
      iconSize: 30,
      selectedIconTheme: const IconThemeData(size: 35, color: Colors.white),
      unselectedIconTheme: const IconThemeData(size: 30, color: Colors.black),

      
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Gestion de usuarios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Dashboard',
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.white,
      onTap: _optionSelected,
    );
  }
}