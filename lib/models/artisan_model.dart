class ArtisanModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? ville;
  final String? description;
  final String? speciality;
  final String? profilePhoto;
  final List<String?> portfolioImages; // ← ADD THIS
  final double? rating;
  final int reviewsCount;
  final bool isVerified;
  final List<String> services;

  ArtisanModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.ville,
    this.description,
    required this.portfolioImages,
    this.speciality,
    this.profilePhoto,
    this.rating,
    required this.reviewsCount,
    required this.isVerified,
    required this.services,
  });

  factory ArtisanModel.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'http://127.0.0.1:8000/';

  String fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url; // already full URL
    return '$baseUrl$url'; // ✅ add base URL
  }

    return ArtisanModel(
      id: json["id"],
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      ville: json["ville"],
      description: json["description"],
      speciality: json["speciality"],
      profilePhoto: json["profile_photo"] != null ? fixUrl(json["profile_photo"]) : null,
      rating: json["rating"] != null
          ? double.tryParse(json["rating"].toString())
          : null,
      reviewsCount: json["reviews_count"] ?? 0,
      isVerified: json["is_verified"] ?? false,
       portfolioImages: (json['portfolio_images'] as List? ?? [])
        .map((e) => fixUrl(e?.toString()))
        .where((e) => e.isNotEmpty)
        .toList(),
      services: json["services"] != null
          ? List<String>.from(json["services"])
          : [],
    );
  }
}
