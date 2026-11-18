class LugaresModel {
  final int id;
  final String nome;
  final String? categoria;
  // a API tem lugares sem coordenadas, por isso podem ser null
  final double? latitude;
  final double? longitude;
  final String descricao;
  final int categoriaId;
  // endereços das fotos (vêm da galeria da API)
  final List<String> fotos;

  LugaresModel({
    required this.id,
    required this.nome,
    this.categoria,
    this.latitude,
    this.longitude,
    required this.categoriaId,
    this.descricao = '',
    this.fotos = const [],
  });

  // JSON da API -> objeto
  factory LugaresModel.fromJson(Map<String, dynamic> json) {
    return LugaresModel(
      id: json['id'],
      nome: json['nome'],
      // o ? evita erro se a categoria vier vazia
      categoria: json['categoria']?['nome'],
      categoriaId: json['categoriaId'],
      // as num? + ?.toDouble porque a API pode mandar número inteiro (ex: 10)
      // ou null
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      descricao: json['descricao'] ?? '',
      // a API manda "galeria": [{"urlFoto": "..."}, ...]. o ?? [] vira lista
      // vazia se não vier galeria. o map pega só o urlFoto de cada item
      fotos: (json['galeria'] as List? ?? [])
          .map((foto) => foto['urlFoto'].toString())
          .toList(),
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
