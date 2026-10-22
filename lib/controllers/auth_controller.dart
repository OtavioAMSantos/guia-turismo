import 'package:flutter/foundation.dart';
import 'package:guia/services/auth_service.dart';
import 'package:guia/services/session_service.dart';

class AuthController extends ChangeNotifier {
  int idLogado = 0;
  bool carregando = false;
  String erro = '';

  // devolve true se o login deu certo e false se deu errado
  Future<bool> autenticarUsuario(String email, String senha) async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      final Map dados = await AuthService().autenticar(email, senha);
      final String? token = dados['token'];
      // se não veio token, o email ou a senha estão errados
      if (token == null) {
        erro = 'Login ou senha inválidos!';
        return false;
      }
      // guarda o token no celular pra usar no cadastro de lugares
      await SessionService().salvarToken(token);
      await SessionService().salvarUsuario(dados['usuario']);
      return true;
    } catch (e) {
      erro = 'Erro: ${e.toString()}';
      return false;
    } finally {
      // o finally roda sempre, dando certo ou errado
      carregando = false;
      notifyListeners();
    }
  }

  Future<void> deslogarUsuario() async {
    await SessionService().logout();
  }
}
