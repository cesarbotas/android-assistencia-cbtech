import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/status_badge.dart';

class WorkOrdersScreen extends ConsumerStatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  ConsumerState<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends ConsumerState<WorkOrdersScreen> {
  String _selectedFilter = 'Todas';
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _workOrders = [
    {
      'id': '1',
      'number': 'OS-0104',
      'client': 'Mariana Souza',
      'phone': '(11) 99876-5432',
      'device': 'Apple iPhone 13 (128GB)',
      'defect': 'Touch não responde, tela trincada no topo',
      'status': 'Em Reparo',
      'total': 'R\$ 630,00',
      'date': '17/11/2026',
    },
    {
      'id': '2',
      'number': 'OS-0103',
      'client': 'Carlos Eduardo Silva',
      'phone': '(11) 98888-7777',
      'device': 'Samsung Galaxy S22 Ultra',
      'defect': 'Aparelho não carrega após contato com umidade',
      'status': 'Aprovada',
      'total': 'R\$ 380,00',
      'date': '17/11/2026',
    },
    {
      'id': '3',
      'number': 'OS-0102',
      'client': 'Fernanda Lima',
      'phone': '(11) 97777-6666',
      'device': 'Motorola Edge 30 Fusion',
      'defect': 'Bateria estufada, desligando com 40%',
      'status': 'Orçamento Pendente',
      'total': 'R\$ 220,00',
      'date': '16/11/2026',
    },
    {
      'id': '4',
      'number': 'OS-0101',
      'client': 'Rodrigo Menezes',
      'phone': '(11) 96666-5555',
      'device': 'Xiaomi Redmi Note 12',
      'defect': 'Sem áudio no alto-falante auricular',
      'status': 'Concluída',
      'total': 'R\$ 150,00',
      'date': '15/11/2026',
    },
  ];

  void _shareViaWhatsApp(Map<String, dynamic> os) {
    final message = '''
*CB Tech — Atualização de Ordem de Serviço*
Olá, ${os['client']}!
Sua ordem *${os['number']}* está atualmente com o status: *${os['status']}*.
Aparelho: ${os['device']}
Defeito: ${os['defect']}
Valor total previsto: ${os['total']}

Caso tenha dúvidas, estamos à disposição!
''';
    Share.share(message, subject: 'Status da ${os['number']} - CB Tech');
  }

  void _showOrderDetails(Map<String, dynamic> os) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  os['number'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                StatusBadge(status: os['status']),
              ],
            ),
            const SizedBox(height: 12),
            Text('Cliente: ${os['client']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Telefone: ${os['phone']}', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            const Text('Aparelho e Defeito', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(os['device']),
            Text(os['defect'], style: const TextStyle(color: Colors.black87)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Valor Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(os['total'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _shareViaWhatsApp(os);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Comprovante PDF'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Comprovante da ${os['number']} pronto para impressão/envio.')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _workOrders.where((os) {
      if (_selectedFilter != 'Todas' && os['status'] != _selectedFilter) {
        return false;
      }
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        final matchNumber = os['number'].toString().toLowerCase().contains(query);
        final matchClient = os['client'].toString().toLowerCase().contains(query);
        final matchDevice = os['device'].toString().toLowerCase().contains(query);
        return matchNumber || matchClient || matchDevice;
      }
      return true;
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => context.go('/work-orders/new'),
      ),
      body: Column(
        children: [
          // Campo de Busca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por OS, cliente ou aparelho...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Chips de Filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                'Todas',
                'Aberta',
                'Orçamento Pendente',
                'Aprovada',
                'Em Reparo',
                'Concluída',
              ].map((status) {
                final isSelected = _selectedFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedFilter = status);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Lista de OS
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('Nenhuma ordem de serviço encontrada.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final os = filtered[index];
                      return Card(
                        elevation: 1.5,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showOrderDetails(os),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      os['number'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    StatusBadge(status: os['status']),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(os['client'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.smartphone, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(os['device'], style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Data: ${os['date']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(
                                      os['total'],
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
