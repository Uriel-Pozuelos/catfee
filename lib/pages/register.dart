
// ignore_for_file: avoid_print


import 'package:catfee/components/text_field.dart';
import 'package:catfee/layouts/bottom_navigator.dart';
import 'package:catfee/models/usuario.dart';
// import 'package:catfee/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _id = 0; 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rolController = TextEditingController();
  final supabase = Supabase.instance.client;
  List<Usuario> usuarios = [];
  bool isLoading = false;
  bool isUpdating = false;
  

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }


Future<void> _registerUser(String name, String email, String password,  String rol) async {
  try{
    setState(() {
      isLoading = true;
    });
    await supabase.from('Users').insert(
      {
        'name': name,
        'email': email,
        'password': password,
        'rol': rol,
      }
    );
    
    setState(() {
        _loadUsers();
        isLoading = false;
      });

    _clearTextFields();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuario registrado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }catch (e){
    print(e);
  }
}

Future<void> _loadUsers() async {
  try{
    setState(() {
      isLoading = true;
    });

    final response = await supabase.from('Users').select('*').eq('estatus', 1) as List<dynamic>;
    print(response);

    setState(() {
      usuarios = response.map((usuario) => Usuario.fromJson(usuario)).toList();
      isLoading = false;
    });

  }catch (e){
    print(e);
  }
}

Future<void> _deleteUser(String email) async {
  bool isSure = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('¿Estás seguro de eliminar al usuario con el email: $email?'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          }, 
          child: const Text ('Cancelar'),
          ),

        ElevatedButton( 
          onPressed: () {
            Navigator.of(context).pop(true);
          }, 
          child: const Text ('Eliminar'),
          ),
      ],
    )
  );

  if (isSure){
    try{
      setState(() {
        isLoading = true;
      });
      await supabase.from('Users').update({'estatus':0}).eq('email', email);

      setState(() {
          usuarios = usuarios;
          _loadUsers();
          isLoading = false;
        });
      _clearTextFields();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

    }catch (e){
      print(e);
    }
  }
  
}

Future<void> _updateUser(int id,String name, String email, String password,  String rol) async {
  try{
    setState(() {
      isLoading = true;
    });

    await supabase.from('Users').update({
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'rol': _rolController.text,
    }).eq('id', _id);
    
    setState(() {
        _loadUsers();
        isLoading = false;
        isUpdating = false;
      });
    _clearTextFields();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuario actualizado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }catch (e){
    print(e);
  }
}

void _clearTextFields(){
  _emailController.clear();
  _passwordController.clear();
  _nameController.clear();
  _rolController.clear();
  
  setState(() {
    isUpdating = false;
  });
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de usuarios'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              children: [

                if(isLoading)
                  const Center(
                    child: CircularProgressIndicator.adaptive() ,
                  ),     
                const SizedBox(height: 16.0),

                TextFieldForm(controller: _nameController, keyboardType: TextInputType.text, labelText: 'Nombre',),
                const SizedBox(height: 16.0),

                TextFieldForm(controller: _emailController, keyboardType: TextInputType.emailAddress, labelText: 'Correo electrónico',),
                const SizedBox(height: 16.0),

                TextFieldForm(controller: _passwordController, keyboardType: TextInputType.visiblePassword, labelText: 'Contraseña',),
                const SizedBox(height: 16.0),


                TextFieldForm(controller: _rolController, keyboardType: TextInputType.text, labelText: 'Rol',),
                const SizedBox(height: 16.0),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUpdating ? Colors.amber  :Colors.green ,
                      ),
                      onPressed:() {
                        isUpdating ? _updateUser(_id, _nameController.text, _emailController.text, _passwordController.text, _rolController.text) 
                        : _registerUser( _nameController.text, _emailController.text, _passwordController.text, _rolController.text);
                      },
                      child: Text(isUpdating ? 'Actualizar' : 'Registar usuario', style: TextStyle(color: isUpdating ?  Colors.black : Colors.white),),
                    ),
                    const SizedBox(width: 10.0),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                      ),
                      onPressed: () => _clearTextFields(),
                      child: const Text('Limpiar campos', style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                
                DataTable(
                  dataTextStyle: const TextStyle(fontSize: 15.0),
                  headingRowColor: WidgetStateProperty.all(Colors.lightBlue[300]),
                  headingRowHeight: 30.0,
                  headingTextStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.black),
                  dataRowColor: WidgetStateProperty.all(Colors.lightBlue[100]),
                  dataRowMinHeight: 30.0,
                  dataRowMaxHeight: 35.0,
                  
                  columnSpacing: 8.0,


                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Correo')),
                    DataColumn(label: Text('Rol')),
                    DataColumn(label: Text('Eliminar')),
                    DataColumn(label: Text('Editar')),
                  ],
                  rows: usuarios.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(Text(user.name)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.rol)),
                        DataCell(
                          const Icon(Icons.delete, color: Color.fromARGB(255, 236, 0, 0),),
                          onTap: () {
                            _deleteUser(user.email);
                          },
                        ),
                        DataCell(
                          const Icon(Icons.edit, color: Color.fromARGB(255, 0, 0, 236),),
                          onTap: () {
                            _emailController.text = user.email;
                            _nameController.text = user.name;
                            _passwordController.text = user.password;
                            _rolController.text = user.rol;
                            _id = int.parse(user.id);

                            setState(() {
                              isUpdating = true;

                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),
                )

              ],              
            ),


          )
        )
          ),
          bottomNavigationBar: const BottomNavigator(
            selectedIndex: 0,
            child: SizedBox(),
          ),
    );
  }

}



