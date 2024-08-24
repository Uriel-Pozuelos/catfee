
import 'package:catfee/pages/login.dart';
// import 'package:catfee/pages/menu.dart';
// import 'package:catfee/pages/admin.dart';
// import 'package:catfee/pages/host.dart';
// import 'package:catfee/pages/cocina.dart';
// import 'package:catfee/pages/caja.dart';
// import 'package:catfee/pages/corredor.dart';
// import 'package:catfee/pages/meseros.dart';
import 'package:catfee/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://teirtvafxrnzbdofpiry.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlaXJ0dmFmeHJuemJkb2ZwaXJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIwNDA3MjQsImV4cCI6MjAzNzYxNjcyNH0.bwU9lwbyrDy5MJlp2E21BNouMJ5UOduvLPavwImHqXo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catfee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Catfee'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catfee',
      debugShowCheckedModeBanner: false,
      routes: rutas,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: 
      // const AdminPage(),
      // const HostPage(),
      const LoginPage(),    
      // const MenuPage(),
      // const MeserosPage(),
      // const CocinaPage(),
      // const CorredorPage(),
      // const CajaPage(),
    );          
  }
}