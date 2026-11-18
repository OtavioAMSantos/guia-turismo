import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// usa o GPS do celular pelo pacote geolocator.
// pra pegar a posição tem 3 passos: GPS ligado, permissão e aí sim a posição
class LocalizacaoService {
  Future<LatLng> pegarPosicao() async {
    // se algum passo falhar, joga um erro (throw) que o controller captura
    // confere se o GPS está ligado
    final gpsLigado = await Geolocator.isLocationServiceEnabled();
    if (!gpsLigado) {
      throw Exception('GPS desligado!');
    }
    // pede permissão pro usuário se ainda não tiver.
    // denied = ainda não deixou, deniedForever = marcou "nunca" (aí o app
    // não consegue nem perguntar de novo)
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada!');
    }
    final posicao = await Geolocator.getCurrentPosition();
    return LatLng(posicao.latitude, posicao.longitude);
  }

  // distância em linha reta (em metros) entre dois pontos.
  // o geolocator já faz a conta pela curvatura da Terra
  double distanciaEmMetros(LatLng a, double latitude, double longitude) {
    return Geolocator.distanceBetween(
        a.latitude, a.longitude, latitude, longitude);
  }
}
