enum AttachmentType {
  recebimento('Recebimento'),
  defeito('Defeito'),
  diagnostico('Diagnóstico'),
  reparo('Durante Reparo'),
  finalizacao('Finalização / Testes'),
  entrega('Entrega');

  final String label;
  const AttachmentType(this.label);
}

class WorkOrderAttachment {
  final String id;
  final String workOrderId;
  final AttachmentType type;
  final String fileName;
  final String filePath;
  final int? fileSize;
  final DateTime createdAt;

  WorkOrderAttachment({
    required this.id,
    required this.workOrderId,
    required this.type,
    required this.fileName,
    required this.filePath,
    this.fileSize,
    required this.createdAt,
  });

  factory WorkOrderAttachment.fromJson(Map<String, dynamic> json) {
    return WorkOrderAttachment(
      id: json['id'] as String,
      workOrderId: json['workOrderId'] as String? ?? '',
      type: _typeFromString(json['type'] as String?),
      fileName: json['fileName'] as String? ?? 'foto.jpg',
      filePath: json['filePath'] as String? ?? '',
      fileSize: json['fileSize'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workOrderId': workOrderId,
      'type': type.label,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static AttachmentType _typeFromString(String? typeStr) {
    for (final t in AttachmentType.values) {
      if (t.label.toLowerCase() == typeStr?.toLowerCase() ||
          t.name.toLowerCase() == typeStr?.toLowerCase()) {
        return t;
      }
    }
    return AttachmentType.recebimento;
  }
}
