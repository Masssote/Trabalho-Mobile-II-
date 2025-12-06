import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/client_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClientService _service = ClientService();

  List<Cliente> _clientes = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final map = await _service.encontrar();
      setState(() {
        _clientes = map.values.toList();
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  void _abrirFormulario({Cliente? cliente}) async {
    final resultado = await showDialog<Cliente>(
      context: context,
      builder: (context) {
        return _ClienteFormDialog(cliente: cliente);
      },
    );

    if (resultado == null) return;

    try {
      if (cliente == null) {
        // novo cliente
        await _service.salvar(resultado);
      } else {
        // atualizar mantendo o id original
        await _service.salvar(
          Cliente(
            id: cliente.id,
            nome: resultado.nome,
            sobrenome: resultado.sobrenome,
            email: resultado.email,
            idade: resultado.idade,
            foto: resultado.foto,
          ),
        );
      }

      final map = await _service.encontrar();
      setState(() {
        _clientes = map.values.toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar cliente: $e')),
      );
    }
  }

  Future<void> _removerCliente(Cliente cliente) async {
    try {
      await _service.remover(cliente.id);
      final map = await _service.encontrar();
      setState(() {
        _clientes = map.values.toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover cliente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: Builder(
        builder: (context) {
          if (_carregando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_erro != null) {
            return Center(child: Text('Erro: $_erro'));
          }
          if (_clientes.isEmpty) {
            return const Center(child: Text('Nenhum cliente encontrado'));
          }
          return RefreshIndicator(
            onRefresh: _carregarClientes,
            child: ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final c = _clientes[index];
                return ListTile(
                  leading: c.foto != null && c.foto!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(c.foto!),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('${c.nome} ${c.sobrenome}'),
                  subtitle: Text('${c.email} - Idade: ${c.idade}'),
                  onTap: () => _abrirFormulario(cliente: c),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removerCliente(c),
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

class _ClienteFormDialog extends StatefulWidget {
  final Cliente? cliente;

  const _ClienteFormDialog({this.cliente});

  @override
  State<_ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends State<_ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _emailController;
  late TextEditingController _idadeController;
  late TextEditingController _fotoController;

  @override
  void initState() {
    super.initState();
    _nomeController =
        TextEditingController(text: widget.cliente?.nome ?? '');
    _sobrenomeController =
        TextEditingController(text: widget.cliente?.sobrenome ?? '');
    _emailController =
        TextEditingController(text: widget.cliente?.email ?? '');
    _idadeController = TextEditingController(
      text: widget.cliente?.idade != null
          ? widget.cliente!.idade.toString()
          : '',
    );
    _fotoController =
        TextEditingController(text: widget.cliente?.foto ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _idadeController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final idade = int.tryParse(_idadeController.text) ?? 0;

    final cliente = Cliente(
      id: widget.cliente?.id,
      nome: _nomeController.text,
      sobrenome: _sobrenomeController.text,
      email: _emailController.text,
      idade: idade,
      foto: _fotoController.text,
    );

    Navigator.of(context).pop(cliente);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cliente == null ? 'Novo cliente' : 'Editar cliente'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _sobrenomeController,
                decoration: const InputDecoration(labelText: 'Sobrenome'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o sobrenome'
                    : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o email' : null,
              ),
              TextFormField(
                controller: _idadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Idade'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a idade';
                  }
                  final idade = int.tryParse(value);
                  if (idade == null || idade <= 0) {
                    return 'Idade inválida';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fotoController,
                decoration:
                    const InputDecoration(labelText: 'URL da foto (avatarUrl)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
