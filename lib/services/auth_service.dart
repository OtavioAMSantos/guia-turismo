import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:guia/services/api_config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String url = '$baseUrl/login';

  // manda email e senha pra API (POST /login).
  // se der certo devolve o "data" da resposta, que tem o token e o usuário
  Future<Map> autenticar(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "senha": senha}),
      );
      final dados = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return dados['data'];
      } else {
        debugPrint(dados.toString());
        return {};
      }
    } catch(e) {
      rethrow;
    }
  } 
}
