import 'package:image_picker/image_picker.dart';

// usa o pacote image_picker pra abrir a câmera ou a galeria.
// XFile é o tipo de arquivo que o pacote devolve (ou null se cancelar)
class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> chamarCamera() async {
    return await _picker.pickImage(source: ImageSource.camera);
  }

  Future<XFile?> chamarGaleria() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }
}
