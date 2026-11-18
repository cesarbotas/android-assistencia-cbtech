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
    for (final s in WorkOrderStatus.values) {
      if (s.label.toLowerCase() == val.toLowerCase() ||
          s.name.toLowerCase() == val.toLowerCase()) {
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

  // Lista de próximas transições permitidas
  List<WorkOrderStatus> get nextAllowedTransitions {
    switch (this) {
      case WorkOrderStatus.aberta:
        return [WorkOrderStatus.diagnostico, WorkOrderStatus.orcamentoPendente, WorkOrderStatus.cancelada];
      case WorkOrderStatus.diagnostico:
        return [WorkOrderStatus.orcamentoPendente, WorkOrderStatus.cancelada];
      case WorkOrderStatus.orcamentoPendente:
        return [WorkOrderStatus.aprovada, WorkOrderStatus.cancelada];
      case WorkOrderStatus.aprovada:
        return [WorkOrderStatus.emReparo, WorkOrderStatus.aguardandoPeca, WorkOrderStatus.cancelada];
      case WorkOrderStatus.aguardandoPeca:
        return [WorkOrderStatus.emReparo, WorkOrderStatus.cancelada];
      case WorkOrderStatus.emReparo:
        return [WorkOrderStatus.testes, WorkOrderStatus.aguardandoPeca];
      case WorkOrderStatus.testes:
        return [WorkOrderStatus.concluida, WorkOrderStatus.emReparo];
      case WorkOrderStatus.concluida:
        return [WorkOrderStatus.entregue];
      case WorkOrderStatus.entregue:
      case WorkOrderStatus.cancelada:
        return [];
    }
  }
}
