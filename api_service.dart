import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente.dart';
import '../models/produto.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // ajuste porta

  // CLIENTES
  static Future<List<Cliente>> getClientes() async {
    final response = await http.get(Uri.parse('$baseUrl/clientes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Cliente(
        id: e['id'],
        nome: e['nome'],
        sobrenome: e['sobrenome'],
        email: e['email'],
        idade: e['idade'],
        foto: e['foto'],
      )).toList();
    } else {
      throw Exception('Erro ao buscar clientes');
    }
  }

  static Future<void> criarCliente(Cliente c) async {
    await http.post(
      Uri.parse('$baseUrl/clientes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': c.nome,
        'sobrenome': c.sobrenome,
        'email': c.email,
        'idade': c.idade,
        'foto': c.foto,
      }),
    );
  }

  static Future<void> atualizarCliente(Cliente c) async {
    await http.put(
      Uri.parse('$baseUrl/clientes/${c.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': c.nome,
        'sobrenome': c.sobrenome,
        'email': c.email,
        'idade': c.idade,
        'foto': c.foto,
      }),
    );
  }

  static Future<void> deletarCliente(int id) async {
    await http.delete(Uri.parse('$baseUrl/clientes/$id'));
  }

  // PRODUTOS – mesma ideia
  static Future<List<Produto>> getProdutos() async {
    final response = await http.get(Uri.parse('$baseUrl/produtos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Produto(
        id: e['id'],
        nome: e['nome'],
        descricao: e['descricao'],
        preco: (e['preco'] as num).toDouble(),
        dataAtualizado: DateTime.parse(e['data_atualizado']),
      )).toList();
    } else {
      throw Exception('Erro ao buscar produtos');
    }
  }

  static Future<void> criarProduto(Produto p) async {
    await http.post(
      Uri.parse('$baseUrl/produtos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': p.nome,
        'descricao': p.descricao,
        'preco': p.preco,
        'data_atualizado': p.dataAtualizado.toIso8601String(),
      }),
    );
  }

  static Future<void> atualizarProduto(Produto p) async {
    await http.put(
      Uri.parse('$baseUrl/produtos/${p.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': p.nome,
        'descricao': p.descricao,
        'preco': p.preco,
        'data_atualizado': p.dataAtualizado.toIso8601String(),
      }),
    );
  }

  static Future<void> deletarProduto(int id) async {
    await http.delete(Uri.parse('$baseUrl/produtos/$id'));
  }
}
