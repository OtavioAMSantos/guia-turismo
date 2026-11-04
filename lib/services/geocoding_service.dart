import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  // GET no Nominatim (OpenStreetMap). devolve null se não achar o endereço
  Future<LatLng?> buscar(String texto) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': texto,
        'format': 'json',
        'limit': '1',
        'countrycodes': 'br',
      });
      // o Nominatim pede um User-Agent. no navegador não dá pra mudar esse header
      Map<String, String> headers = {};
      if (!kIsWeb) {
        headers['User-Agent'] = 'GuiaTurismoApp/1.0';
      }
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          return null;
        }
        // lat e lon vêm como texto no JSON
        return LatLng(
          double.parse(data[0]['lat']),
          double.parse(data[0]['lon']),
        );
      } else {
        throw Exception('Erro na requisição: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
