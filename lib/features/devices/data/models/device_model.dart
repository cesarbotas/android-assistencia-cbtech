class DeviceModel {
  final String id;
  final String brandId;
  final String brandName;
  final String name;
  final String? codeReference;
  final bool isGlobal;
  final String? tenantId;

  DeviceModel({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.name,
    this.codeReference,
    this.isGlobal = true,
    this.tenantId,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      brandId: json['brandId'] as String,
      brandName: json['brandName'] as String? ?? '',
      name: json['name'] as String,
      codeReference: json['codeReference'] as String?,
      isGlobal: json['isGlobal'] as bool? ?? true,
      tenantId: json['tenantId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brandId': brandId,
      'brandName': brandName,
      'name': name,
      'codeReference': codeReference,
      'isGlobal': isGlobal,
      'tenantId': tenantId,
    };
  }
}
