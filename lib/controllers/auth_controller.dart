import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guia/services/auth_service.dart';
import 'package:guia/services/google_auth_service.dart';
import 'package:guia/services/session_service.dart';

class AuthController extends ChangeNotifier {
  int idLogado = 0;
  bool carregando = false;
  String erro = '';
  // usuário que entrou com o Google (null se não entrou). o ? depois de User
  // quer dizer que a variável pode ficar sem valor
  User? usuarioGoogle;

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

  // devolve true se o login com o Google deu certo
  Future<bool> entrarComGoogle() async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      usuarioGoogle = await GoogleAuthService().entrarComGoogle();
      // se a pessoa cancelar a escolha da conta, o usuário volta null
      return usuarioGoogle != null;
    } catch (e) {
      // o erro técnico vai pro console, o usuário vê só a mensagem simples
      erro = 'Erro ao entrar com o Google!';
      debugPrint('Erro ao autenticar: $e');
      return false;
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // sai das duas formas de login (API e Google)
  Future<void> deslogarUsuario() async {
    try {
      await GoogleAuthService().sair();
    } catch (e) {
      debugPrint('Erro ao sair: $e');
    }
    await SessionService().logout();
    usuarioGoogle = null;
    notifyListeners();
  }
}
