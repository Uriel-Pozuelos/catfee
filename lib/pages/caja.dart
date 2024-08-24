// ignore_for_file: avoid_print

import 'package:catfee/models/usuario.dart';
import 'package:catfee/utils/user_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CajaPage extends StatefulWidget{
  const CajaPage({super.key});

  @override
  State<CajaPage> createState() => _CajaState();

}

class _CajaState extends State<CajaPage>{
  bool isLoading = false;
  int isUser = 0;
  int ventaId = 0;
  List<dynamic> ventas = [];
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
        ventaId = int.parse(isUser.id);
      });
      await _loadVentas();

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadVentas() async{
    try{
      //obtenemos las ventas pendientes por pagar
      final response = await supabase.from('Venta').select('id,total').eq('estado', 'Cerrada');
      
      //Iteramos sobre las ventas para obtener el id de cada una y validamos si la respuesta no esta vacia
      if(response.isNotEmpty){
        List<int> ventasId = [];

        for(var venta in response){
          ventasId.add(venta['id']);
        }

        setState(() {
          ventas = response;
          ventaId = ventasId.isNotEmpty ? ventasId[0] : 0;
        });

        print('ids de las ventas: $ventasId');
      }else{
        print('No hay ventas pendientes por pagar');
        setState(() {
          ventas = [];
          ventaId = 0;
        });
      }

    }catch(e){
      print('Error: $e');
    }
  }

  Future<void> _confirmarPago() async{
    bool pagada = false;
    BuildContext contextApp = context;
    await showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar pago'),
          content: const Text('¿Confirma que se recibio el pago?'),
          actions: [
            TextButton(
              onPressed: () async {
                pagada = true;
                print(pagada);
                
                try{
                  //Actualizamos el estado de la venta a Pagada
                  final response = await supabase.from('Venta').update({'estado': 'Pagada'}).eq('id', ventaId);
                  print(response);
                  //Insertamos un registro en la tabla Caja
                  final caja = await supabase.from('Caja').insert({'ventaId': ventaId, 'estatus': 'Pagada'});
                  print(caja);
                }catch(e){
                  print('Error: $e');

                }

                Navigator.pop(context);

                await _loadUserData();

                ScaffoldMessenger.of(contextApp).showSnackBar(
                    const SnackBar(
                      content: Text('Se recibió el pago con éxito'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    )
                  );

              }, 
              child: const Text('Sí')
            ),
            TextButton(
              onPressed: () {
                pagada = false;
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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja'),
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
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: Column(
          children: [
            
            if(isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            
            if(ventas.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: ventas.length,
                  itemBuilder: (context, index){
                    return ListTile(
                      title: Text('Venta ${ventas[index]['id']}'),
                      subtitle: Text('Total: \$${ventas[index]['total']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.payment, color: Colors.green,),
                        onPressed: (){
                          ventaId = ventas[index]['id'];
                          _confirmarPago();
                        },
                      ),
                    );
                  }
                )
              ),

            if(ventas.isEmpty)
              const Center(
                child: Text('No hay ventas pendientes por pagar', style: TextStyle(fontSize: 20.0),),
              ),

          ],
        )
      )
    );
  }

}