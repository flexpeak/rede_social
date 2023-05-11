// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rede_social/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Cadastrar extends StatefulWidget {
  const Cadastrar({super.key});

  @override
  State<Cadastrar> createState() => _CadastrarState();
}

class _CadastrarState extends State<Cadastrar> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  _cadastrarFirebase() async {
    final response = await http.post(
      Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${dotenv.env['FIREBASE_TOKEN']}"),
      body: jsonEncode({
        'email': _emailController.text,
        'password': _senhaController.text,
        'returnSecureToken': true,
      }),
    );

    Map responseData = jsonDecode(response.body);

    if (responseData['error'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário criado com sucesso'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['error']['message']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('CADASTRAR'),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              label: Text('Email'),
            ),
          ),
          TextFormField(
            controller: _senhaController,
            decoration: const InputDecoration(label: Text('Senha')),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _cadastrarFirebase,
            child: const Text('CADASTRAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
              );
            },
            child: const Text('FAZER LOGIN'),
          ),
        ],
      ),
    );
  }
}
