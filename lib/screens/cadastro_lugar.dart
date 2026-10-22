import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guia/controllers/camera_controller.dart';
import 'package:guia/controllers/categorias_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/controllers/theme_controller.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:provider/provider.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  // id da categoria escolhida no dropdown (null = ainda não escolheu)
  int? categoriaId;

  void limparFormulario() {
    nomeController.clear();
    descricaoController.clear();
    latitudeController.clear();
    longitudeController.clear();
    // setState porque categoriaId é uma variável da tela
    setState(() {
      categoriaId = null;
    });
    context.read<CameraController>().limparImagem();
  }

  Future<void> salvar(LugaresController lugaresController) async {
    // não deixa salvar com campo vazio
    if (nomeController.text.isEmpty ||
        descricaoController.text.isEmpty ||
        latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty ||
        categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }
    try {
      // o campo de texto devolve String, então converte pra double.
      // o replace troca vírgula por ponto (ex: -23,46 vira -23.46)
      final lugar = LugaresModel(
        id: 0,
        nome: nomeController.text,
        descricao: descricaoController.text,
        latitude: double.parse(latitudeController.text.replaceAll(',', '.')),
        longitude: double.parse(longitudeController.text.replaceAll(',', '.')),
        categoriaId: categoriaId!,
      );
      String mensagem = await lugaresController.cadastrarLugar(lugar);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
      // só limpa o formulário se deu certo
      if (mensagem.contains('sucesso')) {
        limparFormulario();
      }
    } catch (e) {
      // o double.parse dá erro se digitar letra no lugar de número
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dados inválidos!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar lugar"),
        actions: [
          // context.read chama o método sem reconstruir a tela
          IconButton(
            onPressed: () => context.read<ThemeController>().alternarTema(),
            icon: Icon(Icons.brightness_6),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, 'lugares'),
            icon: Icon(Icons.list),
          ),
        ],
      ),
      // SingleChildScrollView deixa a tela rolar quando o teclado abre
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: "Descrição"),
              maxLines: 3,
            ),
            // signed: true deixa digitar o sinal de menos (latitude e longitude
            // negativas)
            TextField(
              controller: latitudeController,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: "Latitude"),
            ),
            TextField(
              controller: longitudeController,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: "Longitude"),
            ),
            SizedBox(height: 16),
            // dropdown com as categorias que vieram da API
            Consumer<CategoriasController>(
              builder: (context, categoriasController, child) {
                if (categoriasController.carregando) {
                  return CircularProgressIndicator();
                }
                if (categoriasController.erro != '') {
                  return Text(categoriasController.erro);
                }
                return DropdownButton<int>(
                  isExpanded: true,
                  hint: Text("Categoria"),
                  value: categoriaId,
                  // transforma cada categoria em uma opção da lista
                  items: categoriasController.categorias.map((categoria) {
                    return DropdownMenuItem<int>(
                      value: categoria.id,
                      child: Text(categoria.nome),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      categoriaId = valor;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16),
            // parte da foto
            Consumer<CameraController>(
              builder: (context, cameraController, child) {
                final imagem = cameraController.imagemSelecionada;
                return Column(
                  children: [
                    if (cameraController.carregando)
                      CircularProgressIndicator()
                    else if (imagem != null)
                      // kIsWeb é true quando roda no navegador. lá a foto é um
                      // endereço (network), no celular é um arquivo (file)
                      kIsWeb
                          ? Image.network(imagem.path,
                              height: 180, fit: BoxFit.cover)
                          : Image.file(File(imagem.path),
                              height: 180, fit: BoxFit.cover),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: cameraController.abrirCamera,
                          icon: Icon(Icons.camera_alt),
                          label: Text("Câmera"),
                        ),
                        TextButton.icon(
                          onPressed: cameraController.abrirGaleria,
                          icon: Icon(Icons.photo_library),
                          label: Text("Galeria"),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 24),
            Consumer<LugaresController>(
              builder: (context, lugaresController, child) {
                if (lugaresController.carregando) {
                  return CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () => salvar(lugaresController),
                  child: Text("Salvar"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
