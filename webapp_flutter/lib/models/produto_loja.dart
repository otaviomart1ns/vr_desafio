class ProdutoLoja {
  final int idPreco;
  final int idProduto;
  final String descricaoProduto;
  final int idLoja;
  final String descricaoLoja;
  final double precoVenda;

  ProdutoLoja({
    required this.idPreco,
    required this.idProduto,
    required this.descricaoProduto,
    required this.idLoja,
    required this.descricaoLoja,
    required this.precoVenda,
  });

  factory ProdutoLoja.fromJson(Map<String, dynamic> json) {
    return ProdutoLoja(
      idPreco: json['id'],
      idProduto: json['id_produto'],
      descricaoProduto: json['descricao_produto'],
      idLoja: json['id_loja'],
      descricaoLoja: json['descricao_loja'],
      precoVenda: json['preco_venda'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_loja': idLoja,
      'preco_venda': precoVenda,
    };
  }
}
