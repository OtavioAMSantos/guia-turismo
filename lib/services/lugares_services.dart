import 'dart:convert';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/services/api_config.dart';
import 'package:http/http.dart' as http;

class LugaresServices {
  String url = '$baseUrl/lugares';
  int pagina = 1;
  int limite = 10;

  // GET /lugares (pública). pagina e limite controlam a paginação
  Future<List<LugaresModel>> buscarLugares() async {
    try {
      final response = await http.get(
        Uri.parse('$url?pagina=$pagina&limite=$limite'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];
        // transforma cada item do JSON em um LugaresModel
        return data.map((item) => LugaresModel.fromJson(item)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow; 
    }
  }

  // POST /lugares. precisa do token no header Authorization (Bearer)
  Future<String> cadastrarLugar(LugaresModel dados, token) async {
    try {
      if(token.isEmpty) {
        return "Não autorizado!";
      }
      final resposta = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(dados.toJson())
      );
      final Map<String, dynamic> mensagem = jsonDecode(resposta.body);
      // a API responde status "success" quando cadastra
      if (mensagem['status'] == 'success') {
        return "Lugar cadastrado com sucesso!";
      }
      return mensagem['message'] ?? "Erro ao cadastrar: ${resposta.body}";
    } catch (erro) {
      rethrow;
    }
  }
}