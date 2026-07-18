class BerkasModel {
  final int id;
  final int clientId;
  final int caseId;
  final int amount;
  final String lifeStatus;
  final String description;
  String status;
  final int createdAt;
  final int updatedAt;
  final ClientModel client;
  final CaseModel caseData;

  BerkasModel({
    required this.id,
    required this.clientId,
    required this.caseId,
    required this.amount,
    required this.lifeStatus,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.client,
    required this.caseData,
  });

  factory BerkasModel.fromJson(Map<String, dynamic> json) {
    return BerkasModel(
      id: json['id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      caseId: json['case_id'] ?? 0,
      amount: json['amount'] ?? 0,
      lifeStatus: json['life_status'] ?? "",
      description: json['description'] ?? "",
      status: json['status'] ?? "pending",
      createdAt: json['created_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
      client: ClientModel.fromJson(json['client'] ?? {}),
      caseData: CaseModel.fromJson(json['case'] ?? {}),
    );
  }

  String? get type => null;
}

class ClientModel {
  final int id;
  final String publicID;
  final String name;
  final String phone;
  final String email;
  final int createdAt;
  final int updatedAt;

  ClientModel({
    required this.id,
    required this.publicID,
    required this.name,
    required this.phone,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? 0,
      publicID: json['publicID'] ?? "",
      name: json['name'] ?? "Tanpa Nama",
      phone: json['phone'] ?? "",
      email: json['email'] ?? "",
      createdAt: json['created_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
    );
  }
}

class CaseModel {
  final int id;
  final String caseName;
  final int createdAt;
  final int updatedAt;

  CaseModel({
    required this.id,
    required this.caseName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] ?? 0,
      caseName: json['case_name'] ?? "",
      createdAt: json['created_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
    );
  }
}