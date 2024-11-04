import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webapp_flutter/ui/screens/cadastro/cadastro_produto_screen.dart'
    as cadastro;
import 'package:webapp_flutter/ui/screens/consulta/consulta_produto_screen.dart'
    as consulta;
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gerenciador de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/produto',
      getPages: [
        GetPage(
          name: '/produto',
          page: () => consulta.ConsultaProdutoScreen(),
        ),
        GetPage(
          name: '/produto/cadastro',
          page: () => cadastro.CadastroProdutoScreen(),
        )
      ],
      useInheritedMediaQuery: true,
      navigatorKey: Get.key,
    );
  }
}
