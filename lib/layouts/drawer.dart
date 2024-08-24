
import 'package:flutter/material.dart';

class DrawerLayout extends StatelessWidget {
  final Widget child;

  const DrawerLayout({super.key, required this.child}) ;

  @override
  Widget build(BuildContext context){
    
    return Drawer(
          child: Container(
            color:const Color.fromARGB(255, 34, 41, 47),
            child: child,
          ),  
    );
  }
}