// ignore_for_file: avoid_print

import 'package:catfee/components/button.dart';
import 'package:catfee/models/usuario.dart';
import 'package:catfee/utils/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class MeserosPage extends StatefulWidget{
  const MeserosPage({super.key});

  @override
  State<MeserosPage> createState() => _MeserosState();
}

class _MeserosState extends State<MeserosPage>{
  bool isLoading = false;
  int comanda = 0;
  int idUser = 0;
  int idMesa = 0;
  List<Map<String,dynamic>> ventaActual = [];
  List<Map<String,dynamic>> mesas = [];
  List<Map<String,dynamic>> ventas = [];
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
      //Cargamos mesas asignadas para cada mesero
      await _loadMesas(idUser);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMesas(idUser) async {
    try{

      //obtenemos las mesas asignadas al mesero
      final response = await supabase
        .from('MesasxRol')
        .select('*, Mesas(estatus)')
        .eq('userId', idUser)
        .limit(5) as List<dynamic>;
        
      // print('mesas: $response');

      //guardamos el id de la mesa y su estatus en la lista mesas
      setState(() {
        mesas = response.map((e) {
          return {
            'id': e['mesaId'],
            'estatus': e['Mesas']['estatus']
          };
        }).toList();

        isLoading = false;
      });

    }catch (e){
      print(e);
    }
  }

  Future<void> _loadVentas(int mesaId) async {
    
    try{
      //Obtenemos la venta actual para la mesa seleccionada
      final response = await supabase.from('Venta').select('*').eq('mesaId', mesaId).limit(1) as List<dynamic>;
      // print('venta id: $response');

      if(response.isNotEmpty){
        //Si hay venta actual guardamos el id de la comanda en shared preferences

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('comanda${response[0]['id']}', response[0]['id']);
        // print('Comanda por idMesa ${'comanda${response[0]['id']}'}');
        // print(prefs.getInt('comanda${response[0]['id']}'));

        
        setState(() {
          comanda = response[0]['id'];
        });
      }else{
        print('No se encontraron ventas para la mesa $mesaId');
      }

    }catch (e){
      print(e);
    }
  }

  Future<void> _options(BuildContext context, int mesaId) async {
    
    //Cargamos la venta actual para la mesa seleccionada
    await _loadVentas(mesaId);

    if(comanda != 0){
        final BuildContext contextApp = context;

        await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            alignment: Alignment.center,
            title: Text('Comanda actual para la mesa $mesaId: $comanda'),
            content:
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      alignment: Alignment.center,
                      backgroundColor: Colors.lightBlue[300],
                      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
                    ),  
                    onPressed: () async{
                      Navigator.pop(context);
                      //Navegamos a la pagina de menu y pasamos como argumentos el id de la mesa y la comanda
                      Navigator.pushNamed(contextApp, '/menu', arguments: {'mesaId':mesaId, 'comanda':comanda});
                    },
                    child: const Text('Hacer orden', style: TextStyle(color: Colors.white),),
                  ),

                  const SizedBox(width: 20.0,),

                  TextButton(
                    style: TextButton.styleFrom(
                      alignment: Alignment.center,
                      backgroundColor: Colors.lightBlue[300],
                      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
                    ),  
                    onPressed: () async{
                      Navigator.pop(context);
                      //Actualizamos el estatus de la mesa a Limpiar
                      await supabase.from('Mesas').update({'estatus':'Limpiar'}).eq('id', mesaId);
                      print(mesaId);
                      //Actualizamos el estado de la venta a Cerrada para mandarla a caja 
                      await supabase.from('Venta').update({'estado':'Cerrada'}).eq('mesaId', mesaId);

                      ScaffoldMessenger.of(contextApp).showSnackBar(
                        const SnackBar(
                          content: Text('Venta cerrada y asignaga al corredor'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      //actualizamos vista del mesero
                      await _loadMesas(idUser);
                    },
                    child: const Text('Cerrar venta', style: TextStyle(color: Colors.white),),
                  ),
                ],
                
              ),

              
          );
        }
    );    
    }else{
      print('No hay comanda');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meseros'),
        backgroundColor: Colors.lightBlue[300],
        centerTitle: true,
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
          children: [
            
            if(isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            const Text('Mesas asignadas', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
            const SizedBox(height: 20.0,),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                children: mesas.map((mesas){
                  return Padding(
                        
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: 
                          CustomButton(
                            onPressed: () async {
                              
                              _options(context, mesas['id']);
                              // print('idMesa 2: ${mesas['id']}');
                              // print('comanda actual $comanda');

                            },
                            estatus: mesas['estatus'],
                            id: mesas['id'],
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