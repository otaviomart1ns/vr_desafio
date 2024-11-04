import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:webapp_flutter/models/produto.dart';
import 'package:webapp_flutter/network/repository/produto_repository.dart';

class ConsultaProdutoController extends GetxController {
  TextEditingController codigo = TextEditingController();
  TextEditingController descricao = TextEditingController();
  TextEditingController custo = TextEditingController();
  TextEditingController precoVenda = TextEditingController();

  List<Produto> allProdutos = [];
  RxList<Produto> filteredProdutos = RxList();

  Future<void> getProdutos() async {
    String custoValue = custo.text.replaceAll(',', '.');
    String precoVendaValue = precoVenda.text.replaceAll(',', '.');

    filteredProdutos.value = await ProdutoRepository.getProdutos(
        id: codigo.text,
        descricao: descricao.text,
        custo: custoValue,
        precoVenda: precoVendaValue);
  }

  Future<void> deleteProduto(int id) async {
    await ProdutoRepository.deleteProduto(id);
    await getProdutos();
  }
}
