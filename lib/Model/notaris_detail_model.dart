class NotarisDetailModel {
  final int id;
  final int clientId;
  final int staffId;
  final int caseId;
  final String lifeStatus;
  final String description;
  final String status; // pending | proses | revisi | selesai
  final int createdAt;
  final int updatedAt;
  final NotarisClientModel client;
  final NotarisStaffModel staff;
  final NotarisCaseModel caseData;
  final NotarisDocumentTransactionModel? documentTransaction;

  NotarisDetailModel({
    required this.id,
    required this.clientId,
    required this.staffId,
    required this.caseId,
    required this.lifeStatus,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.client,
    required this.staff,
    required this.caseData,
    this.documentTransaction,
  });

  factory NotarisDetailModel.fromJson(Map<String, dynamic> json) {
    return NotarisDetailModel(
      id: json['id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      staffId: json['staff_id'] ?? 0,
      caseId: json['case_id'] ?? 0,
      lifeStatus: json['life_status'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
      client: NotarisClientModel.fromJson(json['client'] ?? {}),
      staff: NotarisStaffModel.fromJson(json['staff'] ?? {}),
      caseData: NotarisCaseModel.fromJson(json['case'] ?? {}),
      documentTransaction: json['document_transaction'] != null
          ? NotarisDocumentTransactionModel.fromJson(
              json['document_transaction'],
            )
          : null,
    );
  }
}

class NotarisClientModel {
  final int id;
  final String publicId;
  final String name;
  final String phone;
  final String email;

  NotarisClientModel({
    required this.id,
    required this.publicId,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory NotarisClientModel.fromJson(Map<String, dynamic> json) {
    return NotarisClientModel(
      id: json['id'] ?? 0,
      publicId: json['publicID'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class NotarisStaffModel {
  final int id;
  final String staffName;
  final int instituteId;

  NotarisStaffModel({
    required this.id,
    required this.staffName,
    required this.instituteId,
  });

  factory NotarisStaffModel.fromJson(Map<String, dynamic> json) {
    return NotarisStaffModel(
      // 🔧 backend pakai key "ID"/"StaffName" (capital) khusus di object staff
      id: json['ID'] ?? 0,
      staffName: json['StaffName'] ?? '',
      instituteId: json['InstituteID'] ?? 0,
    );
  }
}

class NotarisCaseModel {
  final int id;
  final String caseName;

  NotarisCaseModel({required this.id, required this.caseName});

  factory NotarisCaseModel.fromJson(Map<String, dynamic> json) {
    return NotarisCaseModel(
      id: json['id'] ?? 0,
      caseName: json['case_name'] ?? '',
    );
  }
}

class NotarisDocumentTransactionModel {
  final int id;
  final int notaryTransactionId;
  final NotarisAssetModel asset;

  NotarisDocumentTransactionModel({
    required this.id,
    required this.notaryTransactionId,
    required this.asset,
  });

  factory NotarisDocumentTransactionModel.fromJson(Map<String, dynamic> json) {
    return NotarisDocumentTransactionModel(
      id: json['id'] ?? 0,
      notaryTransactionId: json['notary_transaction_id'] ?? 0,
      asset: NotarisAssetModel.fromJson(json['asset'] ?? {}),
    );
  }
}

class NotarisAssetModel {
  final List<NotarisDocMetadata> metadata;
  final String type;

  NotarisAssetModel({required this.metadata, required this.type});

  factory NotarisAssetModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['metadata'] as List? ?? [];
    return NotarisAssetModel(
      metadata: rawList
          .map((e) => NotarisDocMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: json['type'] ?? '',
    );
  }
}

class NotarisDocMetadata {
  final String label;
  final String url;

  NotarisDocMetadata({required this.label, required this.url});

  factory NotarisDocMetadata.fromJson(Map<String, dynamic> json) {
    return NotarisDocMetadata(
      label: json['label'] ?? '',
      url: json['url'] ?? '',
    );
  }
}