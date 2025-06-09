import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ValuesScreen extends StatefulWidget {
  const ValuesScreen({super.key});

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen> {
  Map<String, dynamic>? valores;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarValores();
  }

  Future<void> _carregarValores() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final data = await authProvider.fetchValoresAReceber();
    setState(() {
      valores = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Valores a Receber')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : valores == null
              ? const Center(child: Text('Nenhum valor encontrado.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: valores!.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key),
                        subtitle: Text(entry.value.toString()),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
