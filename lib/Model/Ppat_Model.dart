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
  final InstituteModel? institute;
  final DocumentTransactionModel? documentTransaction;
  final TransactionAddressModel? transactionAddress;
  final CertificateModel? certificate;
  final String notaryName;

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
    this.institute,
    this.documentTransaction,
    this.transactionAddress,
    this.certificate,
    this.notaryName = "",
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
      institute: json['institute'] != null
          ? InstituteModel.fromJson(json['institute'])
          : null,
      documentTransaction: json['document_transaction'] != null
          ? DocumentTransactionModel.fromJson(json['document_transaction'])
          : null,
      transactionAddress: json['transaction_address'] != null
          ? TransactionAddressModel.fromJson(json['transaction_address'])
          : null,
      certificate: json['certificate'] != null
          ? CertificateModel.fromJson(json['certificate'])
          : null,
      notaryName: json['notary_name'] ?? "",
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

  StaffModel({required this.id, required this.staffName});

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? json['ID'] ?? 0,
      staffName: json['name'] ?? json['staff_name'] ?? json['StaffName'] ?? "",
    );
  }
}

class InstituteModel {
  final int id;
  final String name;

  InstituteModel({required this.id, required this.name});

  factory InstituteModel.fromJson(Map<String, dynamic> json) {
    return InstituteModel(id: json['id'] ?? 0, name: json['name'] ?? "");
  }
}

class DocumentTransactionModel {
  final int id;
  final AssetModel asset;

  DocumentTransactionModel({required this.id, required this.asset});

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
    var rawMetadata = json['metadata'];
    List<PpatDocMetadata> metaList = [];

    if (rawMetadata is List) {
      metaList = rawMetadata
          .whereType<Map>()
          .map(
            (item) => PpatDocMetadata.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } else if (rawMetadata is Map) {
      final rawFiles = rawMetadata['files'];
      if (rawFiles is List) {
        metaList = rawFiles
            .whereType<Map>()
            .map(
              (item) =>
                  PpatDocMetadata.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
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
      label:
          json['label'] ??
          json['name'] ??
          json['title'] ??
          'Dokumen tanpa nama',
      url: json['url'] ?? json['file_url'] ?? '',
      matchkey: json['matchkey'] ?? json['match_key'] ?? '',
    );
  }
}

class TransactionAddressModel {
  final int id;
  final int transactionId;
  final String transferorName;
  final String transferorAddress;
  final String transferorNpwp;
  final String transfereeName;
  final String transfereeAddress;
  final String transfereeNpwp;
  final String hamlet;
  final String village;
  final int landArea;
  final int buildingArea;
  final String book;
  final String number;
  final int taxYear;
  final String nop;
  final int njop;
  final int bphtb;
  final int createdAt;
  final int updatedAt;

  TransactionAddressModel({
    required this.id,
    required this.transactionId,
    required this.transferorName,
    required this.transferorAddress,
    required this.transferorNpwp,
    required this.transfereeName,
    required this.transfereeAddress,
    required this.transfereeNpwp,
    required this.hamlet,
    required this.village,
    required this.landArea,
    required this.buildingArea,
    required this.book,
    required this.number,
    required this.taxYear,
    required this.nop,
    required this.njop,
    required this.bphtb,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionAddressModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return TransactionAddressModel(
      id: toInt(json['id']),
      transactionId: toInt(json['transaction_id']),
      transferorName: json['transferor_name']?.toString() ?? '',
      transferorAddress: json['transferor_address']?.toString() ?? '',
      transferorNpwp: json['transferor_npwp']?.toString() ?? '',
      transfereeName: json['transferee_name']?.toString() ?? '',
      transfereeAddress: json['transferee_address']?.toString() ?? '',
      transfereeNpwp: json['transferee_npwp']?.toString() ?? '',
      hamlet: json['hamlet']?.toString() ?? '',
      village: json['village']?.toString() ?? '',
      landArea: toInt(json['land_area']),
      buildingArea: toInt(json['building_area']),
      book: json['book']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      taxYear: toInt(json['tax_year']),
      nop: json['nop']?.toString() ?? '',
      njop: toInt(json['njop']),
      bphtb: toInt(json['bphtb']),
      createdAt: toInt(json['created_at']),
      updatedAt: toInt(json['updated_at']),
    );
  }
}

class CertificateModel {
  final int id;
  final int transactionId;
  final String deedNumber;
  final int deedDate;
  final String deedType;
  final String rightType;
  final String rightNumber;
  final int createdAt;
  final int updatedAt;

  CertificateModel({
    required this.id,
    required this.transactionId,
    required this.deedNumber,
    required this.deedDate,
    required this.deedType,
    required this.rightType,
    required this.rightNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return CertificateModel(
      id: toInt(json['id']),
      transactionId: toInt(json['transaction_id']),
      deedNumber: json['deed_number']?.toString() ?? '',
      deedDate: toInt(json['deed_date']),
      deedType: json['deed_type']?.toString() ?? '',
      rightType: json['right_type']?.toString() ?? '',
      rightNumber: json['right_number']?.toString() ?? '',
      createdAt: toInt(json['created_at']),
      updatedAt: toInt(json['updated_at']),
    );
  }
}
