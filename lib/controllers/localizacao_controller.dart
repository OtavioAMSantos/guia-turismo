import 'package:flutter/material.dart';
import 'package:guia/services/localizacao_service.dart';
import 'package:latlong2/latlong.dart';

class LocalizacaoController extends ChangeNotifier {
  final LocalizacaoService _service = LocalizacaoService();
  // posição do usuário. fica null enquanto não conseguiu pegar (GPS desligado,
  // sem permissão...), por isso as telas sempre conferem antes de usar
  LatLng? posicao;
  String erro = '';
  bool carregando = false;

  Future<void> buscarPosicao() async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      posicao = await _service.pegarPosicao();
    } catch (e) {
      // o erro que o service jogou vira o texto que aparece na tela
      erro = e.toString();
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // texto da distância até o lugar, ex: "850 m" ou "2.3 km".
  // devolve texto vazio se não tiver a posição ou o lugar não tiver coordenada
  String distanciaAte(double? latitude, double? longitude) {
    if (posicao == null || latitude == null || longitude == null) {
      return '';
    }
    final metros = _service.distanciaEmMetros(posicao!, latitude, longitude);
    // menos de 1000 m mostra em metros, senão divide por 1000 pra virar km
    if (metros < 1000) {
      return '${metros.round()} m';
    }
    // toStringAsFixed(1) deixa só 1 casa depois da vírgula
    return '${(metros / 1000).toStringAsFixed(1)} km';
  }
}
