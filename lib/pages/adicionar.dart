// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class Adicionar extends StatefulWidget {
  const Adicionar({super.key});

  @override
  State<Adicionar> createState() => _AdicionarState();
}

class _AdicionarState extends State<Adicionar> {
  final tituloController = TextEditingController();
  Position? localizacao;
  CameraController? cameraController;
  late List<CameraDescription> _cameras;
  XFile? _imagem;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    localizacao = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  @override
  void initState() {
    _determinePosition();
    _inicializarCamera();
    super.initState();
  }

  _inicializarCamera() async {
    _cameras = await availableCameras();
    cameraController = CameraController(_cameras[0], ResolutionPreset.max);
    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null) {
      return Container();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            controller: tituloController,
            decoration: const InputDecoration(label: Text('Título')),
          ),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: CameraPreview(cameraController!)
            ),
          ElevatedButton(onPressed: () async {
            _imagem = await cameraController!.takePicture();
            final permissaoFotos = await Permission.photos.request();
            final permissaoExternal = await Permission.manageExternalStorage.request();
            final imageBytes = await _imagem!.readAsBytes();
            await ImageGallerySaver.saveImage(imageBytes);
          }, child: const Text('Tirar Foto')),
          ElevatedButton(
              onPressed: localizacao != null
                  ? () async {
                      Box box = await Hive.openBox('usuarios');
                      final Uuid uuid = Uuid();

                      final responseImagem = await http.post(
                        Uri.parse("${dotenv.env['HOST_STORAGE']}${uuid.v4()}.jpg"),
                        body: await _imagem!.readAsBytes()
                      );

                      final resDataImg = jsonDecode(responseImagem.body);

                      final response = await http.post(
                        Uri.parse("${dotenv.env['HOST_API']}/posts.json"),
                        body: jsonEncode({
                          'title': tituloController.text,
                          'user_id': box.get('localId'),
                          'photo': '${dotenv.env['HOST_STORAGE']}${resDataImg['name']}?alt=media&token=${resDataImg['downloadTokens']}',
                          'user_email': box.get('email'),
                          'lat': localizacao!.latitude.toString(),
                          'lng': localizacao!.longitude.toString(),
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
                    }
                  : null,
              child: const Text('Fazer Postagem'))
        ],
      ),
    );
  }
}
