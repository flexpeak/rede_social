// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rede_social/pages/login.dart';
import 'package:http/http.dart' as http;

class Registrar extends StatefulWidget {
  const Registrar({super.key});

  @override
  State<Registrar> createState() => _RegistrarState();
}

class _RegistrarState extends State<Registrar> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  _registrarUsuario() async {
    String url = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCayuK2Cv8zNzEEUzkybRH1wOf5SbMMCDU';

    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({
        'email': _emailController.text,
        'password': _senhaController.text,
        'returnSecureToken': true,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (responseData['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['error']['message']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(10))),
          width: size.width / 1.3,
          height: size.height / 2.5,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'REGISTRAR-SE',
                  style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width / 1.5,
                  child: TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      labelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width / 1.5,
                  child: TextFormField(
                    controller: _senhaController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma senha válida';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        hintText: 'Senha',
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _registrarUsuario();
                        }
                      },
                      child: const Text('REGISTRAR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
                      },
                      child: const Text('FAZER LOGIN'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
