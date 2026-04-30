class Country {
  final int id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['country_id'] ?? 0,
      name: json['country_name'] ?? '',
    );
  }
}

class StateModel {
  final int id;
  final String name;

  StateModel({required this.id, required this.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['state_id'] ?? 0,
      name: json['state_name'] ?? '',
    );
  }
}

class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['district_id'] ?? 0,
      name: json['district_name'] ?? '',
    );
  }
}

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['city_id'] ?? 0,
      name: json['city_name'] ?? '',
    );
  }
}

class RequiredDocument {
  final int id;
  final String name;
  final bool isIdentityDoc;
  final bool isActive;
  final bool isMandatory;

  RequiredDocument({
    required this.id,
    required this.name,
    required this.isIdentityDoc,
    required this.isActive,
    required this.isMandatory,
  });

  factory RequiredDocument.fromJson(Map<String, dynamic> json) {
    final docs = json['RequiredDocs'] ?? {};
    return RequiredDocument(
      id: json['detail_id'] ?? 0,
      name: docs['doc_name'] ?? '',
      isIdentityDoc: docs['is_identity_doc'] ?? false,
      isActive: json['is_active'] ?? false,
      isMandatory: json['is_mandatory'] ?? false,
    );
  }
}
