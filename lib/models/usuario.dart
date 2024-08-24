class Usuario {
  final String id;
  final String name;
  final String email;
  final String password;
  final String rol;

  Usuario({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      password: json['password'],
      rol: json['rol'],
    );
  }
}