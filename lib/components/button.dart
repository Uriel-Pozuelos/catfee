import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget{
    final VoidCallback onPressed;
    final String estatus;
    final int id;

    
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.estatus,
    required this.id,
  }) : super();
  
  @override
  Widget build(BuildContext context){
    return ElevatedButton(       
          style: ButtonStyle(
            fixedSize: WidgetStateProperty.all(const Size(20.0, 20.0)),
            backgroundColor: WidgetStateProperty.resolveWith((states) => estatusColor[estatus] ?? Colors.grey),
            padding: WidgetStateProperty.all(const EdgeInsets.all(5.0)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
          ),
          onPressed: onPressed, 
          child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('$id', style: const TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold ),),
                const SizedBox(height: 10.0),
                Text(estatus, style: const TextStyle(fontSize: 15.0, color: Colors.white, fontWeight: FontWeight.bold),),
              ],
            ),
          );
  }

}

final Map<String,Color> estatusColor = {
    'Disponible': Colors.green,
    'Ocupada': Colors.red,
    'Ordenando': Colors.orange,
    'Comiendo': Colors.purple,
    'Limpiar': Colors.blue,
};
