import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto.dart';
import 'product_dao.dart';

class ProductDAOMySQL implements ProductDAO {
  static const String _baseUrl = 'http://localhost:3000'; // ajuste porta se preciso

  @override
  Future<List<Produto>> encontrar() async {
    final uri = Uri.parse('$_baseUrl/produtos');
    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Erro REST API ao listar produtos');
    }

    final Iterable lista = json.decode(resposta.body);
    return lista.map((item) {
      return Produto(
        id: item['id'],
        nome: item['nome'],
        descricao: item['descricao'],
        preco: (item['preco'] as num).toDouble(),
        dataAtualizado: DateTime.parse(item['data_atualizado']),
      );
    }).toList();
  }

  @override
  Future<void> remover(int id) async {
    final uri = Uri.parse('$_baseUrl/produtos/$id');
    final resposta = await http.delete(uri);
    if (resposta.statusCode != 200) {
      throw Exception('Erro REST API ao remover produto');
    }
  }

  @override
  Future<void> salvar(Produto produto) async {
    final uri = Uri.parse('$_baseUrl/produtos');
    final body = jsonEncode({
      'id': produto.id,
      'nome': produto.nome,
      'descricao': produto.descricao,
      'preco': produto.preco,
      'data_atualizado': produto.dataAtualizado.toIso8601String(),
    });

    if (produto.id == null) {
      final response = await http.post(
        uri,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Erro REST API ao criar produto');
      }
    } else {
      final response = await http.put(
        uri,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Erro REST API ao atualizar produto');
      }
    }
  }
}
