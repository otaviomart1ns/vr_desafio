import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webapp_flutter/models/loja.dart';
import 'package:webapp_flutter/models/produto.dart';
import 'package:webapp_flutter/network/api_url.dart';

class ApiService {
  // Método para buscar produtos com filtros opcionais
  static Future<http.Response> getProdutos({
    String? id,
    String? descricao,
    String? custo,
    String? precoVenda,
  }) async {
    String url = ApiUrl.productsUrl;
    Uri uri = Uri.parse(url).replace(queryParameters: {
      if (id != null && id.isNotEmpty) 'id': id,
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
      if (custo != null && custo.isNotEmpty) 'custo': custo,
      if (precoVenda != null && precoVenda.isNotEmpty)
        'preco_venda': precoVenda,
    });

    return await http.get(uri);
  }

  // Método para buscar um único produto por ID
  static Future<http.Response> getProduto(int id) async {
    return await http.get(Uri.parse('${ApiUrl.productsUrl}/$id'));
  }

  // Método para criar um novo produto
  static Future<http.Response> createProduto(Produto produto) async {
    return await http.post(
      Uri.parse(ApiUrl.productsUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(produto.toJson()),
    );
  }

  // Método para atualizar um produto existente
  static Future<http.Response> updateProduto(Produto produto) async {
    return await http.patch(
      Uri.parse('${ApiUrl.productsUrl}/${produto.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(produto.toJson()),
    );
  }

  // Método para deletar um produto por ID
  static Future<http.Response> deleteProduto(int id) async {
    return await http.delete(Uri.parse('${ApiUrl.productsUrl}/$id'));
  }

  // Método para buscar todas as lojas
  static Future<http.Response> getLojas() async {
    return await http.get(Uri.parse(ApiUrl.lojasUrl));
  }

  // Método para buscar uma loja específica por ID
  static Future<http.Response> getLoja(int id) async {
    return await http.get(Uri.parse('${ApiUrl.lojasUrl}/$id'));
  }

  // Método para criar uma nova loja
  static Future<http.Response> createLoja(Loja loja) async {
    return await http.post(
      Uri.parse(ApiUrl.lojasUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(loja.toJson()),
    );
  }

  // Método para atualizar uma loja existente
  static Future<http.Response> updateLoja(Loja loja) async {
    return await http.put(
      Uri.parse('${ApiUrl.lojasUrl}/${loja.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(loja.toJson()),
    );
  }

  // Método para deletar uma loja por ID
  static Future<http.Response> deleteLoja(int id) async {
    return await http.delete(Uri.parse('${ApiUrl.lojasUrl}/$id'));
  }

  // Método para associar um preço de venda a um produto em uma loja específica
  static Future<http.Response> addPrecoProdutoLoja(
      int produtoId, int lojaId, double precoVenda) async {
    return await http.post(
      Uri.parse('${ApiUrl.productsUrl}/$produtoId/precos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'id_loja': lojaId, 'preco_venda': precoVenda}),
    );
  }

  // Método para buscar todos os preços de venda de um produto em diferentes lojas
  static Future<http.Response> getPrecosProdutoLoja(int produtoId) async {
    return await http.get(Uri.parse('${ApiUrl.productsUrl}/$produtoId/precos'));
  }

  // Método para atualizar o preço de venda de um produto em uma loja específica
  static Future<http.Response> updatePrecoProdutoLoja(
      int produtoId, int precoId, double novoPreco) async {
    return await http.patch(
      Uri.parse('${ApiUrl.productsUrl}/$produtoId/precos/$precoId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'preco_venda': novoPreco}),
    );
  }

  // Método para remover a associação de um preço de venda de um produto em uma loja
  static Future<http.Response> deletePrecoProdutoLoja(
      int produtoId, int precoId) async {
    return await http.delete(
      Uri.parse('${ApiUrl.productsUrl}/$produtoId/precos/$precoId'),
    );
  }
}
