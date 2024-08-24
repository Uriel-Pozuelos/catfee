// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:catfee/components/text_field.dart';
import 'package:catfee/models/productos.dart';
import 'package:catfee/models/usuario.dart';
import 'package:catfee/utils/user_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class MenuPage extends StatefulWidget{
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _OrdenarState();
}

class _OrdenarState extends State<MenuPage>{
  final TextEditingController _cantidadController = TextEditingController();
  
  List<Productos> productos = [];
  
  bool isLoading = false;
  int userId = 0;
  // int comanda = 0;

  bool mayonesa = false;
  bool cesar = false;
  bool chipotle = false;
  bool queso = false;
  bool jalapenio = false;
  bool chocolate = false;


  final supabase = Supabase.instance.client;
  

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final Usuario? isUser = await getUserData();
    if (isUser == null){
      Navigator.pushNamed(context, '/login');
    }else {
      print([isUser.id, isUser.name, isUser.rol]);
    }
  }

  Future<void> _addCarrito(Productos producto, int idMesa) async{
    final prefs = await SharedPreferences.getInstance();

    //Obtenemos el carrito acutal de la mesa
    final String? jsonProductos = prefs.getString('carrito$idMesa');
    //A la lista carrito se le agrega el json de los productos
    List<dynamic> carrito = jsonProductos != null ? json.decode(jsonProductos) : [] ;
    
    //Se agrega el producto al carrito
    carrito.add(producto.toJson());
    
    //Se actualiza el carrito
    await prefs.setString('carrito$idMesa',json.encode(carrito));
    await supabase.from('Mesas').update({'estatus':'Ordenando'}).eq('id', idMesa);
    _cantidadController.clear();
    // print(prefs.getString('carrito$idMesa'));
  }

  Future<void> _setMesa(int idMesa) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();  
    prefs.setInt('mesaId', idMesa);
  }

  @override
  Widget build(BuildContext context) {
    
    //obtenemos los argumentos de la ruta anterior
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    //guardamos el id de la mesa en el preferences
    _setMesa(args['mesaId']);
    print(args['mesaId']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        title: const Text('Menú'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/carrito');
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          IconButton(
            onPressed: () {
              logout(context);
            }, 
            icon: const Icon(Icons.logout)
          ),
          // IconButton(
          //   onPressed: (){
          //     Navigator.pushNamed(context, '/meseros');
          //   },
          //   icon: const Icon(Icons.restaurant_menu)
          // ),
        ],
      ),
      backgroundColor: Colors.lightBlue[50],

      
      body: Center(        
        child: SingleChildScrollView(
          child: Column(
          children: [

            const SizedBox(height: 20.0,),
            const Text('Comida', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),),
            Text('Mesa ${args['mesaId']}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
            Text('Comanda actual: ${args['comanda']}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                  ButtonProducts(
                    Image.asset('assets/images/empanada.png', width: toDouble(100),height: toDouble(100)),
                    'Empanadas',
                    () { 
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          
                          String? sabor = 'Empanadas de queso con chorizo';

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Empanadas',
                                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 20.0),
                                      const Text(
                                        'Seleccione el sabor de la empanada',
                                        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                      ),

                                      RadioListTile<String>(
                                        title: const Text('Queso con chorizo'),
                                        value: 'Empanadas de queso con chorizo',
                                        groupValue: sabor,
                                        onChanged: (String? value) {
                                          setState(() {
                                            sabor = value;
                                          });
                                        },
                                      ),

                                      RadioListTile<String>(
                                        title: const Text('Hawaiana'),
                                        value: 'Empanada hawaiana',
                                        groupValue: sabor,
                                        onChanged: (String? value) {
                                          setState(() {
                                            sabor = value;
                                          });
                                        },
                                      ),

                                      RadioListTile<String>(
                                        title: const Text('Pepperoni'),
                                        value: 'Empanada de pepperoni',
                                        groupValue: sabor,
                                        onChanged: (String? value) {
                                          setState(() {
                                            sabor = value;
                                          });
                                        },
                                      ),
                                      
                                      TextFieldForm(
                                        controller: _cantidadController,
                                        keyboardType: TextInputType.number,
                                        labelText: 'Cantidad',
                                      ),
                                      const SizedBox(height: 10.0),

                                      ElevatedButton(
                                        onPressed: () {
                                          final int cantidad = int.parse(_cantidadController.text);
                                          final producto = Productos (
                                            sabor: sabor ?? '',
                                            cantidad: cantidad,
                                            precio: 45.0,
                                            especificaciones: {},
                                          );
                                          _addCarrito(producto, args['mesaId']);
                                          
                                          // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                        },
                                        child: const Text('Aceptar y agregar al carrito'),
                                      ),

                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );

                    }
                  ),
                  const SizedBox(width: 10.0,),

                  ButtonProducts(
                    Image.asset('assets/images/baguette.png', width: toDouble(100),height: toDouble(100)),
                    'Baguettes',
                    () {
                      showDialog(
                        context: context,
                        builder: 
                          (BuildContext context) {
                            String? sabor = 'Baguette de pollo';

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Baguettes',
                                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 20.0),
                                        const Text(
                                          'Seleccione el sabor del baguette',
                                          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                        ),

                                        RadioListTile<String>(
                                          title: const Text('Pollo'),
                                          value: 'Baguette de pollo',
                                          groupValue: sabor,
                                          onChanged: (String? value) {
                                            setState(() {
                                              sabor = value;
                                            });
                                          },
                                        ),

                                        RadioListTile<String>(
                                          title: const Text('Vegetariano'),
                                          value: 'Baguette vegetariano',
                                          groupValue: sabor,
                                          onChanged: (String? value) {
                                            setState(() {
                                              sabor = value;
                                            });
                                          },
                                        ),

                                        const Text(
                                          'Adicionales',
                                          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                        ),

                                        CheckboxListTile(
                                          title: const Text('Mayonesa'),
                                          value: mayonesa,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              mayonesa = value ?? false;
                                              print(mayonesa);
                                            });
                                          }
                                        ),

                                        CheckboxListTile(
                                          title: const Text('Cesar'),
                                          value: cesar,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              cesar = value ?? false;
                                              print(cesar);
                                            });
                                          }
                                        ),

                                        CheckboxListTile(
                                          title: const Text('Chipotle'),
                                          value: chipotle,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              chipotle = value ?? false;
                                              print(chipotle);
                                            });
                                          }
                                        ),


                                        TextFieldForm(
                                          controller: _cantidadController,
                                          keyboardType: TextInputType.number,
                                          labelText: 'Cantidad',
                                        ),
                                        const SizedBox(height: 10.0),



                                        ElevatedButton(
                                          onPressed: () {
                                            final int cantidad = int.parse(_cantidadController.text);
                                            List aderezos = [];
                                            if(mayonesa) aderezos.add('mayonesa');
                                            if(cesar) aderezos.add('cesar');
                                            if(chipotle) aderezos.add('chipotle');
                                            String? especificaciones= aderezos.isNotEmpty ? aderezos.join(', ') : null;
                                            final producto = Productos (
                                              sabor: sabor ?? '',
                                              cantidad: cantidad,
                                              precio: 65.0,
                                              especificaciones: {'aderezo': especificaciones},
                                            );
                                            _addCarrito(producto, args['mesaId']);
                                            
                                            // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                            setState(() {
                                              mayonesa = false;
                                              cesar = false;
                                              chipotle = false;
                                            });
                                            
                                          },
                                          child: const Text('Aceptar y agregar al carrito'),
                                        ),

                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                      );
                    }
                  ),
                  const SizedBox(width: 10.0,),

                  ButtonProducts(
                    Image.asset('assets/images/nachos.png', width: toDouble(80),height: toDouble(100)),
                    'Orden de Nachos',
                    () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String? sabor = 'Orden de nachos';

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Nachos',
                                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 20.0),
                                      const Text(
                                        'Seleccione los adicionales de los nachos',
                                        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                      ),

                                      CheckboxListTile(
                                          title: const Text('Queso Amarillo'),
                                          value: queso,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              queso = value ?? false;
                                              print(queso);
                                            });
                                          }
                                        ),

                                        CheckboxListTile(
                                          title: const Text('Chile Jalapeño'),
                                          value: jalapenio,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              jalapenio = value ?? false;
                                              print(jalapenio);
                                            });
                                          }
                                        ),
                                      
                                      TextFieldForm(
                                        controller: _cantidadController,
                                        keyboardType: TextInputType.number,
                                        labelText: 'Cantidad',
                                      ),
                                      const SizedBox(height: 10.0),

                                      ElevatedButton(
                                        onPressed: () {
                                          final int cantidad = int.parse(_cantidadController.text);
                                          List adicionales = [];
                                          if(queso) adicionales.add('queso amarillo');
                                          if(jalapenio) adicionales.add('chile jalapeño');
                                          String? especificaciones= adicionales.isNotEmpty ? adicionales.join(', ') : null;
                                          final producto = Productos (
                                            sabor: sabor,
                                            cantidad: cantidad,
                                            precio: 45.0,
                                            especificaciones: {'adicionales': especificaciones},
                                          );
                                          _addCarrito(producto, args['mesaId']);
                                          
                                          // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                          setState(() {
                                            queso = false;
                                            jalapenio = false;
                                          });
                                        },
                                        child: const Text('Aceptar y agregar al carrito'),
                                      ),

                                    ],
                                  ),
                                ),
                              );
                            }
                          );
                        }
                      );
                    }
                  ),
                  const SizedBox(width: 10.0,),
              ],
            ),
            const SizedBox(height: 20.0,),

            const Text('Postres', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonProducts(
                  Image.asset('assets/images/brownixhelado.webp', width: toDouble(100),height: toDouble(100)),
                  'Brownie con helado',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Brownie con helado de vainilla',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20.0),
                                TextFieldForm(
                                  controller: _cantidadController,
                                  keyboardType: TextInputType.number,
                                  labelText: 'Cantidad',
                                ),
                                const SizedBox(height: 10.0),

                                ElevatedButton(
                                  onPressed: () {
                                    final int cantidad = int.parse(_cantidadController.text);
                                    final producto = Productos (
                                      sabor: 'Brownie con helado',
                                      cantidad: cantidad,
                                      precio: 35.0,
                                      especificaciones: {},
                                    );
                                    _addCarrito(producto, args['mesaId']);
                                    
                                    // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');                                   
                                  },
                                  child: const Text('Aceptar y agregar al carrito'),
                                ),

                              ],
                            ),
                          ),
                        );
                      }
                    );
                  }
                ),
                const SizedBox(width: 10.0,),

                ButtonProducts(
                  Image.asset('assets/images/crepa.webp', width: toDouble(100),height: toDouble(100)),
                  'Crepas',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String sabor = 'Crepa de nutella';
                        String adicional = 'Plátano';
                        return StatefulBuilder(
                          builder: (context, setState){
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Crepas Dulces',
                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20.0),
                                    const Text(
                                      'Seleccione el untable de la crepa',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Nutella'),
                                      value: 'Crepa de nutella',
                                      groupValue: sabor,
                                      onChanged: (String? value) {
                                        setState(() {
                                          sabor = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Lechera'),
                                      value: 'Crepa de lechera',
                                      groupValue: sabor,
                                      onChanged: (String? value) {
                                        setState(() {
                                          sabor = value ?? '';
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 20.0),

                                    const Text('Seleccione la fruta o el ingrediente adicional', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),

                                    RadioListTile<String>(
                                      title: const Text('Plátano'),
                                      value: 'Plátano',
                                      groupValue: adicional,
                                      onChanged: (String? value) {
                                        setState(() {
                                          adicional = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Fresa'),
                                      value: 'Fresa',
                                      groupValue: adicional,
                                      onChanged: (String? value) {
                                        setState(() {
                                          adicional = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Philadelphia'),
                                      value: 'Philadelphia',
                                      groupValue: adicional,
                                      onChanged: (String? value) {
                                        setState(() {
                                          adicional = value ?? '';
                                        });
                                      },
                                    ),


                                    TextFieldForm(
                                      controller: _cantidadController,
                                      keyboardType: TextInputType.number,
                                      labelText: 'Cantidad',
                                    ),
                                    const SizedBox(height: 10.0),

                                    // if(_cantidadController.text.isEmpty)
                                    //     const Padding(
                                    //       padding: EdgeInsets.all(8.0),
                                    //       child: Text('Por favor, ingrese la cantidad de crepas', style: TextStyle(color: Colors.red),),
                                    //     ),
                                    
                                    ElevatedButton(
                                      onPressed: () {
                                        if(_cantidadController.text.isEmpty == true){

                                        }else{
                                          final int cantidad = int.parse(_cantidadController.text);
                                          final String especificaciones;
                                          if(adicional == 'Plátano'){
                                            especificaciones = adicional;
                                          }else if(adicional == 'Fresa'){
                                            especificaciones = adicional;
                                          }else{
                                            especificaciones = adicional;
                                          }

                                          print('espec: $especificaciones');

                                          final producto = Productos (
                                            sabor: sabor, 
                                            cantidad: cantidad,
                                            precio: 50.0,
                                            especificaciones: {'adicional': especificaciones},
                                          );
                                          print(producto);
                                          
                                          _addCarrito(producto, args['mesaId']);
                                          
                                          // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                        }
                                      },
                                      child: const Text('Aceptar y agregar al carrito'),
                                    ),

                                    

                                    
                                  ],
                                ),
                              ),
                            );
                          }

                        );
                      }
                    );
                  }
                ),
                const SizedBox(width: 10.0,),
              ],
            ),

            const SizedBox(height: 20.0,),

            const Text('Bebidas', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),),

            GridView.count(
              crossAxisCount: 3,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                
                ButtonProducts(
                  Image.asset('assets/images/pinia.webp', width: toDouble(100),height: toDouble(100)),
                  'Piña colada',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Piña colada',
                                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 20.0),

                                      TextFieldForm(
                                        controller: _cantidadController,
                                        keyboardType: TextInputType.number,
                                        labelText: 'Cantidad',
                                      ),
                                      const SizedBox(height: 20.0),

                                      ElevatedButton(
                                        onPressed: () {
                                          final int cantidad = int.parse(_cantidadController.text);
                                          final producto = Productos (
                                            sabor: 'Piña colada',
                                            cantidad: cantidad,
                                            precio: 60.0,
                                            especificaciones: {},
                                          );
                                          _addCarrito(producto, args['mesaId']);
                                          
                                          // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                        },
                                        child: const Text('Aceptar y agregar al carrito'),
                                      ),

                                    ],
                                  )
                                ),
                                
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  }
                ),
                

                ButtonProducts(
                  Image.asset('assets/images/malteadas.png', width: toDouble(100),height: toDouble(100)),
                  'Malteadas',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String malteadas = 'Malteada de vainilla';
                        String leche = 'Entera';
                        return StatefulBuilder(
                          builder: (context, setState){
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Malteadas',
                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20.0),

                                    const Text(
                                      'Seleccione el sabor de la malteada',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Vainilla'),
                                      value: 'Malteada de vainilla',
                                      groupValue: malteadas,
                                      onChanged: (String? value) {
                                        setState(() {
                                          malteadas = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Fresa'),
                                      value: 'Malteada de fresa',
                                      groupValue: malteadas,
                                      onChanged: (String? value) {
                                        setState(() {
                                          malteadas = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Chocolate'),
                                      value: 'Malteada de chocolate',
                                      groupValue: malteadas,
                                      onChanged: (String? value) {
                                        setState(() {
                                          malteadas = value ?? '';
                                        });
                                      },
                                    ),

                                    const Text(
                                      'Seleccione el tipo de leche',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),
                                    
                                    RadioListTile<String>(
                                      title: const Text('Entera'),
                                      value: 'Entera',
                                      groupValue: leche,
                                      onChanged: (String? value) {
                                        setState(() {
                                          leche = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Deslactosada'),
                                      value: 'Deslactosada',
                                      groupValue: leche,
                                      onChanged: (String? value) {
                                        setState(() {
                                          leche = value ?? '';
                                        });
                                      },
                                    ),

                                    const Text(
                                      'Adicionales',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),

                                    CheckboxListTile(
                                      title: const Text('Chocolate y crema batida'),
                                      value: chocolate,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          chocolate = value ?? false;
                                          print(chocolate);
                                        });
                                      }
                                    ),


                                    TextFieldForm(
                                      controller: _cantidadController,
                                      keyboardType: TextInputType.number,
                                      labelText: 'Cantidad',
                                    ),
                                    const SizedBox(height: 10.0),

                                    ElevatedButton(
                                      onPressed: () {
                                        final int cantidad = int.parse(_cantidadController.text);
                                        final producto = Productos (
                                          sabor: malteadas,
                                          cantidad: cantidad,
                                          precio: 60.0,
                                          especificaciones: {'leche': leche, 'adicional': chocolate ? 'chocolate y crema batida' : 'sin adicional'},
                                        );
                                        // print(producto);
                                        _addCarrito(producto, args['mesaId']);
                                        
                                        // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                      },
                                      child: const Text('Aceptar y agregar al carrito'),
                                    ),
                                    const SizedBox(height: 20.0),
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      }
                    );
                  }
                ),
                

                ButtonProducts(
                  Image.asset('assets/images/frappe.webp', width: toDouble(100),height: toDouble(100)),
                  'Frappe',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String frappe = 'Frappe de Moka';
                        String leche = 'Entera';
                        return StatefulBuilder(
                          builder: (context, setState){
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Frappes',
                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20.0),

                                    const Text(
                                      'Seleccione el sabor del frappe',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Moka'),
                                      value: 'Frappe de Moka',
                                      groupValue: frappe,
                                      onChanged: (String? value) {
                                        setState(() {
                                          frappe = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Oreo'),
                                      value: 'Frappe de Oreo',
                                      groupValue: frappe,
                                      onChanged: (String? value) {
                                        setState(() {
                                          frappe = value ?? '';
                                        });
                                      },
                                    ),

                                    const Text(
                                      'Seleccione el tipo de leche',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),
                                    
                                    RadioListTile<String>(
                                      title: const Text('Entera'),
                                      value: 'Entera',
                                      groupValue: leche,
                                      onChanged: (String? value) {
                                        setState(() {
                                          leche = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Deslactosada'),
                                      value: 'Deslactosada',
                                      groupValue: leche,
                                      onChanged: (String? value) {
                                        setState(() {
                                          leche = value ?? '';
                                        });
                                      },
                                    ),

                                    const Text(
                                      'Adicionales',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),

                                    CheckboxListTile(
                                      title: const Text('Chocolate y crema batida'),
                                      value: chocolate,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          chocolate = value ?? false;
                                          print(chocolate);
                                        });
                                      }
                                    ),


                                    TextFieldForm(
                                      controller: _cantidadController,
                                      keyboardType: TextInputType.number,
                                      labelText: 'Cantidad',
                                    ),
                                    const SizedBox(height: 10.0),

                                    ElevatedButton(
                                      onPressed: () {
                                        final int cantidad = int.parse(_cantidadController.text);
                                        final producto = Productos (
                                          sabor: frappe,
                                          cantidad: cantidad,
                                          precio: frappe == 'Frappe de Moka' ? 55.0 : 60.0,
                                          especificaciones: {'leche': leche, 'adicional': chocolate ? 'chocolate y crema batida' : 'sin adicional'},
                                        );
                                        // print(producto);
                                        _addCarrito(producto, args['mesaId']);
                                        
                                        // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                      },
                                      child: const Text('Aceptar y agregar al carrito'),
                                    ),
                                    const SizedBox(height: 20.0),
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      }
                    );
                  }
                ),
                

                ButtonProducts(
                  Image.asset('assets/images/limonadaxnara.jpg', width: toDouble(100),height: toDouble(100)),
                  'Limonada/Naranjada',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String bebida = 'Limonada';
                        return StatefulBuilder(
                          builder: (context, setState){
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Limonada/Naranjada',
                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20.0),

                                    const Text(
                                      'Seleccione el sabor de la bebida',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Limonada'),
                                      value: 'Limonada',
                                      groupValue: bebida,
                                      onChanged: (String? value) {
                                        setState(() {
                                          bebida = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Naranjada'),
                                      value: 'Naranjada',
                                      groupValue: bebida,
                                      onChanged: (String? value) {
                                        setState(() {
                                          bebida = value ?? '';
                                        });
                                      },
                                    ),

                                    TextFieldForm(
                                      controller: _cantidadController,
                                      keyboardType: TextInputType.number,
                                      labelText: 'Cantidad',
                                    ),
                                    const SizedBox(height: 10.0),

                                    ElevatedButton(
                                      onPressed: () {
                                        final int cantidad = int.parse(_cantidadController.text);
                                        final producto = Productos (
                                          sabor: bebida,
                                          cantidad: cantidad,
                                          precio: 35.0,
                                          especificaciones: {},
                                        );
                                        // print(producto);
                                        _addCarrito(producto, args['mesaId']);
                                        
                                        // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                      },
                                      child: const Text('Aceptar y agregar al carrito'),
                                    ),
                                    const SizedBox(height: 20.0),
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      }
                    );
                  }
                ),
                

                ButtonProducts(
                  Image.asset('assets/images/refrescos.png', width: toDouble(100),height: toDouble(100)),
                  'Refrescos',
                  () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String bebida = 'Coca Cola';
                        return StatefulBuilder(
                          builder: (context, setState){
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Refrescos',
                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20.0),

                                    const Text(
                                      'Seleccione el sabor del refresco',
                                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Coca Cola'),
                                      value: 'Coca Cola',
                                      groupValue: bebida,
                                      onChanged: (String? value) {
                                        setState(() {
                                          bebida = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Coca Cola light'),
                                      value: 'Coca Cola light',
                                      groupValue: bebida,
                                      onChanged: (String? value) {
                                        setState(() {
                                          bebida = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Sprite'),
                                      value: 'Sprite',
                                      groupValue: bebida,
                                      onChanged: (String? value) {
                                        setState(() {
                                          bebida = value ?? '';
                                        });
                                      },
                                    ),

                                    RadioListTile<String>(
                                      title: const Text('Manzana'),
                                      value: 'Manzana',
                                      groupValue: bebida,
                                      onChanged: (String? value) {
                                        setState(() {
                                          bebida = value ?? '';
                                        });
                                      },
                                    ),

                                    TextFieldForm(
                                      controller: _cantidadController,
                                      keyboardType: TextInputType.number,
                                      labelText: 'Cantidad',
                                    ),
                                    const SizedBox(height: 10.0),

                                    ElevatedButton(
                                      onPressed: () {
                                        final int cantidad = int.parse(_cantidadController.text);
                                        final producto = Productos (
                                          sabor: bebida,
                                          cantidad: cantidad,
                                          precio: 25.0,
                                          especificaciones: {},
                                        );
                                        // print(producto);
                                        _addCarrito(producto, args['mesaId']);
                                        
                                        // print('Producto agregado: ${[producto.sabor, producto.cantidad, producto.precio, producto.especificaciones]}');
                                      },
                                      child: const Text('Aceptar y agregar al carrito'),
                                    ),
                                    const SizedBox(height: 20.0),
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      }
                    );
                  }
                ),
                

                
              ],
            ),
            const SizedBox(height: 20.0, width: 10.0,),
          ],
        ),
        )
      ),
    );
  }

  ElevatedButton ButtonProducts(Image image, String name, void Function()? onPressed){ {
      return ElevatedButton(
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(const Size(150.0, 180.0)),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
              ),
              onPressed:onPressed, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: image,
                  ),
                  Text(name,textAlign: TextAlign.center, style: const TextStyle(fontSize: 15.0, color:Colors.blue),),
                ],
              ) 
              );
    }
  }

}