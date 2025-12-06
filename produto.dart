class Produto {
  final int? id;
  final String nome;
  final String descricao;
  final double preco;
  final DateTime dataAtualizado;

  Produto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.dataAtualizado,
  });
}
