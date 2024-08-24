import 'package:catfee/models/carrito.dart';
import 'package:catfee/pages/admin.dart';
import 'package:catfee/pages/caja.dart';
import 'package:catfee/pages/cocina.dart';
import 'package:catfee/pages/corredor.dart';
import 'package:catfee/pages/dashboard.dart';
import 'package:catfee/pages/host.dart';
import 'package:catfee/pages/login.dart';
import 'package:catfee/pages/menu.dart';
import 'package:catfee/pages/meseros.dart';
import 'package:catfee/pages/register.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> rutas = {
  '/login' : (context) => const LoginPage(),
  '/admin' : (context) => const AdminPage(),
  '/register':(context) => const RegisterPage(),
  '/dashboard':(context) => const DashboardPage(),
  '/corredor' :(context) => const CorredorPage(),
  '/host' : (context) => const HostPage(),
  '/menu':(context) => const MenuPage(),
  '/carrito': (context) => const CarritoPage(),
  '/meseros' : (context) => const MeserosPage(),
  '/cocina' : (context) => const CocinaPage(),
  '/caja':(context) => const CajaPage(),
};

void navigateTo(BuildContext context, String rol){
  switch (rol) {
    case 'Admin':
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminPage()));
      break;
    case 'Corredor':
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CorredorPage()));
      break;
    case 'Host':
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HostPage()));
      break;
    case 'Mesero':
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MeserosPage()));
      break;
    case 'Cocina':
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CocinaPage()));
      break;
    case 'Caja':
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CajaPage()));
      break;
    default:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }
}
  