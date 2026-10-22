import 'package:flutter/foundation.dart';
import 'package:guia/services/camera_service.dart';
import 'package:image_picker/image_picker.dart';

class CameraController extends ChangeNotifier {
  final CameraService _service = CameraService();
  bool carregando = false;
  XFile? _imagemSelecionada;
  XFile? get imagemSelecionada => _imagemSelecionada;

  Future<void> abrirCamera() async {
    carregando = true;
    notifyListeners();
    try {
      _imagemSelecionada = await _service.chamarCamera();
    } catch (e) {
      debugPrint("$e");
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> abrirGaleria() async {
    carregando = true;
    notifyListeners();
    try {
      _imagemSelecionada = await _service.chamarGaleria();
    } catch (e) {
      debugPrint("$e");
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // tira a foto da tela depois que o lugar é cadastrado
  void limparImagem() {
    _imagemSelecionada = null;
    notifyListeners();
  }
}
