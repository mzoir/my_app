class User {
  final int id; // ✅ int (Laravel id is int)
  final String name;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? ville;
  final String? role; // ✅ ADD THIS

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.ville,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      ville: json['ville']?.toString(),
      role: json['role']?.toString()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'ville': ville,
    };
  }
}
