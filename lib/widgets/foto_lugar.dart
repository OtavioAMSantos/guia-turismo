import 'package:flutter/material.dart';

// mostra a primeira foto do lugar. se não tiver foto ou der erro, mostra um ícone
class FotoLugar extends StatelessWidget {
  final List<String> fotos;
  final double altura;

  const FotoLugar({super.key, required this.fotos, this.altura = 180});

  @override
  Widget build(BuildContext context) {
    final semFoto = Container(
      height: altura,
      color: Colors.grey.shade300,
      child: Center(child: Icon(Icons.image_not_supported, size: 40)),
    );
    if (fotos.isEmpty) {
      return semFoto;
    }
    return Image.network(
      fotos[0],
      height: altura,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => semFoto,
    );
  }
}
