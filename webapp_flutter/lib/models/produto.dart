class Produto {
  final int? id;
  final String descricao;
  final double custo;
  final String? imagem;
  final List<double>? precoVenda;

  Produto? value;

  Produto({
    this.id,
    required this.descricao,
    required this.custo,
    this.imagem,
    this.precoVenda,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      descricao: json['descricao'],
      custo: json['custo'],
      imagem: json['imagem'],
      precoVenda: json['preco_venda'] != null
          ? List<double>.from(
              json['preco_venda'].map((value) => value as double))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'custo': custo,
      'imagem': imagem,
      'preco_venda': precoVenda,
    };
  }
}
