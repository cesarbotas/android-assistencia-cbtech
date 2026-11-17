import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getStatusColor(String s) {
    switch (s.toLowerCase()) {
      case 'aberta':
        return AppColors.statusAberta;
      case 'diagnóstico':
      case 'diagnostico':
        return AppColors.statusDiagnostico;
      case 'orçamento pendente':
      case 'orcamento':
        return AppColors.statusOrcamento;
      case 'aprovada':
        return AppColors.statusAprovada;
      case 'em reparo':
        return AppColors.statusEmReparo;
      case 'concluída':
      case 'concluida':
        return AppColors.statusConcluida;
      case 'entregue':
        return AppColors.statusEntregue;
      case 'cancelada':
        return AppColors.statusCancelada;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
