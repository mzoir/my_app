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
  final String? clientName; // ✅ from user.name via Laravel eager load
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
    this.clientName,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      serviceName: json['service_name']?.toString(),
      serviceType: json['service_type']?.toString(),
      description: json['description']?.toString(),
      ville: json['ville']?.toString(),
      address: json['address']?.toString(),
      additionalInfo: json['additional_info']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      responsesCount: json['responses_count'] as int? ?? 0,
      // ✅ get client name from nested user object
      clientName: json['user']?['name']?.toString() ??
          json['client_name']?.toString(),
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

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
}