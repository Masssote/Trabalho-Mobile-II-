import '../models/produto.dart';

abstract class ProductDAO {
  Future<List<Produto>> encontrar();
  Future<void> remover(int id);
  Future<void> salvar(Produto produto);
}
