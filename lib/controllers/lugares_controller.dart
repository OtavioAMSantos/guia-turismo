import 'package:flutter/material.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/services/lugares_services.dart';
import 'package:guia/services/session_service.dart';

class LugaresController extends ChangeNotifier {
  bool carregando = false;
  String erro = "";
  List<LugaresModel> _lugares = [];
  List<LugaresModel> get lugares => _lugares;

  //inicializar (já busca os lugares quando o controller é criado)
  LugaresController() {
    listarLugares();
  }

  Future<void> listarLugares() async {
    carregando = true;
    erro = "";
    notifyListeners(); 
    try {
      final lugaresService = LugaresServices();
      final listaLugares = await lugaresService.buscarLugares();
      _lugares = listaLugares;
    } catch (error) {
      erro = "Erro ao listar: $error";
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<String> cadastrarLugar(LugaresModel dados) async {
    // pega o token salvo no login. se não tiver, usa texto vazio
    final token = await SessionService().pegarToken() ?? '';
    carregando = true;
    erro = "";
    notifyListeners();
    try {
      final lugaresService = LugaresServices();
      final resposta = await lugaresService.cadastrarLugar(dados, token);
      // atualiza a lista pra o lugar novo aparecer
      await listarLugares();
      return resposta;
    } catch (e) {
      erro = "Erro ao cadastrar: $e";
      return erro;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
