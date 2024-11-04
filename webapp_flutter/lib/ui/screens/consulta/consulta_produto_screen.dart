import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webapp_flutter/models/produto.dart';
import 'package:webapp_flutter/ui/screens/cadastro/cadastro_produto_controller.dart';
import 'consulta_produto_controller.dart';

class ConsultaProdutoScreen extends StatefulWidget {
  const ConsultaProdutoScreen({super.key});

  @override
  State<ConsultaProdutoScreen> createState() => _ConsultaProdutoScreenState();
}

class _ConsultaProdutoScreenState extends State<ConsultaProdutoScreen> {
  CadastroProdutoController cadastroController = Get.put(
    CadastroProdutoController(),
  );
  ConsultaProdutoController consultaController = Get.put(
    ConsultaProdutoController(),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async => await consultaController.getProdutos(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Consulta de Produtos'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            await cadastroController.clearFlow();
            // ignore: use_build_context_synchronously
            Navigator.pushNamed(context, '/produto/cadastro');
          },
          icon: const Icon(Icons.add_circle),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFiltros(),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Obx(() {
                return consultaController.filteredProdutos.isEmpty
                    ? const Center(
                        child: Text('Nenhum produto encontrado.'),
                      )
                    : _buildResponsiveTable(consultaController.filteredProdutos,
                        cadastroController, context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customTextFormField(
          width: 170.0,
          labelText: "Código",
          controller: consultaController.codigo,
          onChanged: (value) => consultaController.getProdutos(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(width: 16.0),
        customTextFormField(
          width: 470.0,
          labelText: "Descrição",
          controller: consultaController.descricao,
          onChanged: (value) => consultaController.getProdutos(),
          keyboardType: TextInputType.text,
          inputFormatters: [],
        ),
        const SizedBox(width: 16.0),
        customTextFormField(
          width: 170.0,
          labelText: "Custo",
          controller: consultaController.custo,
          onChanged: (value) {
            consultaController.getProdutos();
          },
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(
                r'^\d*[\.,]?\d{0,2}$',
              ),
            ),
          ],
        ),
        const SizedBox(width: 16.0),
        customTextFormField(
          width: 170.0,
          labelText: "Preço de Venda",
          controller: consultaController.precoVenda,
          onChanged: (value) => consultaController.getProdutos(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(
                r'^\d*[\.,]?\d{0,2}$',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget customTextFormField({
  required double width,
  required String labelText,
  required TextEditingController controller,
  Function(String)? onChanged,
  bool? readOnly,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? keyboardType,
}) {
  return SizedBox(
    width: width,
    child: TextFormField(
      readOnly: readOnly ?? false,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
    ),
  );
}

Widget _buildResponsiveTable(List<Produto> produtos,
    CadastroProdutoController cadastroController, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    width: double.infinity,
    child: DataTable(
      border: TableBorder.all(
        color: Colors.black,
        width: 1,
        style: BorderStyle.solid,
      ),
      columns: const [
        DataColumn(
          label: Center(
            child: Text(
              'Código',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        DataColumn(
          label: Center(
            child: Text(
              'Descrição',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        DataColumn(
          label: Center(
            child: Text(
              'Custo (R\$)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        DataColumn(
          label: Center(
            child: Text(
              'Ações',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
      rows: produtos.map((produto) {
        return DataRow(
          cells: [
            DataCell(
              Center(
                child: Text(
                  produto.id.toString(),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(produto.descricao),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  cadastroController.formatarValorParaReal(produto.custo),
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      _confirmDelete(context, produto);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () async {
                      await cadastroController.getLojas();
                      await cadastroController.infoProdutoLoja(produto.id!);
                      await cadastroController.infoProduto(produto.id!);
                      Navigator.pushNamed(context, '/produto/cadastro',
                          arguments: produto);
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    ),
  );
}

void _confirmDelete(BuildContext context, Produto produto) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Excluir Produto"),
        content: const Text("Tem certeza de que deseja excluir este produto?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await Get.find<ConsultaProdutoController>()
                    .deleteProduto(produto.id!);
                Get.snackbar(
                  'Sucesso',
                  'Produto excluído com sucesso.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Erro',
                  'Não foi possível excluir o produto: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("Excluir"),
          ),
        ],
      );
    },
  );
}

String _formatNumber(String value) {
  String cleanedValue = value.replaceAll('.', '').replaceAll(',', '.');

  try {
    double number = double.parse(cleanedValue);

    NumberFormat formatter = NumberFormat("#,##0.00", "pt_BR");
    return formatter.format(number);
  } catch (e) {
    return value;
  }
}
