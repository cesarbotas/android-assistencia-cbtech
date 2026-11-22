import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/environment_config.dart';
import '../../../core/constants/app_colors.dart';

class EnvironmentSelectorDialog extends ConsumerWidget {
  const EnvironmentSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEnv = ref.watch(environmentNotifierProvider);
    final envNotifier = ref.read(environmentNotifierProvider.notifier);

    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.dns, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Selecionar Ambiente de API'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppEnvironment.values.map((env) {
          final isSelected = env == currentEnv;
          return RadioListTile<AppEnvironment>(
            title: Text(env.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(
              env == AppEnvironment.local
                  ? 'http://localhost:5176'
                  : env == AppEnvironment.hml
                      ? 'https://cbtech-api-hml.onrender.com'
                      : 'https://api.cbtech.com.br',
              style: const TextStyle(fontSize: 11),
            ),
            value: env,
            groupValue: currentEnv,
            activeColor: AppColors.primary,
            onChanged: (val) {
              if (val != null) {
                envNotifier.setEnvironment(val);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ambiente alterado para: ${val.label}')),
                );
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
