class PpatDetailModel {
  final int id;
  final int clientId;
  final int caseId;
  final int amount;
  final String lifeStatus;
  final String description;
  String status;
  final String paymentStatus;
  final int? titipBiayaInput;
  final int createdAt;
  final int updatedAt;
  final ClientModel client;
  final CaseModel caseData;
  final StaffModel staff;
  final DocumentTransactionModel? documentTransaction;

  PpatDetailModel({
    required this.id,
    required this.clientId,
    required this.caseId,
    required this.amount,
    required this.lifeStatus,
    required this.description,
    required this.status,
    required this.paymentStatus,
    this.titipBiayaInput,
    required this.createdAt,
    required this.updatedAt,
    required this.client,
    required this.caseData,
    required this.staff,
    this.documentTransaction,
  });

  factory PpatDetailModel.fromJson(Map<String, dynamic> json) {
    return PpatDetailModel(
      id: json['id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      caseId: json['case_id'] ?? 0,
      amount: json['amount'] ?? 0,
      lifeStatus: json['life_status'] ?? "",
      description: json['description'] ?? "",
      status: json['status'] ?? "pending",
      paymentStatus: json['payment_status'] ?? "BelumLunas",
      titipBiayaInput: json['titip_biaya_input'],
      createdAt: json['created_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
      client: ClientModel.fromJson(json['client'] ?? {}),
      caseData: CaseModel.fromJson(json['case'] ?? {}),
      staff: StaffModel.fromJson(json['staff'] ?? {}),
      documentTransaction: json['document_transaction'] != null
          ? DocumentTransactionModel.fromJson(json['document_transaction'])
          : null,
    );
  }

  String? get type => null;
}

class ClientModel {
  final int id;
  final String publicId;
  final String name;
  final String phone;
  final String email;
  final int createdAt;
  final int updatedAt;

  ClientModel({
    required this.id,
    required this.publicId,
    required this.name,
    required this.phone,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? 0,
      publicId: json['publicID'] ?? json['public_id'] ?? "",
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

class StaffModel {
  final int id;
  final String staffName;

  StaffModel({
    required this.id,
    required this.staffName,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? 0,
      staffName: json['name'] ?? json['staff_name'] ?? "",
    );
  }
}

// =========================================================
// 📁 KELAS TAMBAHAN UNTUK METADATA DOKUMEN BERKAS PPAT
// =========================================================

class DocumentTransactionModel {
  final int id;
  final AssetModel asset;

  DocumentTransactionModel({
    required this.id,
    required this.asset,
  });

  factory DocumentTransactionModel.fromJson(Map<String, dynamic> json) {
    return DocumentTransactionModel(
      id: json['id'] ?? 0,
      asset: AssetModel.fromJson(json['asset'] ?? {}),
    );
  }
}

class AssetModel {
  final List<PpatDocMetadata> metadata;

  AssetModel({required this.metadata});

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['metadata'];
    List<PpatDocMetadata> metaList = [];

    if (rawList is List) {
      metaList = rawList.map((item) => PpatDocMetadata.fromJson(item)).toList();
    }

    return AssetModel(metadata: metaList);
  }
}

class PpatDocMetadata {
  final String id;
  final String label;
  final String url;
  final String matchkey;

  PpatDocMetadata({
    required this.id,
    required this.label,
    required this.url,
    required this.matchkey,
  });

  factory PpatDocMetadata.fromJson(Map<String, dynamic> json) {
    return PpatDocMetadata(
      id: json['id']?.toString() ?? json['file_id']?.toString() ?? '',
      label: json['label'] ?? json['name'] ?? json['title'] ?? 'Dokumen tanpa nama',
      url: json['url'] ?? json['file_url'] ?? '',
      matchkey: json['matchkey'] ?? json['match_key'] ?? '',
    );
  }
}