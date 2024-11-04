import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // Import para o GetX
import 'package:webapp_flutter/models/loja.dart';
import 'package:webapp_flutter/ui/screens/cadastro/cadastro_produto_controller.dart';

class PriceAdjustmentDialog {
  static void showPriceAdjustmentDialog(
      {required BuildContext context,
      String? precoLoja,
      Loja? loja,
      int? precoLojaId,
      required CadastroProdutoController cadastroProdutoController}) {
    TextEditingController priceController = TextEditingController(
      text: precoLoja != null
          ? cadastroProdutoController.formatarValorParaReal(
              double.parse(precoLoja),
            )
          : '',
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      var id = cadastroProdutoController.codigoController.text;

                      if (id.isEmpty) {
                        Get.snackbar(
                          'Atenção',
                          'Produto não está associado. Por favor, associe um produto antes de salvar.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orangeAccent,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                      } else if (cadastroProdutoController.selectedLoja !=
                              null &&
                          priceController.text.isNotEmpty) {
                        double precoVenda = cadastroProdutoController
                            .converterValorParaSalvar(priceController.text);

                        await cadastroProdutoController.salvarPrecoProdutoLoja(
                          produtoId: int.parse(id),
                          loja: loja ?? cadastroProdutoController.selectedLoja!,
                          precoVenda: precoVenda,
                          precoLojaId: precoLojaId,
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const Text(
                    'Alteração/Inclusão de Preço',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 56),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: loja != null,
                        child: DropdownButtonFormField<Loja>(
                          value: cadastroProdutoController.selectedLoja !=
                                      null &&
                                  cadastroProdutoController.lojas.any((loja) =>
                                      loja.id ==
                                      cadastroProdutoController
                                          .selectedLoja?.id)
                              ? cadastroProdutoController.selectedLoja
                              : null,
                          hint: const Text('Loja*'),
                          items:
                              cadastroProdutoController.lojas.map((Loja loja) {
                            return DropdownMenuItem<Loja>(
                              value: loja,
                              child: Text(loja.descricao),
                            );
                          }).toList(),
                          onChanged: (Loja? newValue) {
                            cadastroProdutoController.selectedLoja = newValue;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[\.,]?\d{0,2}'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Preço de Venda (R\$)*',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 10),
                        ),
                        onTap: () {
                          priceController.text =
                              priceController.text.replaceAll('.', ',');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
