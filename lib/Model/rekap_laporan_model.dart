import 'dart:convert';

class RekapLaporanModel {
  final int totalBerkas;
  final int totalSelesai;
  final int totalProses;
  final double pemasukan;
  final List<ChartDataModel> chartData;

  const RekapLaporanModel({
    required this.totalBerkas,
    required this.totalSelesai,
    required this.totalProses,
    required this.pemasukan,
    required this.chartData,
  });

  factory RekapLaporanModel.fromJson(Map<String, dynamic> json) {
    final rawChart = json['chart_data'] as List? ?? [];
    return RekapLaporanModel(
      totalBerkas: (json['total_berkas'] ?? 0) as int,
      totalSelesai: (json['total_selesai'] ?? 0) as int,
      totalProses: (json['total_proses'] ?? 0) as int,
      pemasukan: ((json['pemasukan'] ?? 0) as num).toDouble(),
      chartData: rawChart
          .map((e) => ChartDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory RekapLaporanModel.fromPpatTransactionList(
    List<dynamic> rawList, {
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmountOverride,
  }) {
    final items = rawList.whereType<Map<String, dynamic>>().toList();

    final totalBerkas = items.length;

    final totalSelesai = items
        .where((e) => (e['status']?.toString() ?? '') == 'done')
        .length;
    final totalProses = totalBerkas - totalSelesai;

    double pemasukan;
    if (totalAmountOverride != null) {
      pemasukan = totalAmountOverride;
    } else {
      pemasukan = 0;
      for (var item in items) {
        if ((item['status']?.toString() ?? '') == 'done') {
          pemasukan += ((item['amount'] ?? 0) as num).toDouble();
        }
      }
    }

    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final Map<String, double> monthlyTotals = {};
    for (var item in items) {
      final created = _parseDDMMYYYY(item['created_at']?.toString());
      if (created == null) continue;
      final label = monthLabels[created.month - 1];
      final amount = ((item['amount'] ?? 0) as num).toDouble();
      monthlyTotals[label] = (monthlyTotals[label] ?? 0) + amount;
    }
    final chartData = monthLabels
        .where((label) => monthlyTotals.containsKey(label))
        .map(
          (label) => ChartDataModel(label: label, value: monthlyTotals[label]!),
        )
        .toList();

    return RekapLaporanModel(
      totalBerkas: totalBerkas,
      totalSelesai: totalSelesai,
      totalProses: totalProses,
      pemasukan: pemasukan,
      chartData: chartData,
    );
  }

  factory RekapLaporanModel.fromNotarisTransactionList(
    List<dynamic> rawList, {
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmountOverride,
  }) {
    var items = rawList.whereType<Map<String, dynamic>>().toList();

    if (startDate != null || endDate != null) {
      final start = startDate != null
          ? DateTime(startDate.year, startDate.month, startDate.day)
          : null;
      final end = endDate != null
          ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
          : null;

      items = items.where((item) {
        final created = _parseDDMMYYYY(item['created_at']?.toString());
        if (created == null) return false;
        if (start != null && created.isBefore(start)) return false;
        if (end != null && created.isAfter(end)) return false;
        return true;
      }).toList();
    }

    final totalBerkas = items.length;

    final totalSelesai = items
        .where((e) => (e['status']?.toString() ?? '') == 'done')
        .length;
    final totalProses = totalBerkas - totalSelesai;

    double pemasukan;
    if (totalAmountOverride != null) {
      pemasukan = totalAmountOverride;
    } else {
      pemasukan = 0;
      for (var item in items) {
        if ((item['status']?.toString() ?? '') == 'done') {
          pemasukan += ((item['amount'] ?? 0) as num).toDouble();
        }
      }
    }

    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final Map<String, double> monthlyTotals = {};
    for (var item in items) {
      final created = _parseDDMMYYYY(item['created_at']?.toString());
      if (created == null) continue;
      final label = monthLabels[created.month - 1];
      final amount = ((item['amount'] ?? 0) as num).toDouble();
      monthlyTotals[label] = (monthlyTotals[label] ?? 0) + amount;
    }
    final chartData = monthLabels
        .where((label) => monthlyTotals.containsKey(label))
        .map(
          (label) => ChartDataModel(label: label, value: monthlyTotals[label]!),
        )
        .toList();

    return RekapLaporanModel(
      totalBerkas: totalBerkas,
      totalSelesai: totalSelesai,
      totalProses: totalProses,
      pemasukan: pemasukan,
      chartData: chartData,
    );
  }

  static DateTime? _parseDDMMYYYY(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final dd = int.tryParse(parts[0]);
    final mm = int.tryParse(parts[1]);
    final yyyy = int.tryParse(parts[2]);
    if (dd == null || mm == null || yyyy == null) return null;
    return DateTime(yyyy, mm, dd);
  }
}

class ChartDataModel {
  final String label;
  final double value;

  const ChartDataModel({required this.label, required this.value});

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    return ChartDataModel(
      label: json['label']?.toString() ?? '',
      value: ((json['value'] ?? 0) as num).toDouble(),
    );
  }
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

Map<String, dynamic> _decodeNestedObject(dynamic raw) {
  if (raw == null) return {};
  if (raw is Map<String, dynamic>) return raw;
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
  }
  return {};
}

List<Map<String, dynamic>> _decodeNestedList(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    return raw.whereType<Map<String, dynamic>>().toList();
  }
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {}
  }
  return [];
}

