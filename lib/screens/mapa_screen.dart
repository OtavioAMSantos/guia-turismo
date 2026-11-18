import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia/controllers/categorias_controller.dart';
import 'package:guia/controllers/localizacao_controller.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:guia/widgets/lugar_detalhes.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // id da categoria usada no filtro (null = mostra todas)
  int? categoriaFiltro;

  @override
  void initState() {
    super.initState();
    // pega a localização do usuário quando a tela abre
    context.read<LocalizacaoController>().buscarPosicao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa dos lugares")),
      body: Consumer<LocalizacaoController>(
        builder: (context, localizacao, child) {
          // espera o GPS responder pra abrir o mapa já onde o usuário está.
          // o mapa só usa o centro inicial na hora que é criado, por isso
          // não dá pra abrir antes e centralizar depois
          if (localizacao.carregando) {
            return Center(child: CircularProgressIndicator());
          }
          return Consumer<LugaresController>(
            builder: (context, lugaresController, child) {
              // monta a lista do que vai pro mapa. o continue pula o lugar sem
              // coordenada (a API tem lugar assim). categoriaFiltro null
              // significa "todas", aí entra qualquer categoria
              List<LugaresModel> lugares = [];
              for (final lugar in lugaresController.lugares) {
                if (lugar.latitude == null || lugar.longitude == null) {
                  continue;
                }
                if (categoriaFiltro == null ||
                    lugar.categoriaId == categoriaFiltro) {
                  lugares.add(lugar);
                }
              }

              // escolhe onde o mapa abre, por ordem: no usuário, no primeiro
              // lugar ou em São Paulo. o ! diz pro Dart "pode confiar, não é
              // null" (a gente acabou de conferir no if)
              LatLng centro = LatLng(-23.5505, -46.6333);
              if (localizacao.posicao != null) {
                centro = localizacao.posicao!;
              } else if (lugares.isNotEmpty) {
                centro = LatLng(lugares[0].latitude!, lugares[0].longitude!);
              }

              return Column(
                children: [
                  // filtro por categoria (dropdown igual ao do cadastro)
                  Consumer<CategoriasController>(
                    builder: (context, categoriasController, child) {
                      // primeira opção = sem filtro (value null), depois
                      // uma opção por categoria que veio da API.
                      // o int? é um int que aceita null
                      List<DropdownMenuItem<int?>> opcoes = [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text("Todas as categorias"),
                        ),
                      ];
                      for (final categoria in categoriasController.categorias) {
                        opcoes.add(
                          DropdownMenuItem<int?>(
                            value: categoria.id,
                            child: Text(categoria.nome),
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          hint: Text("Todas as categorias"),
                          value: categoriaFiltro,
                          items: opcoes,
                          // setState refaz a tela, aí o for lá de cima roda
                          // de novo com o filtro novo
                          onChanged: (valor) {
                            setState(() {
                              categoriaFiltro = valor;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  if (localizacao.erro != '')
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(localizacao.erro),
                    ),
                  Expanded(
                    child: FlutterMap(
                      options:
                          MapOptions(initialCenter: centro, initialZoom: 13),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.guia',
                        ),
                        // um pin com a foto pra cada lugar. o Container faz o
                        // círculo com borda vermelha e o ClipOval recorta a
                        // foto em círculo. se não tiver foto (ou der erro ao
                        // carregar) mostra o ícone de pin no lugar
                        MarkerLayer(
                          markers: lugares.map((lugar) {
                            return Marker(
                              point: LatLng(lugar.latitude!, lugar.longitude!),
                              width: 50,
                              height: 50,
                              child: GestureDetector(
                                onTap: () =>
                                    mostrarDetalhesLugar(context, lugar),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.red, width: 3),
                                  ),
                                  child: ClipOval(
                                    child: lugar.fotos.isEmpty
                                        ? Icon(Icons.place, color: Colors.red)
                                        : Image.network(
                                            lugar.fotos[0],
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Icon(
                                                Icons.place,
                                                color: Colors.red),
                                          ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        // ícone azul = onde o usuário está. o if dentro da
                        // lista só adiciona a camada se tiver posição
                        if (localizacao.posicao != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: localizacao.posicao!,
                                width: 30,
                                height: 30,
                                child:
                                    Icon(Icons.my_location, color: Colors.blue),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
