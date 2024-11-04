import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webapp_flutter/models/loja.dart';
import 'package:webapp_flutter/models/produto.dart';
import 'package:webapp_flutter/models/produto_loja.dart';
import 'package:webapp_flutter/network/repository/loja_repository.dart';
import 'package:webapp_flutter/network/repository/produto_repository.dart';

class CadastroProdutoController extends GetxController {
  TextEditingController codigoController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  TextEditingController custoController = TextEditingController();
  RxList<Map<String, dynamic>> precosVendaController = RxList();
  RxString? imagemBase64 = ''.obs;
  RxList<Loja> lojas = RxList();
  RxList<ProdutoLoja> produtoLojaList = RxList();
  Loja? selectedLoja;
  Produto? produto;

  Future<void> infoProdutoLoja(int produtoId) async {
    try {
      produtoLojaList.value =
          await ProdutoRepository.getPrecosProduto(produtoId);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar preços: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> infoProduto(int produtoId) async {
    try {
      produto = await ProdutoRepository.getProduto(produtoId);
      codigoController.text = produto!.id.toString();
      descricaoController.text = produto!.descricao;
      custoController.text = formatarValorParaReal(produto!.custo);
      imagemBase64?.value = produto!.imagem ?? '';
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar produto: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<int?> saveProduto() async {
    try {
      if (codigoController.text.isNotEmpty &&
          int.tryParse(codigoController.text) != null) {
        // Atualiza o produto se o código já existir
        Produto produtoAtualizado = Produto(
          id: int.parse(codigoController.text),
          descricao: descricaoController.text,
          custo: converterValorParaSalvar(custoController.text),
          imagem: imagemBase64?.value ?? '',
          precoVenda: precosVendaController
              .map((preco) => preco['preco'] as double)
              .toList(),
        );

        await ProdutoRepository.updateProduto(produtoAtualizado);

        Get.snackbar(
          'Sucesso',
          'Produto atualizado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return produtoAtualizado.id;
      } else {
        Produto novoProduto = Produto(
          descricao: descricaoController.text,
          custo: converterValorParaSalvar(custoController.text),
          imagem: imagemBase64?.value ?? '',
        );

        int produtoId = await ProdutoRepository.createProduto(novoProduto);
        codigoController.text = produtoId.toString();

        Get.snackbar(
          'Sucesso',
          'Produto criado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return produtoId;
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao salvar o produto: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> deleteProduto() async {
    try {
      await ProdutoRepository.deleteProduto(produto!.id!);
      Get.snackbar(
        'Sucesso',
        'Produto excluído com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offNamed('/produto');
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao excluir o produto: $e',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<int?> createProduto() async {
    try {
      Produto novoProduto = Produto(
        descricao: descricaoController.text,
        custo: double.tryParse(custoController.text) ?? 0.00,
        imagem: imagemBase64!.value,
      );
      int idProduto = await ProdutoRepository.createProduto(novoProduto);

      Get.snackbar(
        'Sucesso',
        'Produto criado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return idProduto;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Falha ao criar o produto: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return null;
    }
  }

  Future<void> uploadImagem() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        imagemBase64!.value = base64Encode(bytes);
        update();
      } else {
        Get.snackbar(
          "Upload Cancelado",
          "Nenhuma imagem foi selecionada.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Ocorreu um erro ao fazer o upload da imagem.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getLojas() async {
    try {
      lojas.value = await LojaRepository.getLojas();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar lojas: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> salvarPrecoProdutoLoja({
    required int produtoId,
    required Loja loja,
    double precoVenda = 0.0,
    int? precoLojaId,
  }) async {
    try {
      if (precoLojaId != null) {
        await ProdutoRepository.updatePrecoProdutoLoja(
            produtoId, precoLojaId, precoVenda);
      } else {
        await ProdutoRepository.addProdutoLoja(produtoId, loja.id, precoVenda);
      }
      await infoProdutoLoja(produtoId);
      Get.snackbar(
        'Sucesso',
        precoLojaId != null
            ? 'Preço de venda atualizado com sucesso!'
            : 'Preço de venda criado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar preço de venda: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deletePrecoProdutoLoja(int produtoId, int precoLojaId) async {
    try {
      await ProdutoRepository.deletePrecoProdutoLoja(produtoId, precoLojaId);
      Get.snackbar(
        'Sucesso',
        'Preço de venda removido com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await infoProdutoLoja(produtoId);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao remover o preço de venda: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  clearFlow() {
    codigoController.clear();
    descricaoController.clear();
    custoController.clear();
    precosVendaController = RxList();
    imagemBase64!.value = '';
    lojas = RxList();
    produtoLojaList = RxList();
  }

  clearSelectedLoja() {
    selectedLoja = null;
  }

  String formatarValorParaReal(double valor) {
    NumberFormat formatoReal = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatoReal.format(valor).trim();
  }

  double converterValorParaSalvar(String valorComVirgula) {
    if (valorComVirgula.contains(',')) {
      valorComVirgula =
          valorComVirgula.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(valorComVirgula) ?? 0.0;
  }
}
