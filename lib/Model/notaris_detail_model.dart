class NotarisDetailModel {
  final int id;
  final int clientId;
  final int staffId;
  final String lifeStatus;
  final String description;
  final String status;
  final String? paymentStatus;
  final int? titipBiayaInput;

  // ✅ nominal total biaya layanan dari backend
  final int amount;

  // CHANGED: backend udah nggak punya relasi "case" (caseId/caseData
  // dihapus). Sekarang jenis pekerjaan itu array of string.
  final List<String> transactionTypes;
  final String aktaNature;
  final String aktaDate;

  final int createdAt;
  final int updatedAt;
  final int monthlyNumber;

  final NotarisClientModel client;
  final NotarisStaffModel staff;
  final NotarisDocumentTransactionModel? documentTransaction;

  // NEW: daftar penghadap, sesuai response backend
  final List<NotarisPenghadapModel> penghadap;

  NotarisDetailModel({
    required this.id,
    required this.clientId,
    required this.staffId,
    required this.lifeStatus,
    required this.description,
    required this.status,
    this.paymentStatus,
    this.titipBiayaInput,
    required this.amount,
    required this.transactionTypes,
    required this.aktaNature,
    required this.aktaDate,
    required this.createdAt,
    required this.updatedAt,
    required this.monthlyNumber,
    required this.client,
    required this.staff,
    this.documentTransaction,
    required this.penghadap,
  });

  // helper parse int dari berbagai kemungkinan tipe (int/String/double/null)
  static int _parseInt(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    if (raw is String) {
      return int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }

  factory NotarisDetailModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawTitip = json['titip_biaya_input'];
    int? titipBiayaInput;
    if (rawTitip is int) {
      titipBiayaInput = rawTitip;
    } else if (rawTitip is String) {
      titipBiayaInput = int.tryParse(rawTitip.replaceAll(RegExp(r'[^0-9]'), ''));
    }

    // Coba beberapa kemungkinan nama key dari backend buat "amount".
    final dynamic rawAmount = json['amount'] ??
        json['total_biaya'] ??
        json['totalBiaya'] ??
        json['service_amount'];

    // CHANGED: transaction_types (array of string), ganti dari
    // json['case'] yang sudah tidak ada.
    final rawTypes = json['transaction_types'];
    final types = (rawTypes is List)
        ? rawTypes.map((e) => e.toString()).toList()
        : <String>[];

    final rawPenghadap = json['penghadap'];
    final penghadapList = (rawPenghadap is List)
        ? rawPenghadap
            .whereType<Map<String, dynamic>>()
            .map((e) => NotarisPenghadapModel.fromJson(e))
            .toList()
        : <NotarisPenghadapModel>[];

    return NotarisDetailModel(
      id: json['id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      staffId: json['staff_id'] ?? 0,
      lifeStatus: json['life_status'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status']?.toString(),
      titipBiayaInput: titipBiayaInput,
      amount: _parseInt(rawAmount),
      transactionTypes: types,
      aktaNature: json['akta_nature'] ?? '',
      aktaDate: json['akta_date'] ?? '',
      createdAt: json['created_at'] ?? 0,
      updatedAt: json['updated_at'] ?? 0,
      monthlyNumber: json['monthly_number'] ?? 0,
      client: NotarisClientModel.fromJson(json['client'] ?? {}),
      staff: NotarisStaffModel.fromJson(json['staff'] ?? {}),
      documentTransaction: json['document_transaction'] != null
          ? NotarisDocumentTransactionModel.fromJson(
              json['document_transaction'],
            )
          : null,
      penghadap: penghadapList,
    );
  }

  get caseData => null;
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
      id: json['ID'] ?? 0,
      staffName: json['StaffName'] ?? '',
      instituteId: json['InstituteID'] ?? 0,
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
          .whereType<Map<String, dynamic>>()
          .map((e) => NotarisDocMetadata.fromJson(e))
          .toList(),
      type: json['type'] ?? '',
    );
  }
}

class NotarisDocMetadata {
  final String name;
  final String url;
  final String type;
  final int size;

  NotarisDocMetadata({
    required this.name,
    required this.url,
    required this.type,
    required this.size,
  });

  String get label => name;

  factory NotarisDocMetadata.fromJson(Map<String, dynamic> json) {
    return NotarisDocMetadata(
      name: json['name'] ?? json['label'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] is int
          ? json['size']
          : int.tryParse(json['size']?.toString() ?? '') ?? 0,
    );
  }
}

class NotarisPenghadapModel {
  final int id;
  final String publicId;
  final String name;
  final int orderNumber;
  final String title;

  NotarisPenghadapModel({
    required this.id,
    required this.publicId,
    required this.name,
    required this.orderNumber,
    required this.title,
  });

  factory NotarisPenghadapModel.fromJson(Map<String, dynamic> json) {
    return NotarisPenghadapModel(
      id: json['ID'] ?? 0,
      publicId: json['PublicID'] ?? '',
      name: json['Name'] ?? '',
      orderNumber: json['OrderNumber'] ?? 0,
      title: json['Title'] ?? '',
    );
  }
}