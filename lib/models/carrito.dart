
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:catfee/models/productos.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  List<Productos> _productos = [];
  int idMesa = 0;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _getData();
    
  }
  Future<void> _getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? mesaId = prefs.getInt('mesaId');
    final List<Productos> productos = await _loadCarrito(mesaId!);
    setState(() {
      idMesa = mesaId;
      _productos = productos;
    });
  }

  Future<void> _cleanCarrito(int mesaId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('carrito$mesaId');
    setState(() {
      _productos = [];
    });
  }

  Future<List<Productos>> _loadCarrito (int mesaId) async {
    final prefs = await SharedPreferences.getInstance();

    final String? jsonProductos = prefs.getString('carrito$mesaId');
    print('cart actual: carrito$mesaId');
    if(jsonProductos != null){
      //Se convierte el json a una lista de mapas
      List<dynamic> mapCarrito = json.decode(jsonProductos);
      print('Map carrito: $mapCarrito');

      //Se convierte la lista de mapas a una lista de productos
      List<Productos> listProductos = mapCarrito.map((c) => Productos.fromMap(c)).toList();
      print('Productos: $listProductos');

      return listProductos;

    }else{
      return [];
    }
  }

  Future<void> _saveCarrito(int mesaId) async {

    final String jsonProductos = json.encode(_productos);
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('carrito$mesaId', jsonProductos);
    // print(prefs.getString('carrito$mesaId'));
    // print('Productos guardados: $jsonProductos');
  }

  Future<void> _deleteItemCarrito(int index, int mesaId) async{
    setState(() {
      _productos.removeAt(index);
    });
    await _saveCarrito(mesaId);
  }

  Future<void> _ordenar(int mesaId) async {
    try{
      //Obtenemos la venta actual para la mesa seleccionada
      final response = await supabase.from('Venta').select('id').eq('mesaId',mesaId).limit(1) as List<dynamic>;
      int ventaId = response[0]['id'];
      double total = 0;
      print('Venta id: $ventaId');
      
      //Obtenemos los detalles de la venta y calculamos el total
      final detalleVenta = await supabase
            .from('Detalle_Venta')
            .select('cantidad,precioUnitario')
            .eq('ventaId', ventaId) as List<dynamic>;

      //si hay detalles de venta calculamos el total
      if(detalleVenta.isNotEmpty){
        for (var dv in detalleVenta) {
          total += dv['cantidad'] * dv['precioUnitario'];
        }
      }

      //Se convierte la lista de productos a una lista de json
      final carrito = _productos.map((e) => e.toJson()).toList();
      print('Carrito: $carrito');
      
      //Se recorre la lista de productos y se insertan los detalles de la venta
      for (var pd in carrito) {
        final pdData = await supabase
          .from('Producto')
          .select('id')
          .eq('name',pd['sabor'])
          .single();
        // print('Producto: $pdData');

        
        final productId = pdData['id'];
        final cantidad = pd['cantidad'];
        final precio = pd['precio'];
        final especificaciones = pd['especificaciones'];
        // print({'productId': productId, 'cantidad': cantidad, 'precio': precio, 'especificaciones': especificaciones});

        total += cantidad * precio;

        await supabase.from('Detalle_Venta').insert(
          {
            'ventaId': ventaId,
            'productoId': productId,
            'cantidad': cantidad,
            'precioUnitario': precio,
            'especificaciones': especificaciones,
          }
        );
      }

      //Actualizamos el total de la venta y su estado, y cambiamos el estatus de la mesa a Ordenando
      await supabase.from('Venta').update({'total': total,'estado':'Pedido'}).eq('id', ventaId);
      await supabase.from('Mesas').update({'estatus': 'Ordenando'}).eq('id', mesaId);


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orden realizada con éxito'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        )
      );

      await _cleanCarrito(mesaId);
      Navigator.pushNamed(context, '/meseros');


    }catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al ordenar'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordenes'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
              Expanded(
                child:
                  ListView.builder(
                    itemCount: _productos.length,
                    itemBuilder: (context, index){
                      
                      String? especificaciones ='';
                      //Si hay especificaciones se formatean y se agregan a la descripcion
                      if(_productos[index].especificaciones.isNotEmpty){
                        especificaciones = _productos[index].especificaciones.entries.map((e) {
                          return 'con ${e.key} de ${e.value}';
                        }).join(', ');

                        especificaciones = ', Especificaciones: $especificaciones';
                      }


                      return ListTile(
                        title: Text(_productos[index].sabor),
                        subtitle: Text('Cantidad: ${_productos[index].cantidad }, Precio Unitario: \$${_productos[index].precio.toString()} $especificaciones '),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red,),
                          onPressed: (){
                            _deleteItemCarrito(index, idMesa);
                          },
                        ),

                      );
                    },
                  ),    
              ),
              if (_productos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0), 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.green),
                        ),
                        onPressed: () async {
                          await _saveCarrito(idMesa);
                          await _ordenar(idMesa);
                          
                        }, 
                        child: const Text('Ordenar', style: TextStyle(color: Colors.white),),
                      ),

                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.red),
                        ),
                        onPressed: () async {
                          await _cleanCarrito(idMesa);
                        }, 
                        child: const Text('Limpiar orden', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
          ],
        )
      ),
    );
  }
}

