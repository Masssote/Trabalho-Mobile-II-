import '../dao/client_dao_impl.dart';
import '../models/cliente.dart';

class ClientService {
  final _dao = ClientDAOMySQL();

  Future<void> salvar(Cliente cliente) async {
    _validarNomeSobrenome(cliente.nome);
    _validarNomeSobrenome(cliente.sobrenome);
    _validarEmail(cliente.email);
    await _dao.salvar(cliente);
  }

  Future<Map<String, Cliente>> remover(dynamic id) async {
    return await _dao.remover(id);
  }

  Future<Map<String, Cliente>> encontrar() async {
    return await _dao.encontrar();
  }

  void _validarNomeSobrenome(String nome) {
    const int min = 3;
    const int max = 50;

    if (nome.isEmpty) {
      throw Exception('O nome é obrigatório.');
    } else if (nome.length < min) {
      throw Exception('O nome deve possuir pelo menos $min caracteres.');
    } else if (nome.length > max) {
      throw Exception('O nome deve possuir no máximo $max caracteres.');
    }
  }

  void _validarEmail(String email) {
    if (email.isEmpty) {
      throw Exception('O e-mail é obrigatório.');
    } else if (!email.contains('@')) {
      throw Exception('O e-mail deve possuir @.');
    }
  }
}
