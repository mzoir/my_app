class ArtisanModel {
  final String nomComplet;
  final String email;
  final String phone;
  final String password;

  final String? dateNaissance; // format: YYYY-MM-DD
  final String? ville;
  final String? adresse;
  final String? diplome;
  final String? description;

  // (optionnel) services
  final List<int>? serviceIds;
  final int? servicePrincipalId;
  final String? newServiceName;

  ArtisanModel({
    required this.nomComplet,
    required this.email,
    required this.phone,
    required this.password,
    this.dateNaissance,
    this.ville,
    this.adresse,
    this.diplome,
    this.description,
    this.serviceIds,
    this.servicePrincipalId,
    this.newServiceName,
  });

  /// ✅ Fields attendus par Laravel StoreArtisanRequest
  Map<String, String> toJson() {
    final data = <String, String>{
      "nom_complet": nomComplet,
      "email": email,
      "phone": phone,
      "password": password,
    };

    // ✅ nullable: on les envoie seulement si non null et non vide
    void putIfNotEmpty(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        data[key] = value.trim();
      }
    }

    putIfNotEmpty("date_naissance", dateNaissance);
    putIfNotEmpty("ville", ville);
    putIfNotEmpty("adresse", adresse);
    putIfNotEmpty("diplome", diplome);
    putIfNotEmpty("description", description);

    // ✅ services (si tu les utilises côté backend)
    if (serviceIds != null && serviceIds!.isNotEmpty) {
      // Laravel valide souvent service_ids comme array => on envoie service_ids[]
      // avec plusieurs valeurs
      // (dans MultipartRequest, on doit ajouter plusieurs fields)
      // => géré dans le ViewModel
    }

    putIfNotEmpty("new_service_name", newServiceName);
    if (servicePrincipalId != null) {
      data["service_principal_id"] = servicePrincipalId.toString();
    }

    return data;
  }
}
