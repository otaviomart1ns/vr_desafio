class Loja {
  final int id;
  final String descricao;

  Loja({
    required this.id,
    required this.descricao,
  });

  factory Loja.fromJson(Map<String, dynamic> json) {
    return Loja(
      id: json['id'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
    };
  }
}
