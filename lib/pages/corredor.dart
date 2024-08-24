// ignore_for_file: avoid_print

import 'package:catfee/components/button.dart';
import 'package:catfee/models/usuario.dart';
import 'package:catfee/utils/user_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CorredorPage extends StatefulWidget {
  const CorredorPage({super.key});

  @override
  State<CorredorPage> createState() => _CorredorPageState();
}

class _CorredorPageState extends State<CorredorPage> {
  bool isLoading = false;
  // int comanda = 0;
  int idUser = 0;
  // int idMesa = 0;
  List<dynamic> ventas = [];
  List<Map<String, dynamic>> mesas = [];
  List<dynamic> detalleVenta = [];
  String limpiar = 'No hay mesas por limpiar';

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
  }

  Future<void> _loadUserData() async {
    final Usuario? isUser = await getUserData();
    // print(isUser?.email);
    if (isUser == null){
      Navigator.pushNamed(context, '/login');
    }else {
      // print(isUser);
      setState(() {
        isLoading = true;
        idUser = int.parse(isUser.id);
      });
      await _loadMesas(idUser);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMesas(idUser) async {
    try{

      final response = await supabase
        .from('MesasxRol')
        .select('mesaId, Mesas(estatus)')
        .eq('userId', idUser)
        as List<dynamic>;
        
      print('mesas: $response');

      if(response.isNotEmpty){
        setState(() {
          mesas = response.where((e) => e['Mesas']['estatus'] == 'Limpiar').map((e) {
            return {
              'id': e['mesaId'],
              'estatus': e['Mesas']['estatus']
            };
          }).toList();

          isLoading = false;
        }); 
      }else{
        setState(() {
          isLoading = false;
          limpiar = 'No hay mesas por limpiar';
        });
      }


    }catch (e){
      print(e);
    }
  }

  Future<void> _confirmarLimpieza (idMesa) async {
    bool isClean = false;
    await showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar limpieza'),
          content: const Text('¿Estás seguro de que la mesa esta limpia?'),
          actions: [
            TextButton(
              onPressed: () async {
                isClean = true;
                print(isClean);
                Navigator.pop(context);
                
                if(isClean){
                  await supabase.from('Mesas').update({'estatus':'Disponible'}).eq('id', idMesa);
                }
                await _loadMesas(idUser);
              }, 
              child: const Text('Sí')
            ),
            TextButton(
              onPressed: () {
                isClean = false;
                Navigator.pop(context);
              }, 
              child: const Text('No')
            ),
          ],
        );
      }
    );


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corredor'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
        actions: [
          IconButton(
            onPressed: () async {
              await _loadUserData();
            },
            icon: const Icon(Icons.refresh),
          ),
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
          children: [
            
            if(isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            const Text('Mesas asignadas', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
            const SizedBox(height: 20.0,),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: mesas.isEmpty
                ? Text(limpiar, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),)
                : GridView.count(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  children: mesas.map((mesa){
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CustomButton(
                        onPressed: () async {
                          await _confirmarLimpieza(mesa['id']);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mesa limpia'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          
                        },
                        estatus: mesa['estatus'],
                        id: mesa['id'],
                      ),
                    );
                  }).toList(),
                ),
            ),
          ],

        ),
      ),
    );
  }
}