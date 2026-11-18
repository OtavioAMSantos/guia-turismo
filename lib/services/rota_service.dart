import 'package:url_launcher/url_launcher.dart';

// abre o Google Maps com a rota até o lugar.
// é só montar um link no formato que o Google Maps entende (destination é o
// destino) e pedir pro celular abrir
class RotaService {
  Future<bool> abrirRota(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    // externalApplication abre fora do app (no app do Google Maps ou navegador).
    // devolve true se conseguiu abrir
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