class PpatAddressDetail {
  final String transferorName;
  final String transferorAddress;
  final String transferorNpwp;

  final String transfereeName;
  final String transfereeAddress;
  final String transfereeNpwp;

  final String hamlet;
  final String village;
  final double landArea;
  final double buildingArea;

  final String book;
  final String number;
  final int taxYear;

  final String nop;
  final double njop;
  final double bphtb;

  const PpatAddressDetail({
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
  });

  factory PpatAddressDetail.fromJson(Map<String, dynamic> json) {
    return PpatAddressDetail(
      transferorName: json['transferor_name']?.toString() ?? '',
      transferorAddress: json['transferor_address']?.toString() ?? '',
      transferorNpwp: json['transferor_npwp']?.toString() ?? '',
      transfereeName: json['transferee_name']?.toString() ?? '',
      transfereeAddress: json['transferee_address']?.toString() ?? '',
      transfereeNpwp: json['transferee_npwp']?.toString() ?? '',
      hamlet: json['hamlet']?.toString() ?? '',
      village: json['village']?.toString() ?? '',
      landArea: ((json['land_area'] ?? 0) as num).toDouble(),
      buildingArea: ((json['building_area'] ?? 0) as num).toDouble(),
      book: json['book']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      taxYear: _parseInt(json['tax_year']),
      nop: json['nop']?.toString() ?? '',
      njop: ((json['njop'] ?? 0) as num).toDouble(),
      bphtb: ((json['bphtb'] ?? 0) as num).toDouble(),
    );
  }

  static const empty = PpatAddressDetail(
    transferorName: '',
    transferorAddress: '',
    transferorNpwp: '',
    transfereeName: '',
    transfereeAddress: '',
    transfereeNpwp: '',
    hamlet: '',
    village: '',
    landArea: 0,
    buildingArea: 0,
    book: '',
    number: '',
    taxYear: 0,
    nop: '',
    njop: 0,
    bphtb: 0,
  );
}

class PpatCertificateDetail {
  final String deedNumber;
  final String deedDate;
  final String deedType;
  final String rightType;
  final String rightNumber;

  const PpatCertificateDetail({
    required this.deedNumber,
    required this.deedDate,
    required this.deedType,
    required this.rightType,
    required this.rightNumber,
  });

