import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webapp_flutter/ui/screens/cadastro/cadastro_produto_controller.dart';
import 'package:webapp_flutter/utils/alert_dialog.dart';

class CadastroProdutoScreen extends StatelessWidget {
  final CadastroProdutoController cadastroController = Get.put(
    CadastroProdutoController(),
  );
  CadastroProdutoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Cadastro de Produto'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.offNamed('/produto'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await cadastroController.saveProduto();
              var id = int.parse(cadastroController.codigoController.text);
              await cadastroController.infoProdutoLoja(id);
              await cadastroController.infoProduto(id);
            },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () async {
              _confirmDelete(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 170.0,
                  child: TextFormField(
                    controller: cadastroController.codigoController,
                    decoration: const InputDecoration(
                      labelText: "Código",
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ).marginOnly(right: 10),
                SizedBox(
                  width: 470.0,
                  child: TextFormField(
                    controller: cadastroController.descricaoController,
                    decoration: const InputDecoration(
                      labelText: "Descrição*",
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 60,
                  ),
                ).marginOnly(right: 10),
                SizedBox(
                  width: 170.0,
                  child: TextFormField(
                    controller: cadastroController.custoController,
                    decoration: const InputDecoration(
                      labelText: "Custo",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+[\,.]?\d{0,2}'),
                      ),
                    ],
                    onChanged: (value) {},
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(
                    () => _buildTabelaPrecos(context, cadastroController),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      width: 300.0,
                      height: 300.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Colors.orange.shade50,
                      ),
                      child: Obx(
                        () => cadastroController.imagemBase64!.value.isNotEmpty
                            ? Image.memory(
                                base64Decode(
                                    cadastroController.imagemBase64!.value),
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: Text(
                                  "Sem imagem",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        onPressed: () {
                          cadastroController.uploadImagem();
                        },
                        child: const Text("Upload Imagem"),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabelaPrecos(
      BuildContext context, CadastroProdutoController cadastroController) {
    return DataTable(
      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      columnSpacing: 30,
      border: TableBorder.all(
        color: Colors.black,
        width: 1,
        style: BorderStyle.solid,
      ),
      columns: [
        DataColumn(
          label: Row(
            children: [
              IconButton(
                onPressed: () async {
                  cadastroController.clearSelectedLoja();
                  await cadastroController.getLojas();
                  if (context.mounted) {
                    PriceAdjustmentDialog.showPriceAdjustmentDialog(
                      context: context,
                      cadastroProdutoController: cadastroController,
                    );
                  }
                },
                icon: const Icon(Icons.add_circle),
                iconSize: 20,
              ),
              const Center(
                child: Text('Loja'),
              ),
            ],
          ),
        ),
        const DataColumn(
          label: Center(
            child: Text('Preço de Venda (R\$)'),
          ),
        ),
        const DataColumn(
          label: Center(
            child: Text('Ações'),
          ),
        ),
      ],
      rows: cadastroController.produtoLojaList.map((preco) {
        return DataRow(
          cells: [
            DataCell(
              Center(
                child: Text(preco.descricaoLoja),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  cadastroController.formatarValorParaReal(preco.precoVenda),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        cadastroController.selectedLoja =
                            cadastroController.lojas.firstWhere(
                          (loja) => loja.id == preco.idLoja,
                        );
                        if (context.mounted) {
                          PriceAdjustmentDialog.showPriceAdjustmentDialog(
                              context: context,
                              precoLoja: preco.precoVenda.toStringAsFixed(2),
                              loja: cadastroController.selectedLoja,
                              precoLojaId: preco.idPreco,
                              cadastroProdutoController: cadastroController);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await cadastroController.deletePrecoProdutoLoja(
                            preco.idProduto, preco.idPreco);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Excluir Produto"),
          content:
              const Text("Tem certeza de que deseja excluir este produto?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await cadastroController.deleteProduto();
                Get.back();
                Get.snackbar(
                  'Sucesso',
                  'Produto excluído com sucesso.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
  }
}
