// ignore_for_file: avoid_print

import 'package:catfee/components/button.dart';
import 'package:catfee/models/usuario.dart';
import 'package:catfee/utils/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HostPage extends StatefulWidget{
  const HostPage({super.key});

  @override
  State<HostPage> createState() => _HostState();
}

class _HostState extends State<HostPage>{
  bool isLoading = false;
  int comanda = 0;
  List<Map<String,dynamic>> ventaActual = [];
  List<Map<String,dynamic>> mesas = [];
  List<Map<String,dynamic>> ventas = [];
  final supabase = Supabase.instance.client;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMesas();
    _loadVentas();
  }

  Future<void> _loadUserData() async {
    final Usuario? isUser = await getUserData();
    // print(isUser?.email);
    if (isUser == null){
      Navigator.pushNamed(context, '/login');
    }else {
      print(isUser);
    }
  }

  Future<void> _loadMesas() async {
    try{
      setState(() {
        isLoading = true;
      });

      final response = await supabase.from('Mesas').select('*').order('id',ascending: true) as List<dynamic>;
      // print("mesas: $response");

      setState(() {
        mesas = response.map((e) => e as Map<String,dynamic>).toList();
        isLoading = false;
      });

    }catch (e){
      print(e);
    }
  }

  Future<void> _loadVentas() async {
    try{
      setState(() {
        isLoading = true;
      });

      final response = await supabase.from('Venta').select('*') as List<dynamic>;
      // print(response);

      setState(() {
        ventas = response.map((e) => e as Map<String,dynamic>).toList();
        isLoading = false;
      });

    }catch (e){
      print(e);
    }
  }

  Future<void> _asignarMesa(BuildContext context, int idMesa) async {
    
    String cliente = '';
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            alignment: Alignment.center,
            title: const Text('Asignar mesa a nombre de:'),
            content: TextField(
              onChanged: (value) {
                cliente = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  print(cliente);
                  Navigator.pop(context,cliente);
                  Navigator.pushNamed(context, '/meseros');
                },
                child: const Text('Asignar'),
              ),
            ],
          );
        }
    );    

    if(cliente.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe ingresar un nombre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try{
      setState(() {
        isLoading = true;
      });

      final response = await supabase.from('Mesas').select('*').eq('id', idMesa);
      final mesa = response[0];
      print(mesa);
      
      if (mesa['estatus'] == 'Disponible'){
        
        final nuevaVenta = await supabase.from('Venta').insert(
          {
            'fecha': DateTime.now().toString(),
            'estado': 'Pendiente',
            'mesaId': idMesa,
            'cliente': cliente,
          }
        ).select();

        print(nuevaVenta);
        // print(nuevaVenta[0]['id']);
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setInt('comanda', nuevaVenta[0]['id']);
        });
        
      }

      await supabase.from('Mesas').update({'estatus': 'Ocupada'}).eq('id', idMesa);
      // print(response);
      
      await _loadMesas();
      setState(() {
        isLoading = false;
      });
      

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La mesa $idMesa fue asignada a $cliente'),
          backgroundColor: Colors.green,
        ),
      );

    }catch (e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 168, 200, 227),
        actions: [ 
          IconButton(
            onPressed: () async {
              await logout(context);
            }, 
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView (
          child: Column(
          children: [
            
            if(isLoading)
              const Center(
                child: CircularProgressIndicator.adaptive() ,
              ),

            const Text('Mesas', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
            const SizedBox(height: 20.0,),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.count(
                    crossAxisCount: 5,
                    crossAxisSpacing: 20.0,
                    shrinkWrap: true,
                    children: mesas.map((mesas){
                      return Padding(
                        
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: CustomButton(
                          onPressed: () {
                            if (mesas['estatus'] == 'Disponible'){
                                _asignarMesa(context, mesas['id']);
                            }else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mesa ocupada'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }   
                          },
                          estatus: mesas['estatus'],
                          id: mesas['id'],
                        ),
                      );
                    }
                    ).toList(),
                ),
            ),
            
          ],
        ),
        )
      ),
    );
  }

}