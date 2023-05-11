// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rede_social/pages/cadastrar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rede_social/pages/feed.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  _loginFirebase() async {
    final response = await http.post(
      Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${dotenv.env['FIREBASE_TOKEN']}"),
      body: jsonEncode(
        {
          'email': _emailController.text,
          'password': _senhaController.text,
          'returnSecureToken': true,
        },
      ),
    );

    Map responseData = jsonDecode(response.body);

    if (responseData['error'] == null) {
      Box box = await Hive.openBox('usuarios');
      box.put('idToken', responseData['idToken']);
      box.put('email', responseData['email']);
      box.put('refreshToken', responseData['refreshToken']);
      box.put('expiresIn', responseData['expiresIn']);
      box.put('localId', responseData['localId']);
      box.put('registered', responseData['registered']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário loggado com sucesso'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Feed(),
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
          const Text('LOGIN'),
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
            onPressed: _loginFirebase,
            child: const Text('FAZER LOGIN'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Cadastrar(),
                ),
              );
            },
            child: const Text('CADASTRAR'),
          ),
        ],
      ),
    );
  }
}
