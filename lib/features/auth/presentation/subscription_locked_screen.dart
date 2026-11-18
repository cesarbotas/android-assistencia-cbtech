import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import 'auth_controller.dart';

class SubscriptionLockedScreen extends ConsumerWidget {
  const SubscriptionLockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tenantName = authState.activeTenantName ?? 'Sua Empresa';

    void contactSupport() {
      Share.share('Olá, gostaria de regularizar a mensalidade da assistência técnica $tenantName para desbloquear o sistema CBTech.');
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline, color: Colors.red, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Acesso Suspenso',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Assistência: $tenantName',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Identificamos que a mensalidade do plano SaaS da sua empresa encontra-se pendente ou expirada.\n\nPara restabelecer o acesso completo às Ordens de Serviço, Estoque e Caixa, realize a regularização do pagamento.',
                    style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chave PIX para Regularização:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 4),
                        Text('financeiro@cbtech.com.br (CNPJ)\nValor: R\$ 149,90', style: TextStyle(fontSize: 13, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Falar com Suporte (WhatsApp)',
                    icon: Icons.support_agent,
                    onPressed: contactSupport,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).logout();
                    },
                    child: const Text('Sair da Conta / Trocar Tenant', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
