import 'dart:convert';
import 'dart:io';
import 'package:webapp_flutter/models/loja.dart';
import 'package:http/http.dart' as http;
import 'package:webapp_flutter/network/services/api_service.dart';

class LojaRepository {
  // Obtém todas as lojas disponíveis
  static Future<List<Loja>> getLojas() async {
    try {
      http.Response response = await ApiService.getLojas();
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map(
              (json) => Loja.fromJson(json),
            )
            .toList();
      } else {
        throw HttpException(
            'Falha ao carregar lojas: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtém uma loja específica pelo ID
  static Future<Loja?> getLoja(int id) async {
    try {
      http.Response response = await ApiService.getLoja(id);
      if (response.statusCode == 200) {
        final Map<String, dynamic> loja = json.decode(response.body);
        return Loja.fromJson(loja);
      } else {
        throw HttpException(
            'Falha ao carregar loja com id $id: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Cria uma nova loja
  static Future<void> createLoja(Loja loja) async {
    try {
      http.Response response = await ApiService.createLoja(loja);
      if (response.statusCode != 201) {
        throw HttpException('Falha ao criar loja: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Atualiza uma loja existente
  static Future<void> updateLoja(Loja loja) async {
    try {
      http.Response response = await ApiService.updateLoja(loja);
      if (response.statusCode != 200) {
        throw HttpException(
            'Falha ao atualizar loja: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Deleta uma loja pelo ID
  static Future<void> deleteLoja(int id) async {
    try {
      http.Response response = await ApiService.deleteLoja(id);
      if (response.statusCode != 204) {
        throw HttpException(
            'Falha ao deletar loja com id $id: ${response.reasonPhrase}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
