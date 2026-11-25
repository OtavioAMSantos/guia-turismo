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

  // liga a conta Google com uma conta da API: tenta logar com o e-mail do
  // Google; se ainda não existe conta, cria e loga. a senha é montada com o
  // uid do Firebase (id único da conta Google), então é sempre a mesma pra
  // essa pessoa e ela não precisa digitar nada
  Future<void> pegarTokenDaApi(User usuario) async {
    final email = usuario.email ?? '';
    final senha = 'google-${usuario.uid}';
    final nome = usuario.displayName ?? email;
    try {
      Map dados = await AuthService().autenticar(email, senha);
      if (dados['token'] == null) {
        await AuthService().cadastrar(nome, email, senha);
        dados = await AuthService().autenticar(email, senha);
      }
      if (dados['token'] != null) {
        await SessionService().salvarToken(dados['token']);
        await SessionService().salvarUsuario(dados['usuario']);
      }
    } catch (e) {
      // se falhar, o login com Google continua valendo; só o cadastro de
      // lugar fica sem token
      debugPrint('Erro ao pegar token da API: $e');
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
      if (usuarioGoogle == null) return false;
      // a API não aceita o token do Google, então pega um token da API
      // pra esse mesmo e-mail (assim dá pra cadastrar lugar)
      await pegarTokenDaApi(usuarioGoogle!);
      return true;
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
