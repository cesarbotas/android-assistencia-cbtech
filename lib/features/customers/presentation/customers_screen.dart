import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final List<Map<String, String>> _customers = [
    {
      'name': 'Mariana Souza',
      'phone': '(11) 99876-5432',
      'email': 'mariana.souza@gmail.com',
      'devices': '2 aparelhos cadastrados',
    },
    {
      'name': 'Carlos Eduardo Silva',
      'phone': '(11) 98888-7777',
      'email': 'carlos.edu@outlook.com',
      'devices': '1 aparelho cadastrado',
    },
    {
      'name': 'Fernanda Lima',
      'phone': '(11) 97777-6666',
      'email': 'fernanda.lima@hotmail.com',
      'devices': '3 aparelhos cadastrados',
    },
    {
      'name': 'Rodrigo Menezes',
      'phone': '(11) 96666-5555',
      'email': 'rodrigo.m@gmail.com',
      'devices': '1 aparelho cadastrado',
    },
  ];

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome Completo')),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'WhatsApp / Telefone')),
            const SizedBox(height: 10),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'E-mail')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _customers.insert(0, {
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                    'email': emailCtrl.text,
                    'devices': '0 aparelhos',
                  });
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Clientes Cadastrados'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.person_add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final c = _customers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  c['name']![0],
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${c['phone']} • ${c['email']}', style: const TextStyle(fontSize: 12)),
                  Text(c['devices']!, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
