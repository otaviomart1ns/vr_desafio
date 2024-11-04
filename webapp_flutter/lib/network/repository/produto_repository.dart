import 'dart:convert';
import 'dart:io';
import 'package:webapp_flutter/models/produto.dart';
import 'package:http/http.dart' as http;
import 'package:webapp_flutter/models/produto_loja.dart';
import 'package:webapp_flutter/network/services/api_service.dart';

class ProdutoRepository {
  // Obtém uma lista de produtos com filtros opcionais
  static Future<List<Produto>> getProdutos({
    String? id,
    String? descricao,
    String? custo,
    String? precoVenda,
  }) async {
    try {
      http.Response response = await ApiService.getProdutos(
        id: id,
        descricao: descricao,
        custo: custo,
        precoVenda: precoVenda,
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Produto.fromJson(json)).toList();
      } else {
        throw HttpException(
            'Falha ao carregar produtos: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtém um produto específico pelo ID
  static Future<Produto?> getProduto(int id) async {
    try {
      http.Response response = await ApiService.getProduto(id);
      if (response.statusCode == 200) {
        final Map<String, dynamic> produto = json.decode(response.body);
        return Produto.fromJson(produto);
      } else {
        throw HttpException(
            'Falha ao carregar produto com id $id: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Cria um novo produto
  static Future<int> createProduto(Produto produto) async {
    try {
      http.Response response = await ApiService.createProduto(produto);
      if (response.statusCode != 201) {
        throw HttpException('Falha ao criar produto: ${response.reasonPhrase}');
      }
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody['id'] as int;
    } catch (e) {
      rethrow;
    }
  }

  // Atualiza um produto existente
  static Future<void> updateProduto(Produto produto) async {
    try {
      http.Response response = await ApiService.updateProduto(produto);
      if (response.statusCode != 200) {
        throw HttpException(
            'Falha ao atualizar produto: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Deleta um produto pelo ID
  static Future<void> deleteProduto(int id) async {
    try {
      http.Response response = await ApiService.deleteProduto(id);
      if (response.statusCode != 204) {
        throw HttpException(
            'Falha ao deletar produto com id $id: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Adiciona o preço de venda de um produto em uma loja específica
  static Future<void> addProdutoLoja(
      int produtoId, int lojaId, double precoVenda) async {
    try {
      http.Response response =
          await ApiService.addPrecoProdutoLoja(produtoId, lojaId, precoVenda);
      if (response.statusCode != 201) {
        throw HttpException(
            'Falha ao associar produto ao preço de venda na loja: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtém todos os preços de venda de um produto nas lojas
  static Future<List<ProdutoLoja>> getPrecosProduto(int produtoId) async {
    try {
      http.Response response = await ApiService.getPrecosProdutoLoja(produtoId);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ProdutoLoja.fromJson(json)).toList();
      } else {
        throw HttpException(
            'Falha ao obter preços do produto com id $produtoId: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Atualiza o preço de venda de um produto em uma loja específica
  static Future<void> updatePrecoProdutoLoja(
      int produtoId, int precoLojaId, double novoPreco) async {
    try {
      http.Response response = await ApiService.updatePrecoProdutoLoja(
          produtoId, precoLojaId, novoPreco);
      if (response.statusCode != 200) {
        throw HttpException(
            'Falha ao atualizar o preço de venda: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Remove a associação de um preço de venda de um produto em uma loja específica
  static Future<void> deletePrecoProdutoLoja(int produtoId, int lojaId) async {
    try {
      http.Response response =
          await ApiService.deletePrecoProdutoLoja(produtoId, lojaId);
      if (response.statusCode != 200) {
        throw HttpException(
            'Falha ao remover associação do produto com id $produtoId da loja $lojaId: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
