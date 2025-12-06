class Cliente {
  final int? id;
  final String nome;
  final String sobrenome;
  final String email;
  final int idade;
  final String? foto;

  Cliente({
    this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    required this.idade,
    this.foto,
  });
}
