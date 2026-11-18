import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guia/controllers/auth_controller.dart';
import 'package:guia/controllers/camera_controller.dart';
import 'package:guia/controllers/categorias_controller.dart';
import 'package:guia/controllers/favoritos_controller.dart';
import 'package:guia/controllers/localizacao_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/controllers/theme_controller.dart';
import 'package:guia/screens/cadastro_lugar.dart';
import 'package:guia/screens/login_screen.dart';
import 'package:guia/screens/lugares_screen.dart';
import 'package:guia/screens/mapa_screen.dart';
import 'package:guia/services/session_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  // obrigatório quando o main usa await antes do runApp
  WidgetsFlutterBinding.ensureInitialized();
  // liga o Firebase. o firebase_options.dart foi gerado pelo flutterfire
  // e tem as chaves do nosso projeto
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // confere se já tem sessão salva: login do Google (o Firebase guarda sozinho)
  // ou o token do login com e-mail e senha
  final token = await SessionService().pegarToken();
  final logado = FirebaseAuth.instance.currentUser != null || token != null;
  runApp(Inicializar(rotaInicial: logado ? 'lugares' : 'login'));
}

class Inicializar extends StatefulWidget {
  final String rotaInicial;

  const Inicializar({super.key, required this.rotaInicial});

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
        ChangeNotifierProvider(create: (_) => LocalizacaoController()),
        ChangeNotifierProvider(create: (_) => FavoritosController()),
      ],
      // o Consumer do tema fica aqui em cima pra trocar o tema do app inteiro
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Guia de Turismo',
          // as cores do app saem todas da cor teal
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeController.temaAtual,
          // abre direto nos lugares se já estiver logado, senão no login
          initialRoute: widget.rotaInicial,
          routes: {
            'login': (context) => LoginScreen(),
            'lugares': (context) => LugaresScreen(),
            'cadastro': (context) => CadastroLugar(),
            'mapa': (context) => MapaScreen(),
          },
        ),
      ),
    );
  }
}
