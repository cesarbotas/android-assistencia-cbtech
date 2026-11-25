import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum WorkOrderStatus {
  aberta('Aberta'),
  diagnostico('Diagnóstico'),
  orcamentoPendente('Orçamento Pendente'),
  aprovada('Aprovada'),
  emReparo('Em Reparo'),
  aguardandoPeca('Aguardando Peça'),
  testes('Testes'),
  concluida('Concluída'),
  entregue('Entregue'),
  cancelada('Cancelada');

  final String label;
  const WorkOrderStatus(this.label);

  static WorkOrderStatus fromString(String val) {
    final upper = val.toUpperCase().trim();
    if (upper.contains('AGUARDANDO_PECA') || upper.contains('PECA')) return WorkOrderStatus.aguardandoPeca;
    if (upper.contains('DIAGNOSTICO')) return WorkOrderStatus.diagnostico;
    if (upper.contains('ORCAMENTO')) return WorkOrderStatus.orcamentoPendente;
    if (upper.contains('APROVADA')) return WorkOrderStatus.aprovada;
    if (upper.contains('REPARO') || upper.contains('ANDAMENTO')) return WorkOrderStatus.emReparo;
    if (upper.contains('TESTES')) return WorkOrderStatus.testes;
    if (upper.contains('CONCLUIDO') || upper.contains('CONCLUIDA')) return WorkOrderStatus.concluida;
    if (upper.contains('ENTREGUE')) return WorkOrderStatus.entregue;
    if (upper.contains('CANCELADO') || upper.contains('CANCELADA')) return WorkOrderStatus.cancelada;

    final cleanVal = val.toLowerCase().replaceAll('_', '');
    for (final s in WorkOrderStatus.values) {
      final cleanName = s.name.toLowerCase().replaceAll('_', '');
      final cleanLabel = s.label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (cleanName == cleanVal || cleanLabel == cleanVal.replaceAll(RegExp(r'[^a-z0-9]'), '')) {
        return s;
      }
    }
    return WorkOrderStatus.aberta;
  }

  Color get color {
    switch (this) {
      case WorkOrderStatus.aberta:
        return AppColors.statusAberta;
      case WorkOrderStatus.diagnostico:
        return AppColors.statusDiagnostico;
      case WorkOrderStatus.orcamentoPendente:
        return AppColors.statusOrcamento;
      case WorkOrderStatus.aprovada:
        return AppColors.statusAprovada;
      case WorkOrderStatus.emReparo:
        return AppColors.statusEmReparo;
      case WorkOrderStatus.aguardandoPeca:
        return Colors.deepOrange;
      case WorkOrderStatus.testes:
        return Colors.indigo;
      case WorkOrderStatus.concluida:
        return AppColors.statusConcluida;
      case WorkOrderStatus.entregue:
        return AppColors.statusEntregue;
      case WorkOrderStatus.cancelada:
        return AppColors.statusCancelada;
    }
  }

  // Transições flexíveis para permitir avançar para qualquer status
  List<WorkOrderStatus> get nextAllowedTransitions {
    return WorkOrderStatus.values.where((st) => st != this).toList();
  }
}
