import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guia/controllers/auth_controller.dart';
import 'package:guia/controllers/favoritos_controller.dart';
import 'package:guia/controllers/localizacao_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/widgets/lugar_detalhes.dart';
import 'package:provider/provider.dart';

class LugaresScreen extends StatefulWidget {
  const LugaresScreen({super.key});

  @override
  State<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends State<LugaresScreen> {
  @override
  void initState() {
    super.initState();
    // pega a localização pra mostrar a distância de cada lugar
    context.read<LocalizacaoController>().buscarPosicao();
  }

  // sai da conta e volta pra tela de login. o mounted confere se a tela ainda
  // existe depois do await
  Future<void> sair() async {
    await context.read<AuthController>().deslogarUsuario();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    // usuário do Google (fica null quando entrou com e-mail e senha)
    final usuarioGoogle = FirebaseAuth.instance.currentUser;
    final foto = usuarioGoogle?.photoURL;
    return Scaffold(
      appBar: AppBar(
        title: Text("Lugares para visitar"),
        actions: [
          // foto e nome da conta Google. se não tiver foto mostra um ícone
          if (usuarioGoogle != null)
            Tooltip(
              message: usuarioGoogle.displayName ?? usuarioGoogle.email ?? '',
              child: CircleAvatar(
                radius: 16,
                backgroundImage: foto != null ? NetworkImage(foto) : null,
                child: foto == null ? Icon(Icons.person, size: 18) : null,
              ),
            ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, 'mapa'),
            icon: Icon(Icons.map),
          ),
          IconButton(onPressed: sair, icon: Icon(Icons.logout)),
        ],
      ),
      body: Consumer<LugaresController>(
        builder: (context, lugaresController, child) {
          // a tela mostra uma coisa diferente dependendo do estado do controller
          if(lugaresController.carregando) {
            return Center(child: CircularProgressIndicator());
          }
          if(lugaresController.erro != '') {
            return Center(child: Text(lugaresController.erro));
          }
          if(lugaresController.lugares.isEmpty) {
            return Center(child: Text("Nenhum lugar encontrado!"));
          }

          return ListView.builder(
            itemCount: lugaresController.lugares.length,
            itemBuilder: (context, index) {
              final lugar = lugaresController.lugares[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                elevation: 4,
                child: ListTile(
                  onTap: () => mostrarDetalhesLugar(context, lugar),
                  title: Text(lugar.nome),
                  // a distância aparece quando o GPS responde
                  subtitle: Consumer<LocalizacaoController>(
                    builder: (context, localizacao, child) {
                      final distancia = localizacao.distanciaAte(
                          lugar.latitude, lugar.longitude);
                      return Text(
                        '${lugar.categoria ?? 'Sem categoria'} $distancia',
                      );
                    },
                  ),
                  leading: CircleAvatar(child: Icon(Icons.place)),
                  // coração cheio = favorito
                  trailing: Consumer<FavoritosController>(
                    builder: (context, favoritos, child) => IconButton(
                      onPressed: () => favoritos.alternar(lugar.id),
                      icon: Icon(
                        favoritos.ehFavorito(lugar.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              );
            } ,
          );
        },
      ),
      // botão + que abre a tela de cadastro
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, 'cadastro'),
        child: Icon(Icons.add),
      ),
    );
  }
}