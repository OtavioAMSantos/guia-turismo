class CategoriaModel {
  final int id;
  final String nome;

  CategoriaModel({required this.id, required this.nome});

  // transforma o JSON que vem da API em um objeto CategoriaModel
  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'],
      nome: json['nome'],
    );
  }
}
