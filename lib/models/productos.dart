class Productos {
  final String sabor;
  final int cantidad;
  final double precio;
  final Map<String,dynamic> especificaciones;

  Productos({
    required this.sabor,
    required this.cantidad,
    required this.precio,
    this.especificaciones = const{},
  });
  
  factory Productos.fromMap(Map<String,dynamic> map) {
    return Productos(
      sabor: map['sabor'],
      cantidad: map['cantidad'],
      precio: map['precio'],
      especificaciones: Map<String,dynamic>.from(map['especificaciones'] ?? {}),
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'sabor': sabor,
      'cantidad': cantidad,
      'precio': precio,
      'especificaciones': especificaciones,
    };
  }

   @override
  String toString() {
    return 'Producto(sabor: $sabor, cantidad: $cantidad, precio: $precio, especificaciones: $especificaciones)';
  }

}


