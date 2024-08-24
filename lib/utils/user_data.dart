import 'dart:convert';
import 'package:catfee/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Usuario?> getUserData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userData = prefs.getString('userData');

  if (userData != null) {
    final Map<String, dynamic> userMapData = jsonDecode(userData);
    return Usuario.fromJson(userMapData);
  }
  return null;
}

Future<void> logout(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userData');
  
  Navigator.pushReplacementNamed(context, '/login');
}