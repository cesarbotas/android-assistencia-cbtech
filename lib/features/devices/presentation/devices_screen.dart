import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import 'devices_controller.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(devicesControllerProvider);
    final controller = ref.read(devicesControllerProvider.notifier);
    final devices = state.filteredDevices;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Aparelhos dos Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Aparelho', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => context.go('/devices/new'),
      ),
      body: Column(
        children: [
          // Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por modelo, marca, cliente ou IMEI...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          controller.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => controller.setSearchQuery(val),
            ),
          ),

          // Chips de Filtro por Marca (Apple, Samsung, Motorola, Xiaomi...)
          if (state.brands.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Todas as Marcas'),
                      selected: state.selectedBrandFilter == null,
                      onSelected: (_) => controller.setBrandFilter(null),
                    ),
                  ),
                  ...state.brands.map((b) {
                    final isSelected = state.selectedBrandFilter == b.name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(b.name),
                        selected: isSelected,
                        onSelected: (val) => controller.setBrandFilter(val ? b.name : null),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Lista de Aparelhos
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : devices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_android, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              state.searchQuery.isNotEmpty || state.selectedBrandFilter != null
                                  ? 'Nenhum aparelho encontrado para o filtro'
                                  : 'Nenhum aparelho cadastrado',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final d = devices[index];
                          return Card(
                            elevation: 1.5,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => context.go('/devices/edit', extra: d),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.smartphone, color: AppColors.primary, size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${d.brandName} ${d.modelName}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (d.color != null)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    d.color!,
                                                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                d.customerName,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (d.imei1 != null) ...[
                                                Text(
                                                  'IMEI: ${d.imei1}',
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              if (d.storage != null)
                                                Text(
                                                  '• ${d.storage}',
                                                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
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
