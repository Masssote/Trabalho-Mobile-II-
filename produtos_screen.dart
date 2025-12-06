import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/product_service.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final ProductService _service = ProductService();

  List<Produto> _produtos = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await _service.encontrar();
      setState(() {
        _produtos = lista;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  void _abrirFormulario({Produto? produto}) async {
    final nomeController =
        TextEditingController(text: produto?.nome ?? '');
    final descricaoController =
        TextEditingController(text: produto?.descricao ?? '');
    final precoController = TextEditingController(
      text: produto?.preco != null ? produto!.preco.toString() : '',
    );

    final resultado = await showDialog<Produto>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(produto == null ? 'Novo produto' : 'Editar produto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                TextField(
                  controller: precoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Preço'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final preco =
                    double.tryParse(precoController.text.replaceAll(',', '.')) ??
                        0.0;

                final novo = Produto(
                  id: produto?.id,
                  nome: nomeController.text,
                  descricao: descricaoController.text,
                  preco: preco,
                  dataAtualizado: DateTime.now(),
                );

                Navigator.of(context).pop(novo);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (resultado == null) return;

    try {
      if (produto == null) {
        await _service.salvar(resultado);
      } else {
        await _service.salvar(
          Produto(
            id: produto.id,
            nome: resultado.nome,
            descricao: resultado.descricao,
            preco: resultado.preco,
            dataAtualizado: resultado.dataAtualizado,
          ),
        );
      }
      await _carregarProdutos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar produto: $e')),
      );
    }
  }

  Future<void> _removerProduto(Produto produto) async {
    try {
      await _service.remover(produto.id!);
      await _carregarProdutos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover produto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: Builder(
        builder: (context) {
          if (_carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_erro != null) {
            return Center(child: Text('Erro: $_erro'));
          }
          if (_produtos.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado'));
          }
          return RefreshIndicator(
            onRefresh: _carregarProdutos,
            child: ListView.builder(
              itemCount: _produtos.length,
              itemBuilder: (context, index) {
                final p = _produtos[index];
                return ListTile(
                  title: Text(p.nome),
                  subtitle: Text(
                    '${p.descricao}\nPreço: R\$ ${p.preco.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  onTap: () => _abrirFormulario(produto: p),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removerProduto(p),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
