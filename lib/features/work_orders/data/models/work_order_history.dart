import 'work_order_status.dart';

class WorkOrderHistory {
  final String id;
  final String workOrderId;
  final WorkOrderStatus previousStatus;
  final WorkOrderStatus newStatus;
  final String userName;
  final String? note;
  final DateTime createdAt;

  WorkOrderHistory({
    required this.id,
    required this.workOrderId,
    required this.previousStatus,
    required this.newStatus,
    required this.userName,
    this.note,
    required this.createdAt,
  });

  factory WorkOrderHistory.fromJson(Map<String, dynamic> json) {
    return WorkOrderHistory(
      id: json['id'] as String,
      workOrderId: json['workOrderId'] as String? ?? '',
      previousStatus: WorkOrderStatus.fromString(json['previousStatus'] as String? ?? ''),
      newStatus: WorkOrderStatus.fromString(json['newStatus'] as String? ?? ''),
      userName: json['userName'] as String? ?? 'Sistema',
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workOrderId': workOrderId,
      'previousStatus': previousStatus.label,
      'newStatus': newStatus.label,
      'userName': userName,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
