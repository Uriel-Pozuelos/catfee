// ignore_for_file: avoid_print

import 'package:catfee/layouts/bottom_navigator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  DateTimeRange? _rangoFecha;
  List<Map<String, dynamic>> ventas = [];
  bool isLoading = false;
  totalVentas() {
    double total = 0;
    for (var venta in ventas) {
      total += venta['total'];
    }
    return total;
  }
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initialDate();
    _loadData();
  }

  void _initialDate() async {
    // const String dateStr = '2024-08-07 22:51:16.315';
    // DateTime date = DateTime.parse(dateStr);
    final now = DateTime.now();
    _rangoFecha = DateTimeRange(
      // start: DateTime(date.year, date.month, date.day),
      // end: DateTime(date.year, date.month, date.day, 23, 59, 59),
      
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
    print('Fecha inicial: ${_rangoFecha!.start} - ${_rangoFecha!.end}');

  }

  Future<void> _selectDateRange() async {
    //mostramos el selector de rango de fechas 
    final DateTimeRange? fechaSeleccionada = await showDateRangePicker(
      context: context,
      initialDateRange: _rangoFecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    //Si se selecciona un rango diferente al actual se actualiza el estado
    if (fechaSeleccionada != null && fechaSeleccionada != _rangoFecha) {
      setState(() {
        isLoading = true;
        final inicio = DateTime(
          fechaSeleccionada.start.year,
          fechaSeleccionada.start.month,
          fechaSeleccionada.start.day,
          0, 0, 0,
        );

        final fin = DateTime(
          fechaSeleccionada.end.year,
          fechaSeleccionada.end.month,
          fechaSeleccionada.end.day,
          23, 59, 59,
        );

        _rangoFecha = DateTimeRange(start: inicio, end: fin);
        
        print('fecha seleccionada: $fechaSeleccionada');
        print('rango de fecha: ${_rangoFecha!.start} - ${_rangoFecha!.end}'); 
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    //Si no se ha seleccionado una fecha no se hace nd 
    if (_rangoFecha == null) return;

    setState(() {
      isLoading = true;
    });

    //Se formatea la fecha para hacer match con la base de datos
    final format = DateFormat('yyyy-MM-dd HH:mm:ss');
    final inicio = format.format(_rangoFecha!.start);
    final fin = format.format(_rangoFecha!.end);

    //Se extrae el dia de la fecha de inicio 
    final dia = DateFormat('dd').format(_rangoFecha!.start);
    
    print('Dia: $dia');
    print('Inicio: $inicio');
    print('Fin: $fin');

    //Se consultan los datos de la venta tomando en cuenta la fecha de inicio y fin
    final response = await supabase
        .from('Venta')
        .select('*, Detalle_Venta(*,Producto(*))')
        .gte('fecha', inicio)
        .lte('fecha', fin)
        .eq('estado', 'Pagada');       

    //Si no hay datos asignamos una lista vacia y si no se asinga la respuesta a la lista de ventas
    if (response.isEmpty) {

      setState(() {
        isLoading = false;
        ventas = [];
      });
      print('Error al obtener datos: $response');

    } else {

      setState(() {
        isLoading = false;
        ventas = response ;
      });
      print('Datos obtenidos: $ventas');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            if(isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 20.0),

            
            ElevatedButton(
              onPressed: _selectDateRange,
              style:  ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              ),
              child: Text(
                _rangoFecha == null
                    ? 'Fecha seleccionada'
                    : 'Fecha seleccionada: ${_rangoFecha!.start.toLocal()} \n${_rangoFecha!.end.toLocal()}',
              ),
            ),
            const SizedBox(height: 20.0),


            //Se muestra la fecha seleccionada si hay una cargada
            if (_rangoFecha != null)
                Text(
                  'Fecha inicial:${_rangoFecha!.start.toLocal()} \nFecha final: ${_rangoFecha!.end.toLocal()}',
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20.0),

            //Si hay ventas se mapean los datos y se muestran en la tabla
            if (ventas.isNotEmpty)

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    
                    child: Column(
                      children: [
                        DataTable(
                          dataTextStyle: const TextStyle(fontSize: 15.0),
                          headingRowColor: WidgetStateProperty.all(Colors.lightBlue[300]),
                          headingRowHeight: 30.0,
                          headingTextStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),
                          dataRowColor: WidgetStateProperty.all(Colors.lightBlue[100]),
                          dataRowMinHeight: 30.0,
                          dataRowMaxHeight: 35.0,
                          
                          columns: const [
                            DataColumn(label: Text('Id')),
                            DataColumn(label: Text('Mesa')),
                            DataColumn(label: Text('Fecha')),
                            DataColumn(label: Text('Total')),
                          ],
                          
                          rows:ventas.map((e) {
                            //Formateamos la fecha para mostrarla de forma simple en la tabla
                            final fecha = DateFormat('yyyy-MM-dd').format(DateTime.parse(e['fecha']));
                            print (fecha);
                            return DataRow(
                              cells: [
                                DataCell(Text(e['id'].toString())),
                                DataCell(Text(e['mesaId'].toString())),
                                DataCell(Text(fecha.toString())),
                                DataCell(Text(e['total'].toString())),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20.0),
                        Text('Total de ventas: \$${totalVentas()}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                      ],
                    ),

                  ),
                ),
              const SizedBox(height: 20.0),

              //Se evalua si no hay ventas para la fecha seleccionada 
              if (ventas.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        Text('No hay ventas para mostrar', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                        SizedBox(height: 20.0),
                      ],
                    )
                  ),

          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigator(
        selectedIndex: 2,
        child: SizedBox(),
      ),
    );
  }
}
