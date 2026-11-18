import 'package:flutter/material.dart';
import 'package:guia/controllers/favoritos_controller.dart';
import 'package:guia/controllers/localizacao_controller.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/services/rota_service.dart';
import 'package:guia/widgets/foto_lugar.dart';
import 'package:provider/provider.dart';

// abre uma janela com os dados do lugar (usado na lista e no mapa).
// showDialog mostra a janelinha por cima da tela. é uma função fora da classe
// pra poder chamar de qualquer tela com a mesma linha
void mostrarDetalhesLugar(BuildContext context, LugaresModel lugar) {
  showDialog(
    context: context,
    builder: (context) => LugarDetalhes(lugar: lugar),
  );
}

class LugarDetalhes extends StatelessWidget {
  final LugaresModel lugar;

  const LugarDetalhes({super.key, required this.lugar});

  Future<void> comoChegar(BuildContext context) async {
    try {
      final abriu = await RotaService().abrirRota(
        lugar.latitude!,
        lugar.longitude!,
      );
      // context.mounted confere se a janela ainda existe depois do await
      if (!abriu && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível abrir o mapa!")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível abrir o mapa!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // os dois podem vir null da API. o botão "Como chegar" só aparece se tiver
    // os dois (o ! lá em cima só é usado depois dessa conferência)
    final temLocal = lugar.latitude != null && lugar.longitude != null;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(lugar.nome)),
          // o Consumer refaz só o coração quando o favorito muda
          Consumer<FavoritosController>(
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
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FotoLugar(fotos: lugar.fotos),
            SizedBox(height: 12),
            Text(lugar.categoria ?? 'Sem categoria'),
            Consumer<LocalizacaoController>(
              builder: (context, localizacao, child) {
                final distancia =
                    localizacao.distanciaAte(lugar.latitude, lugar.longitude);
                if (distancia == '') {
                  return SizedBox();
                }
                return Text("Distância: $distancia");
              },
            ),
            SizedBox(height: 8),
            Text(lugar.descricao),
            SizedBox(height: 12),
            if (temLocal)
              ElevatedButton.icon(
                onPressed: () => comoChegar(context),
                icon: Icon(Icons.directions),
                label: Text("Como chegar"),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Fechar"),
        ),
      ],
    );
  }
}
