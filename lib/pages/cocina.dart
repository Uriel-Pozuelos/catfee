// ignore_for_file: avoid_print


import 'package:catfee/models/usuario.dart';
import 'package:catfee/utils/user_data.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CocinaPage extends StatefulWidget{
  const CocinaPage({super.key});

  @override
  State<CocinaPage> createState() => _CocinaState();
}

class _CocinaState extends State<CocinaPage>{
  bool isLoading = false;
  int comanda = 0;
  int idUser = 0;
  int idMesa = 0;
  List<dynamic> ventas = [];
  List<Map<String,dynamic>> mesas = [];
  List<dynamic> detalleVenta = [];
  List<Map<String,dynamic>> productos = [];
  
  final supabase = Supabase.instance.client;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadOrdenes();
  }

  Future<void> _loadUserData() async {
    final Usuario? isUser = await getUserData();
    if (isUser == null){
      Navigator.pushNamed(context, '/login');
    }else {
      print([isUser.id, isUser.name, isUser.rol]);
    }
  }

  Future<void> _loadOrdenes() async{
    try{
      setState(() {
        isLoading = true;
      });
      
      //obtenemos las ordenes pendientes
      final response = await supabase.from('Venta').select().eq('estado','Pedido');
      if(response.isEmpty){
        print('No hay ordenes pendientes');
      }
      // print (response);

      //obtenemos los productos de cada orden pendiente
      for (var venta in response){
        final dv = await supabase
          .from('Detalle_Venta')
          .select('*,Producto(name)')
          .eq('ventaId', venta['id'])
          .eq('estatus', 'ND');

        if(dv.isNotEmpty){
          setState(() {
            ventas.add(venta);
            detalleVenta.add(dv);  
          });
        }
      }
      // print(ventas);
      // print(detalleVenta);

      setState(() {
        isLoading = false;
      });

    }catch(e){
      print(e);
    }
  }

  Future<bool?>  _confirmarPedido(BuildContext context, int index) async  {
  showDialog(
    context: context, 
    builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar pedido'),
          content: const Text('¿Está seguro de que desea confirmar este pedido como listo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              }, 
              child: const Text('Cancelar')
            ),
            TextButton(
              onPressed: () async{
                final dvActualizado = await supabase.from('Detalle_Venta').update({'estatus':'D'}).eq('ventaId', ventas[index]['id']);
                print(dvActualizado);
                await supabase.from('Mesas').update({'estatus':'Comiendo'}).eq('id', ventas[index]['mesaId']);
                Navigator.of(context).pop(true);
                setState(() {
                  ventas.removeAt(index);
                  detalleVenta.removeAt(index);                  
                });   
              }, 
              child: const Text('Confirmar')
            ),
          ],
        );
      }
    
    );
  return null;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocina'),
        backgroundColor: Colors.lightBlue[300],
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await logout(context);
            }, 
            icon: const Icon(Icons.logout)
          )
        ],
      ),
      body:
        Center(
          child: 
                Column(
                  children: [
                    
                    if(isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    

                    const Text('Ordenes pendientes', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 20.0,),

                    // SingleChildScrollView(
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                            
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: ventas.length,
                              itemBuilder: (context, index){
                                final v = ventas[index];
                                final dv = detalleVenta[index];
                                
                                return Dismissible(
                                  key: Key(v['id'].toString()), 
                                  direction: DismissDirection.horizontal,
                                  confirmDismiss: (direction) {
                                    return _confirmarPedido(context, index);
                                  },
                                  
                                  background: Container( 
                                    alignment: Alignment.center,
                                    color: Colors.green,
                                    child: const Icon(Icons.check_circle_rounded, color: Colors.white,),
                                  ),
                                  child: Card(
                                    margin: const EdgeInsets.all(10.0),
                                    child: ExpansionTile(

                                      title: Text('Mesa ${v['mesaId']}'),
                                      backgroundColor: Colors.lightBlue[100],
                                      children: [
                                        Container(
                                          constraints: const BoxConstraints(maxHeight: 200),
                                          child: 
                                            ListView(
                                              shrinkWrap: true,                                           
                                              children: 
                                                // mapeamos los productos de cada orden en una lista
                                                dv.map<Widget>( (detalle){
                                                
                                                //si hay especificaciones se formatean y se agregan a la descripcion
                                                final especificaciones = detalle['especificaciones'] != null ? detalle['especificaciones'].entries.map((e) {
                                                  return 'con ${e.key} de ${e.value}';
                                                }).join(', ') : '';

                                                return ListTile(
                                                    title: Text('Producto: ${detalle['Producto']['name']}'),
                                                    subtitle:
                                                      Column(  
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [

                                                          Text('Cantidad: ${detalle['cantidad']}', style: const TextStyle(color:Colors.black )),
                                                          if(detalle['especificaciones'] != null)
                                                            Text('Especificaciones: $especificaciones', style: const TextStyle(color:Colors.black )),
                                                          const Divider(
                                                            color: Colors.black,
                                                            thickness: 1.0,
                                                          ),
                                                        ],
                                                      ),
                                                    

                                                  );
                                                }).toList(),
                                            )
                                            
                                          
                                        )
                                      ],
                                    )
                                  )
                                    
                                );
                              },
                            ),
                          
                        ],
                      
                      
                  ),

                    )

                    

                    
                  ],
                ),
        ),
      
      
      
    );
  }
}

