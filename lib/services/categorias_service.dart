import 'dart:convert';
import 'package:guia/models/categoria_model.dart';
import 'package:guia/services/api_config.dart';
import 'package:http/http.dart' as http;

class CategoriasService {
  // GET /categorias (rota pública, não precisa de token)
  Future<List<CategoriaModel>> buscarCategorias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categorias'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        // cada item do JSON vira um CategoriaModel
        return data.map((item) => CategoriaModel.fromJson(item)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
