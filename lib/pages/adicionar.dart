// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Adicionar extends StatefulWidget {

  const Adicionar({super.key});

  @override
  State<Adicionar> createState() => _AdicionarState();
}

class _AdicionarState extends State<Adicionar> {
  final tituloController = TextEditingController();
  final fotoController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            controller: tituloController,
            decoration: const InputDecoration(
              label: Text('Título')
            )
          ),
          TextFormField(
            controller: fotoController,
            decoration: const InputDecoration(
              label: Text('Foto')
            ),
          ),
          TextFormField(
            controller: latitudeController,
            decoration: const InputDecoration(
              label: Text('Latitude')
            ),
          ),
          TextFormField(
            controller: longitudeController,
            decoration: const InputDecoration(
              label: Text('Longitude')
            ),
          ),
          ElevatedButton(onPressed: () async {
            Box box = await Hive.openBox('usuarios');

            final response = await http.post(
              Uri.parse("${dotenv.env['HOST_API']}/posts.json"),
              body: jsonEncode({
                'title': tituloController.text,
                'user_id': box.get('localId'),
                'photo': fotoController.text,
                'user_email': box.get('email'),
                'lat': latitudeController.text,
                'lng': longitudeController.text,
              }),
            );
            
            if (response.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Postagem criada com sucesso'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erro ao criar postagem'),
                ),
              );
            }

          }, child: const Text('Fazer Postagem'))
        ],
      ),
    );
  }
}