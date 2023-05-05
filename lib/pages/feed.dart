// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rede_social/pages/login.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Usuário Logado'),
          ElevatedButton(
            onPressed: () async {
              Box userBox = await Hive.openBox('user');
              userBox.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
