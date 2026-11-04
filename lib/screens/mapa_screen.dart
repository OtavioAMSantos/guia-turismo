import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia/controllers/lugares_controller.dart';
import 'package:guia/models/lugares_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  void mostrarLugar(LugaresModel lugar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lugar.nome),
        content: Text(
          "${lugar.categoria ?? 'Sem categoria'}\n\n${lugar.descricao}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fechar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa dos lugares")),
      body: Consumer<LugaresController>(
        builder: (context, lugaresController, child) {
          final lugares = lugaresController.lugares;
          // se não tiver lugar, abre o mapa em São Paulo
          final centro = lugares.isEmpty
              ? LatLng(-23.5505, -46.6333)
              : LatLng(lugares[0].latitude, lugares[0].longitude);

          return FlutterMap(
            options: MapOptions(initialCenter: centro, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.guia',
              ),
              // um pin pra cada lugar da lista
              MarkerLayer(
                markers: lugares.map((lugar) {
                  return Marker(
                    point: LatLng(lugar.latitude, lugar.longitude),
                    width: 40,
                    height: 40,
                    // topCenter deixa a ponta do pin em cima da coordenada
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => mostrarLugar(lugar),
                      child: Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
