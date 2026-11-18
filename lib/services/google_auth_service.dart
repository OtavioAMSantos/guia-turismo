import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // usuário que já está logado (o Firebase guarda a sessão sozinho, então
  // se fechar e abrir o app de novo ele continua aqui). null = ninguém logado
  User? get usuarioAtual => FirebaseAuth.instance.currentUser;

  Future<User?> entrarComGoogle() async {
    // late final = a variável só recebe valor depois, dentro do if/else
    late final UserCredential resultado;

    // kIsWeb é true quando roda no navegador. lá abre um popup do Google
    if (kIsWeb) {
      resultado =
          await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } else {
      // no celular: o google_sign_in abre a escolha da conta e devolve um
      // idToken. esse token é a "prova" de que a pessoa logou no Google
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      final conta = await googleSignIn.authenticate();
      // troca o token do Google por uma credencial que o Firebase entende
      final credencial =
          GoogleAuthProvider.credential(idToken: conta.authentication.idToken);

      // entrega a credencial pro Firebase, que registra o usuário
      resultado = await FirebaseAuth.instance.signInWithCredential(credencial);
    }
    return resultado.user;
  }

  // precisa sair das duas: do Google e do Firebase
  Future<void> sair() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
