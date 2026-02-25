class ServiceRequest {
  final int id;
  final int userId;
  final String? serviceName;
  final String? serviceType;
  final String? description;
  final String? ville;
  final String? address;
  final String? additionalInfo;
  final String status;
  final int responsesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceRequest({
    required this.id,
    required this.userId,
    this.serviceName,
    this.serviceType,
    this.description,
    this.ville,
    this.address,
    this.additionalInfo,
    this.status = 'pending',
    this.responsesCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      serviceName: json['service_name']?.toString(),
      serviceType: json['service_type']?.toString(),
      description: json['description']?.toString(),
      ville: json['ville']?.toString(),
      address: json['address']?.toString(),
      additionalInfo: json['additional_info']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      responsesCount: json['responses_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_name': serviceName,
      'service_type': serviceType,
      'description': description,
      'ville': ville,
      'address': address,
      'additional_info': additionalInfo,
      'status': status,
      'responses_count': responsesCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ServiceRequest copyWith({
    int? id,
    int? userId,
    String? serviceName,
    String? serviceType,
    String? description,
    String? ville,
    String? address,
    String? additionalInfo,
    String? status,
    int? responsesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceName: serviceName ?? this.serviceName,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      ville: ville ?? this.ville,
      address: address ?? this.address,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      status: status ?? this.status,
      responsesCount: responsesCount ?? this.responsesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  @override
  String toString() => 'ServiceRequest(id: $id, serviceName: $serviceName, status: $status)';
}