  factory PpatCertificateDetail.fromJson(Map<String, dynamic> json) {
    return PpatCertificateDetail(
      deedNumber: json['deed_number']?.toString() ?? '',
      deedDate: json['deed_date']?.toString() ?? '',
      deedType: json['deed_type']?.toString() ?? '',
      rightType: json['right_type']?.toString() ?? '',
      rightNumber: json['right_number']?.toString() ?? '',
    );
  }

  static const empty = PpatCertificateDetail(
    deedNumber: '',
    deedDate: '',
    deedType: '',
    rightType: '',
    rightNumber: '',
  );
}

class PpatClientDetail {
  final int id;
  final String publicId;
  final String name;
  final String phone;
  final String email;

  const PpatClientDetail({
    required this.id,
    required this.publicId,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory PpatClientDetail.fromJson(Map<String, dynamic> json) {
    return PpatClientDetail(
      id: _parseInt(json['id']),
      publicId: json['public_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  static const empty = PpatClientDetail(
    id: 0,
    publicId: '',
    name: '',
    phone: '',
    email: '',
  );
}

class PpatStaffDetail {
  final int id;
  final String staffName;
  final int instituteId;

  const PpatStaffDetail({
    required this.id,
    required this.staffName,
    required this.instituteId,
  });

  factory PpatStaffDetail.fromJson(Map<String, dynamic> json) {
    return PpatStaffDetail(
      id: _parseInt(json['id']),
      staffName: json['staff_name']?.toString() ?? '',
      instituteId: _parseInt(json['institute_id']),
    );
  }

  static const empty = PpatStaffDetail(id: 0, staffName: '', instituteId: 0);
}

class PpatTransactionDetail {
  final int id;
  final String status;
  final double amount;
  final String createdAt;
  final String notaryName;
  final String lifeStatus;

  final PpatAddressDetail address;
  final PpatCertificateDetail certificate;
  final PpatClientDetail client;
  final PpatStaffDetail staff;

  const PpatTransactionDetail({
    required this.id,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.notaryName,
    required this.lifeStatus,
    required this.address,
    required this.certificate,
    required this.client,
    required this.staff,
  });

  factory PpatTransactionDetail.fromJson(Map<String, dynamic> json) {
    final addressJson = _decodeNestedObject(json['address']);
    final certificateJson = _decodeNestedObject(json['certificate']);
    final clientJson = _decodeNestedObject(json['client']);
    final staffJson = _decodeNestedObject(json['staff']);

    return PpatTransactionDetail(
      id: _parseInt(json['id']),
      status: json['status']?.toString() ?? '',
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      createdAt: json['created_at']?.toString() ?? '',
      notaryName: json['notary_name']?.toString() ?? '',
      lifeStatus: json['life_status']?.toString() ?? '',
      address: addressJson.isNotEmpty
          ? PpatAddressDetail.fromJson(addressJson)
          : PpatAddressDetail.empty,
      certificate: certificateJson.isNotEmpty
          ? PpatCertificateDetail.fromJson(certificateJson)
          : PpatCertificateDetail.empty,
      client: clientJson.isNotEmpty
          ? PpatClientDetail.fromJson(clientJson)
          : PpatClientDetail.empty,
      staff: staffJson.isNotEmpty
          ? PpatStaffDetail.fromJson(staffJson)
          : PpatStaffDetail.empty,
    );
  }
}

class PpatReportResponse {
  static const String _listKey = 'data';

  final List<PpatTransactionDetail> items;
  final double totalAmount;
  final int totalOperation;

  const PpatReportResponse({
    required this.items,
    required this.totalAmount,
    required this.totalOperation,
  });

  factory PpatReportResponse.fromDecoded(dynamic decoded) {
    List<dynamic> rawList;
    double totalAmount = 0;
    int totalOperation = 0;

    if (decoded is Map<String, dynamic>) {
      final rawFromKey = decoded[_listKey];
      rawList = rawFromKey is List ? rawFromKey : <dynamic>[];

      totalAmount = ((decoded['total_amount'] ?? 0) as num).toDouble();
      totalOperation = _parseInt(decoded['total_operation']);
    } else if (decoded is List) {
      rawList = decoded;
    } else {
      rawList = <dynamic>[];
    }

    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => PpatTransactionDetail.fromJson(e))
        .toList();

    return PpatReportResponse(
      items: items,
      totalAmount: totalAmount,
      totalOperation: totalOperation,
    );
  }

  static List<Map<String, dynamic>> rawItemsFrom(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final rawFromKey = decoded[_listKey];
      if (rawFromKey is List) {
        return rawFromKey.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } else if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}

class NotarisPenghadapDetail {
  final String publicId;
  final String name;
  final String title;
  final int orderNumber;

  const NotarisPenghadapDetail({
    required this.publicId,
    required this.name,
    required this.title,
    required this.orderNumber,
  });

  factory NotarisPenghadapDetail.fromJson(Map<String, dynamic> json) {
    return NotarisPenghadapDetail(
      publicId: json['public_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      orderNumber: _parseInt(json['order_number']),
    );
  }
}

class NotarisTransactionDetail {
  final int id;
  final String status;
  final double amount;
  final String createdAt;

  final String? aktaDate;
  final String caseName;
  final String aktaNature;
  final String lifeStatus;
  final List<NotarisPenghadapDetail> penghadap;

  const NotarisTransactionDetail({
    required this.id,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.aktaDate,
    required this.caseName,
    required this.aktaNature,
    required this.lifeStatus,
    required this.penghadap,
  });

  factory NotarisTransactionDetail.fromJson(Map<String, dynamic> json) {
    final penghadapRaw = _decodeNestedList(json['penghadap']);

    final rawAktaDate = json['akta_date'];
    final aktaDateStr = (rawAktaDate == null)
        ? null
        : rawAktaDate.toString().trim();

    return NotarisTransactionDetail(
      id: _parseInt(json['id']),
      status: json['status']?.toString() ?? '',
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      createdAt: json['created_at']?.toString() ?? '',
      aktaDate: (aktaDateStr == null || aktaDateStr.isEmpty)
          ? null
          : aktaDateStr,
      caseName: json['case_name']?.toString() ?? '',
      aktaNature: json['akta_nature']?.toString() ?? '',
      lifeStatus: json['life_status']?.toString() ?? '',
      penghadap:
          (penghadapRaw..sort(
                (a, b) => _parseInt(
                  a['order_number'],
                ).compareTo(_parseInt(b['order_number'])),
              ))
              .map((e) => NotarisPenghadapDetail.fromJson(e))
              .toList(),
    );
  }

  String get sifatAktaDisplay =>
      aktaNature.trim().isNotEmpty ? aktaNature.trim() : caseName.trim();
}

class NotarisReportResponse {
  static const String _listKey = 'data';

  final List<NotarisTransactionDetail> items;
  final double totalAmount;
  final int totalOperation;

  const NotarisReportResponse({
    required this.items,
    required this.totalAmount,
    required this.totalOperation,
  });

  factory NotarisReportResponse.fromDecoded(dynamic decoded) {
    List<dynamic> rawList;
    double totalAmount = 0;
    int totalOperation = 0;

    if (decoded is Map<String, dynamic>) {
      final rawFromKey = decoded[_listKey];
      rawList = rawFromKey is List ? rawFromKey : <dynamic>[];

      totalAmount = ((decoded['total_amount'] ?? 0) as num).toDouble();
      totalOperation = _parseInt(decoded['total_operation']);
    } else if (decoded is List) {
      rawList = decoded;
    } else {
      rawList = <dynamic>[];
    }

    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => NotarisTransactionDetail.fromJson(e))
        .toList();

    return NotarisReportResponse(
      items: items,
      totalAmount: totalAmount,
      totalOperation: totalOperation,
    );
  }

  static List<Map<String, dynamic>> rawItemsFrom(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final rawFromKey = decoded[_listKey];
      if (rawFromKey is List) {
        return rawFromKey.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } else if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
