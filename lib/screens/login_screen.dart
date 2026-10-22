import 'package:flutter/material.dart';
import 'package:guia/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // guardam o que foi digitado nos campos
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      // o Consumer refaz a tela quando o AuthController chama notifyListeners
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "E-mail"),
                ),
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Senha"),
                ),
                SizedBox(height: 20),
                // enquanto está carregando mostra o círculo no lugar do botão
                if (authController.carregando)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () async {
                      bool ok = await authController.autenticarUsuario(
                        emailController.text,
                        senhaController.text,
                      );
                      // depois de um await, confere se a tela ainda existe
                      if (!mounted) return;
                      if (ok) {
                        // pushReplacement troca a tela, assim o botão voltar
                        // não leva de novo pro login
                        Navigator.pushReplacementNamed(context, 'lugares');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authController.erro)),
                        );
                      }
                    },
                    child: Text("Entrar"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
