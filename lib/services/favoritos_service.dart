import 'package:shared_preferences/shared_preferences.dart';

// guarda no celular os ids dos lugares favoritos
class FavoritosService {
  Future<List<String>> pegarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favoritos') ?? [];
  }

  Future<void> salvarFavoritos(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoritos', ids);
  }
}
