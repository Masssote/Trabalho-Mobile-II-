import '../dao/product_dao_impl.dart';
import '../models/produto.dart';

class ProductService {
  final _dao = ProductDAOMySQL();

  Future<List<Produto>> encontrar() async {
    return await _dao.encontrar();
  }

  Future<void> remover(int id) async {
    await _dao.remover(id);
  }

  Future<void> salvar(Produto produto) async {
    if (produto.nome.isEmpty) {
      throw Exception('Nome do produto é obrigatório.');
    }
    if (produto.preco <= 0) {
      throw Exception('Preço deve ser maior que zero.');
    }
    await _dao.salvar(produto);
  }
}
