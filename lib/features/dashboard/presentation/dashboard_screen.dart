import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/presentation/auth_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'Hoje';

  final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authState.activeTenantName ?? 'CB Tech',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Painel Operacional',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Indicadores atualizados com sucesso.')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova OS', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => context.go('/work-orders/new'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtro de Período
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Visão Geral',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  underline: const SizedBox(),
                  items: ['Hoje', 'Esta Semana', 'Este Mês', 'Ano']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPeriod = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cards de Resumo de OS (Grid 2x2)
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'OS Abertas',
                    count: '14',
                    icon: Icons.assignment_outlined,
                    color: AppColors.statusAberta,
                    onTap: () => context.go('/work-orders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Em Reparo',
                    count: '6',
                    icon: Icons.build_outlined,
                    color: AppColors.statusEmReparo,
                    onTap: () => context.go('/work-orders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Aguard. Orçamento',
                    count: '5',
                    icon: Icons.pending_actions_outlined,
                    color: AppColors.statusOrcamento,
                    onTap: () => context.go('/work-orders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Aguard. Retirada',
                    count: '8',
                    icon: Icons.check_circle_outline,
                    color: AppColors.statusConcluida,
                    onTap: () => context.go('/work-orders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Financeiro (Faturamento x Custos x Lucro Bruto)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Desempenho Financeiro',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+18% vs mês anterior',
                            style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _FinancialItem(
                          label: 'Faturamento',
                          value: currencyFormatter.format(12480.00),
                          color: Colors.blue.shade800,
                        ),
                        _FinancialItem(
                          label: 'Custos de Peças',
                          value: currencyFormatter.format(4120.00),
                          color: Colors.orange.shade800,
                        ),
                        _FinancialItem(
                          label: 'Lucro Bruto',
                          value: currencyFormatter.format(8360.00),
                          color: Colors.green.shade800,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Alerta de Estoque Baixo
            Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.amber.shade200),
              ),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 30),
                title: const Text(
                  '3 Peças com Estoque Baixo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text('Telas e baterias abaixo do mínimo configurado.'),
                trailing: TextButton(
                  onPressed: () => context.go('/inventory'),
                  child: const Text('Ver Estoque'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Seção Últimas Ordens de Serviço
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Últimas Ordens de Serviço',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/work-orders'),
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _RecentOrderTile(
              orderNumber: 'OS-0104',
              clientName: 'Mariana Souza',
              device: 'iPhone 13 - 128GB',
              status: 'Em Reparo',
              date: 'Hoje, 14:30',
              onTap: () => context.go('/work-orders'),
            ),
            _RecentOrderTile(
              orderNumber: 'OS-0103',
              clientName: 'Carlos Eduardo',
              device: 'Samsung Galaxy S22 Ultra',
              status: 'Aprovada',
              date: 'Hoje, 11:15',
              onTap: () => context.go('/work-orders'),
            ),
            _RecentOrderTile(
              orderNumber: 'OS-0102',
              clientName: 'Fernanda Lima',
              device: 'Motorola Edge 30 Fusion',
              status: 'Orçamento Pendente',
              date: 'Ontem, 16:40',
              onTap: () => context.go('/work-orders'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinancialItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinancialItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final String orderNumber;
  final String clientName;
  final String device;
  final String status;
  final String date;
  final VoidCallback onTap;

  const _RecentOrderTile({
    required this.orderNumber,
    required this.clientName,
    required this.device,
    required this.status,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Text(
              orderNumber,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                clientName,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(device, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: status),
                Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
