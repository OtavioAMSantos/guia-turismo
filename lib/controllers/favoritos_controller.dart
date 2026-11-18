import 'package:flutter/material.dart';
import 'package:guia/services/favoritos_service.dart';

class FavoritosController extends ChangeNotifier {
  final FavoritosService _service = FavoritosService();
  // lista de ids dos favoritos. é lista de texto porque o shared_preferences
  // só guarda lista de String (por isso o id vira texto com toString)
  List<String> _ids = [];

  // carrega os favoritos salvos quando o controller é criado
  FavoritosController() {
    carregar();
  }

  Future<void> carregar() async {
    _ids = await _service.pegarFavoritos();
    notifyListeners();
  }

  bool ehFavorito(int id) => _ids.contains(id.toString());

  // se já é favorito tira, se não é coloca
  Future<void> alternar(int id) async {
    if (ehFavorito(id)) {
      _ids.remove(id.toString());
    } else {
      _ids.add(id.toString());
    }
    // avisa a tela primeiro, assim o coração muda na hora, sem esperar salvar
    notifyListeners();
    try {
      await _service.salvarFavoritos(_ids);
    } catch (e) {
      debugPrint('Erro ao salvar favorito: $e');
    }
  }
}
