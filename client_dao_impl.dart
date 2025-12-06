import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente.dart';
import 'client_dao.dart';

class ClientDAOMySQL implements ClientDAO {
  static const String _baseUrl = 'http://localhost:3000';

  @override
  Future<Map<String, Cliente>> encontrar() async {
    final uri = Uri.parse('$_baseUrl/clientes');
    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Erro REST API ao listar clientes');
    }

    final Iterable lista = json.decode(resposta.body);
    final Map<String, Cliente> map = {};

    for (var item in lista) {
      map[item['id'].toString()] = Cliente(
        id: item['id'],
        nome: item['nome'],
        sobrenome: item['sobrenome'],
        email: item['email'],
        idade: 0, // se o backend ainda não tiver idade
        foto: item['avatarUrl'],
      );
    }

    return map;
  }

  @override
  Future<Map<String, Cliente>> remover(dynamic id) async {
    final uri = Uri.parse('$_baseUrl/clientes/$id');
    final resposta = await http.delete(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Erro REST API ao remover cliente');
    }

    return encontrar();
  }

  @override
  Future<void> salvar(Cliente cliente) async {
    final uri = Uri.parse('$_baseUrl/clientes');
    final body = jsonEncode({
      'id': cliente.id,
      'nome': cliente.nome,
      'sobrenome': cliente.sobrenome,
      'email': cliente.email,
      'avatarUrl': cliente.foto,
    });

    if (cliente.id == null) {
      final response = await http.post(
        uri,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Erro REST API ao criar cliente');
      }
    } else {
      final response = await http.put(
        uri,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Erro REST API ao atualizar cliente');
      }
    }
  }
}
