class User {
  final int id; // ✅ int (Laravel id is int)
  final String name;
  final String email;
  final String? phone;
  final String? dateOfBirth;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
    };
  }
}
