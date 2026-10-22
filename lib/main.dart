import 'package:flutter/material.dart';
import 'package:guia/controllers/auth_controller.dart';
import 'package:guia/controllers/camera_controller.dart';
import 'package:guia/controllers/categorias_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/controllers/theme_controller.dart';
import 'package:guia/screens/cadastro_lugar.dart';
import 'package:guia/screens/login_screen.dart';
import 'package:guia/screens/lugares_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(Inicializar());
}

class Inicializar extends StatefulWidget {
  const Inicializar({super.key});

  @override
  State<Inicializar> createState() => _InicializarState();
}

class _InicializarState extends State<Inicializar> {
  @override
  Widget build(BuildContext context) {
    // o MultiProvider deixa os controllers disponíveis pra todas as telas
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LugaresController()),
        ChangeNotifierProvider(create: (_) => CategoriasController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => CameraController()),
      ],
      // o Consumer do tema fica aqui em cima pra trocar o tema do app inteiro
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeController.temaAtual,
          // o app abre na tela de login
          initialRoute: 'login',
          routes: {
            'login': (context) => LoginScreen(),
            'lugares': (context) => LugaresScreen(),
            'cadastro': (context) => CadastroLugar(),
          },
        ),
      ),
    );
  }
}
