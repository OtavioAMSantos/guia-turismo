class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  final double latitude;
  final double longitude;
  final String descricao;
  final int categoriaId;

  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria,
    required this.latitude,
    required this.longitude,
    required this.categoriaId,
    this.descricao = '',
  });

  // JSON da API -> objeto
  factory LugaresModel.fromJson(Map<String, dynamic> json) {
    return LugaresModel(
      id: json['id'],
      nome: json['nome'],
      // o ? evita erro se a categoria vier vazia
      categoria: json['categoria']?['nome'],
      categoriaId: json['categoriaId'],
      // as num + toDouble porque a API pode mandar número inteiro (ex: 10)
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      descricao: json['descricao'] ?? '',
    );
  }

  // objeto -> JSON, só com os campos que a API pede
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'categoriaId': categoriaId,
    };
  }
}
