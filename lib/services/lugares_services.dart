import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

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
  Future<String> cadastrarLugar(LugaresModel dados, token, {XFile? foto}) async {
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
      debugPrint('[CADASTRO] ${resposta.statusCode} ${resposta.body}');
      final Map<String, dynamic> mensagem = jsonDecode(resposta.body);
      // a API responde status "success" quando cadastra
      if (mensagem['status'] == 'success') {
        // se escolheu foto, envia pra galeria do lugar que acabou de ser
        // criado (a API devolve o id dele em "data")
        final id = mensagem['data']?['id'];
        if (foto != null && id != null) {
          final enviou = await enviarFoto(id, foto, token);
          if (!enviou) {
            return "Lugar cadastrado com sucesso, mas a foto não foi enviada!";
          }
        }
        return "Lugar cadastrado com sucesso!";
      }
      return mensagem['message'] ?? "Erro ao cadastrar: ${resposta.body}";
    } catch (erro) {
      rethrow;
    }
  }

  // POST /lugares/{id}/galeria. manda a foto como arquivo (multipart) no
  // campo "foto". usa os bytes da foto, assim funciona no celular e na web
  Future<bool> enviarFoto(int id, XFile foto, String token) async {
    try {
      final requisicao =
          http.MultipartRequest('POST', Uri.parse('$url/$id/galeria'));
      requisicao.headers['Authorization'] = 'Bearer $token';
      requisicao.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          await foto.readAsBytes(),
          filename: foto.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final resposta = await requisicao.send();
      debugPrint('[FOTO] ${resposta.statusCode} '
          '${await resposta.stream.bytesToString()}');
      return resposta.statusCode == 200 || resposta.statusCode == 201;
    } catch (e) {
      debugPrint('[FOTO] erro: $e');
      return false;
    }
  }
}