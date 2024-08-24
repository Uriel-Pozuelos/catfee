// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:catfee/layouts/bottom_navigator.dart';
import 'package:catfee/utils/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AdminPage extends StatefulWidget{
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminState();
}


class _AdminState extends State<AdminPage>{
  bool isLoading = false;
  String? userName;
  String? userRol;
  bool isHappy = false;
  // int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAttributes();
  }

  // void _optionSelected(int index){
  //   setState(() {
  //     selectedIndex = index;
  //   });

  //   switch(index){
  //     case 0: 
  //       Navigator.pushNamed(context, '/register');
  //       break;
  //     case 1:
  //       Navigator.pushNamed(context, '/dashboard');
  //       break;
  //   }
  // }


  Future<void> _loadUserAttributes() async {
    Map<String, String>? attributes = await getUserAttributes(['name', 'rol']);
    setState(() {
      userName = attributes?['name'];
      userRol = attributes?['rol'];
    });
  }


  Future<Map<String,dynamic>?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userData');
    if(userData != null){
      return jsonDecode(userData);
    }
    return null;
  }

  Future<Map<String,String>?> getUserAttributes(List<String> att) async {
    Map<String,dynamic>? userData = await getUserData();
    if (userData != null){
      Map<String,String> attributes = {};
      for (String a in att){
        attributes[a] = userData[a];
      }
      return attributes;
    }
    return null;
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catfee'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Text( 
                  'Hola $userName',
                  style: const TextStyle(fontSize: 40.0, color: Colors.black),
            ),
            const SizedBox(height: 40.0),
            const Text('¿Qué deseas hacer?', style: TextStyle(fontSize: 30.0, color: Colors.black),),
            const SizedBox(height: 20.0),

            IconButton(
              tooltip: 'Presiona para cambiar de estado de animo',

              onPressed: () {
                setState(() {
                  isHappy = !isHappy;
                });
              },
              icon: isHappy ? const Icon(Icons.sentiment_very_satisfied, size: 100.0, color: Colors.green) 
                    : const Icon(Icons.sentiment_very_dissatisfied, size: 100.0, color: Colors.red),
            ),

            // ElevatedButton(
            //   onPressed: () {
            //       Navigator.pushNamed(context, '/register');
            //   },
            //   child: const Text('Administrar usuarios'),
            // ),
            // const SizedBox(height: 20.0),

            // ElevatedButton(
            //   onPressed: () {
            //       Navigator.pushNamed(context, '/dashboard');
            //   },
            //   child: const Text('Dashboard'),
            // ),
            // const SizedBox(height: 20.0),
          ],
        )
      ),
      bottomNavigationBar: const BottomNavigator(
        selectedIndex: 1,
        child: SizedBox(),
      )
    );
  }
}