// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:catfee/components/text_field.dart';
import 'package:catfee/models/usuario.dart';
import 'package:catfee/utils/router.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/user_data.dart';


class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage>{

  @override
  void initState() {
    super.initState();
    _loadUserData();  
  }

  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> _loadUserData() async {
    final Usuario? isUser = await getUserData();
    print('actualUser: $isUser');
    if (isUser != null){
      navigateTo(context, isUser.rol);
    }
  }

  Future<void> _signIn () async {
    
    setState(() {
      isLoading = true;
    });

    try{
      final response = await Supabase.instance.client
      .from('Users')
      .select('*')
      .eq('email', _emailController.text)
      .single();

      if(response.isNotEmpty){
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData',jsonEncode(response));
        print(prefs.getString('userData'));

        //Obtenemos los datos del usuario de los shared preferences
        final Usuario? user = await getUserData();  
        if (user == null){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al obtener los datos del usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }

        setState(() {
          isLoading = false;
        });

        if(_passwordController.text == user?.password){
          if(mounted){
            navigateTo(context, user!.rol);
          }

        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La contraseña no coincide'),
              backgroundColor: Colors.red,
            ),
          );
        }

      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El usuario no existe'),
            backgroundColor: Colors.red,
          ),
        );
      }


    } on AuthException catch(e){
      

      print('Error: ${e.message}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
      
    }catch(e){

      // print('Error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

    } finally {
      setState(() {
        isLoading = false;
      });
    }

  }

  @override
Widget build(BuildContext context){
  return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      backgroundColor:const Color.fromARGB(255, 231, 254, 255),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120.0),
                  child: Column(
                    children: [

                      Column(
                        children: [
                          const Text('Catfee', style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),),
                          Container(
                            width: 150,
                            height: 150,
                            margin: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                            child: Image.asset('assets/images/catfee.jpg'),
                          ),
                        ],
                      ),

                      TextFieldForm(controller: _emailController, keyboardType: TextInputType.emailAddress, labelText: 'Correo electrónico',),  
                      const SizedBox(height: 16.0),

                      TextFieldForm(controller: _passwordController, keyboardType: TextInputType.visiblePassword, labelText: 'Contraseña', obscureText: true,),
                      const SizedBox(height: 16.0),


                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.black),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0)),
                        ),
                        onPressed: _signIn,
                        child: const Text('Iniciar sesión', style: TextStyle(fontSize: 15.0, color: Colors.white),),
                      ),
                    ],
                  )
                  
                ),

              ],
              )
          )
        )
      ),
    );
  }

  
}

