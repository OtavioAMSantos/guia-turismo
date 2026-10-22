import 'package:flutter/material.dart';
import 'package:guia/models/categoria_model.dart';
import 'package:guia/services/categorias_service.dart';

class CategoriasController extends ChangeNotifier {
  bool carregando = false;
  String erro = "";
  List<CategoriaModel> _categorias = [];
  List<CategoriaModel> get categorias => _categorias;

  // busca as categorias assim que o controller é criado
  CategoriasController() {
    listarCategorias();
  }

  Future<void> listarCategorias() async {
    carregando = true;
    erro = "";
    notifyListeners();
    try {
      _categorias = await CategoriasService().buscarCategorias();
    } catch (error) {
      erro = "Erro ao listar categorias: $error";
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
