import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia/services/geocoding_service.dart';
import 'package:latlong2/latlong.dart';

class SelecionarLocalScreen extends StatefulWidget {
  const SelecionarLocalScreen({super.key});

  @override
  State<SelecionarLocalScreen> createState() => _SelecionarLocalScreenState();
}

class _SelecionarLocalScreenState extends State<SelecionarLocalScreen> {
  final enderecoController = TextEditingController();
  final mapController = MapController();
  // ponto escolhido no mapa (null = ainda não escolheu)
  LatLng? pontoEscolhido;
  bool carregando = false;

  Future<void> buscarEndereco() async {
    if (enderecoController.text.isEmpty) {
      return;
    }
    setState(() {
      carregando = true;
    });
    LatLng? ponto;
    try {
      ponto = await GeocodingService().buscar(enderecoController.text);
    } catch (e) {
      debugPrint("$e");
    }
    if (!mounted) return;
    setState(() {
      carregando = false;
    });
    // ponto fica null se não achou ou se deu erro
    if (ponto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Endereço não encontrado!")),
      );
      return;
    }
    setState(() {
      pontoEscolhido = ponto;
    });
    mapController.move(ponto, 16);
  }

  @override
  void dispose() {
    enderecoController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Escolher local")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: enderecoController,
                    decoration: InputDecoration(labelText: "Endereço ou CEP"),
                  ),
                ),
                if (carregando)
                  CircularProgressIndicator()
                else
                  IconButton(
                    onPressed: buscarEndereco,
                    icon: Icon(Icons.search),
                  ),
              ],
            ),
          ),
          // Expanded pro mapa ocupar o resto da tela
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(-23.5505, -46.6333),
                initialZoom: 13,
                // tocar no mapa também escolhe o ponto
                onTap: (tapPosition, ponto) {
                  setState(() {
                    pontoEscolhido = ponto;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.guia',
                ),
                if (pontoEscolhido != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pontoEscolhido!,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: Icon(Icons.location_on,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            // fica desabilitado (null) até escolher um ponto
            child: ElevatedButton(
              onPressed: pontoEscolhido == null
                  ? null
                  : () => Navigator.pop(context, pontoEscolhido),
              child: Text("Usar este local"),
            ),
          ),
        ],
      ),
    );
  }
}
