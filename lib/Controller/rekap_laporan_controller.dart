import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notaris_app/config/base_url.dart';
import 'package:notaris_app/Model/rekap_laporan_model.dart';
import 'package:notaris_app/Pages/rekap_laporan_page.dart';
import 'package:notaris_app/Widget/Laporan/jenis_layanan_toggle.dart';

class RekapLaporanController extends StatefulWidget {
  const RekapLaporanController({super.key});

  @override
  State<RekapLaporanController> createState() => _RekapLaporanControllerState();
}

class _RekapLaporanControllerState extends State<RekapLaporanController> {
  static const String baseUrl = "${ApiConfig.baseUrl}";

  static const List<String> _bulanIndonesia = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _bulanRomawi = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI',
    'XII',
  ];
  static const String _notaryOfficeCode = "NOT.WLN";
  static const String _notaryLocationLabel = "Notaris di Kabupaten Karanganyar";

  JenisLayanan _jenisLayanan = JenisLayanan.notaris;

  late DateTime _tanggalAwal = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  late DateTime _tanggalAkhir = DateTime.now();

  bool _isLoading = false;

  RekapLaporanModel? _ppatFetchedData;
  RekapLaporanModel? _notarisFetchedData;

  List<PpatTransactionDetail> _ppatDetailItems = [];

  List<NotarisTransactionDetail> _notarisDetailItems = [];

  RekapLaporanModel get _currentData {
    final fetched = _jenisLayanan == JenisLayanan.notaris
        ? _notarisFetchedData
        : _ppatFetchedData;

    return fetched ??
        const RekapLaporanModel(
          totalBerkas: 0,
          totalSelesai: 0,
          totalProses: 0,
          pemasukan: 0,
          chartData: [],
        );
  }

  @override
  void initState() {
    super.initState();
    _fetchDataForCurrentJenis();
  }

  void _fetchDataForCurrentJenis() {
    if (_jenisLayanan == JenisLayanan.ppat) {
      _fetchPpatReport();
    } else {
      _fetchNotarisReport();
    }
  }

  Future<void> _fetchPpatReport() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      if (token.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final queryParams = {
        'start_date': _formatDateForApi(_tanggalAwal),
        'end_date': _formatDateForApi(_tanggalAkhir),
      };

      final uri = Uri.parse(
        '$baseUrl/api/v1/generate/report/PPAT',
      ).replace(queryParameters: queryParams);

      print("🌐 [LAPORAN PPAT] Target URL   : $uri");
      print("🌐 [LAPORAN PPAT] Query Params : $queryParams");

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print("🚀 [LAPORAN PPAT] Status Code  : ${response.statusCode}");
      print("🚀 [LAPORAN PPAT] Response mentah: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Server Error (${response.statusCode}): ${response.body}",
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded == null) {
        print("⚠️ [LAPORAN PPAT] Response null — tidak ada data dari server.");
        setState(() {
          _ppatFetchedData = const RekapLaporanModel(
            totalBerkas: 0,
            totalSelesai: 0,
            totalProses: 0,
            pemasukan: 0,
            chartData: [],
          );
          _ppatDetailItems = [];
        });
        return;
      }

      final rawList = PpatReportResponse.rawItemsFrom(decoded);
      print("📦 [LAPORAN PPAT] Total item mentah dari API: ${rawList.length}");

      // NEW: ambil total_amount langsung dari root response, biar
      // "Pemasukan" akurat sesuai perhitungan backend, bukan hasil
      // hitung ulang manual di Flutter yang gampang meleset.
      final double? totalAmountFromApi = (decoded is Map &&
              decoded['total_amount'] != null)
          ? ((decoded['total_amount'] as num).toDouble())
          : null;

      final model = RekapLaporanModel.fromPpatTransactionList(
        rawList,
        startDate: _tanggalAwal,
        endDate: _tanggalAkhir,
        totalAmountOverride: totalAmountFromApi,
      );

      final detailedResponse = PpatReportResponse.fromDecoded(decoded);

      print(
        "✅ [LAPORAN PPAT] Total Berkas: ${model.totalBerkas}, "
        "Selesai: ${model.totalSelesai}, Proses: ${model.totalProses}, "
        "Pemasukan: ${model.pemasukan}, DetailRows: ${detailedResponse.items.length}",
      );

      setState(() {
        _ppatFetchedData = model;
        _ppatDetailItems = detailedResponse.items;
      });
    } catch (e) {
      print("❌ [LAPORAN PPAT ERROR]: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNotarisReport() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      if (token.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final queryParams = {
        'start_date': _formatDateForApi(_tanggalAwal),
        'end_date': _formatDateForApi(_tanggalAkhir),
      };

      final uri = Uri.parse(
        '$baseUrl/api/v1/generate/report/Notary',
      ).replace(queryParameters: queryParams);

      print("🌐 [LAPORAN NOTARIS] Target URL   : $uri");
      print("🌐 [LAPORAN NOTARIS] Query Params : $queryParams");

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print("🚀 [LAPORAN NOTARIS] Status Code  : ${response.statusCode}");
      print("🚀 [LAPORAN NOTARIS] Response mentah: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Server Error (${response.statusCode}): ${response.body}",
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded == null) {
        print(
          "⚠️ [LAPORAN NOTARIS] Response null — tidak ada data dari server.",
        );
        setState(() {
          _notarisFetchedData = const RekapLaporanModel(
            totalBerkas: 0,
            totalSelesai: 0,
            totalProses: 0,
            pemasukan: 0,
            chartData: [],
          );
          _notarisDetailItems = [];
        });
        return;
      }

      final rawList = NotarisReportResponse.rawItemsFrom(decoded);
      print(
        "📦 [LAPORAN NOTARIS] Total item mentah dari API: ${rawList.length}",
      );

      // NEW: sama seperti PPAT — pakai total_amount dari root
      // response backend buat "Pemasukan".
      final double? totalAmountFromApi = (decoded is Map &&
              decoded['total_amount'] != null)
          ? ((decoded['total_amount'] as num).toDouble())
          : null;

      final model = RekapLaporanModel.fromNotarisTransactionList(
        rawList,
        startDate: _tanggalAwal,
        endDate: _tanggalAkhir,
        totalAmountOverride: totalAmountFromApi,
      );

      final detailedResponse = NotarisReportResponse.fromDecoded(decoded);

      print(
        "✅ [LAPORAN NOTARIS] Total Berkas: ${model.totalBerkas}, "
        "Selesai: ${model.totalSelesai}, Proses: ${model.totalProses}, "
        "Pemasukan: ${model.pemasukan}, DetailRows: ${detailedResponse.items.length}",
      );

      setState(() {
        _notarisFetchedData = model;
        _notarisDetailItems = detailedResponse.items;
      });
    } catch (e) {
      print("❌ [LAPORAN NOTARIS ERROR]: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onJenisLayananChanged(JenisLayanan val) {
    setState(() => _jenisLayanan = val);
    _fetchDataForCurrentJenis();
  }

  Future<void> _onTanggalAwalTap() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalAwal,
      firstDate: DateTime(2000),
      lastDate: _tanggalAkhir,
    );
    if (picked != null) {
      setState(() => _tanggalAwal = picked);
      _fetchDataForCurrentJenis();
    }
  }

  Future<void> _onTanggalAkhirTap() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalAkhir,
      firstDate: _tanggalAwal,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _tanggalAkhir = picked);
      _fetchDataForCurrentJenis();
    }
  }

  Future<void> _onExportPdf() async {
    if (_jenisLayanan == JenisLayanan.ppat) {
      await _onExportPpatDetailedPdf();
    } else {
      await _onExportNotarisDetailedPdf();
    }
  }

  Future<void> _onExportPpatDetailedPdf() async {
    final doc = pw.Document();
    final bulanLabel = _bulanIndonesia[_tanggalAwal.month - 1];

    final validItems = _ppatDetailItems.where((item) {
      final hasCertificate = item.certificate.deedNumber.trim().isNotEmpty;
      final hasParties =
          item.address.transferorName.trim().isNotEmpty ||
          item.address.transfereeName.trim().isNotEmpty;
      return hasCertificate || hasParties;
    }).toList();

    print(
      "🖨️ [EXPORT PPAT] Total item dari API: ${_ppatDetailItems.length}, "
      "setelah filter (buang yang kosong): ${validItems.length}",
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        header: (context) {
          if (context.pageNumber != 1) return pw.SizedBox();
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Laporan PPAT",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "Periode: ${_formatDateForApi(_tanggalAwal)} - ${_formatDateForApi(_tanggalAkhir)}",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                color: PdfColors.black,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
                child: pw.Text(
                  "BULAN : ${bulanLabel.toUpperCase()}",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              _buildPpatTableHeader(),
            ],
          );
        },
        build: (context) {
          return [
            for (int i = 0; i < validItems.length; i++)
              _buildPpatDataRow(i + 1, validItems[i], isEven: i % 2 == 0),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  pw.Widget _buildPpatTableHeader() {
    return pw.Row(
      children: [
        _headerCellMerged("NO", flex: 1),
        _headerCellGroup(
          "NO TGL & JENIS AKTA",
          ["NO/TGL", "JENIS AKTA"],
          [2, 2],
        ),
        _headerCellMerged("JENIS NOMOR\nHAK MILIK", flex: 3),
        _headerCellGroup(
          "NAMA ALAMAT & NPWP",
          ["YANG MENGALIHKAN HAK", "YANG MENERIMA HAK"],
          [4, 4],
        ),
        _headerCellGroup("LETAK TANAH &\nBANGUNAN", ["DUSUN/DESA"], [3]),
        _headerCellGroup("LUAS (M2)", ["T", "B"], [1, 1]),
        _headerCellGroup("NO & TAHUN\nSPPT PBB", ["NOP", "NJOP"], [3, 2]),
        _headerCellMerged("SSPD/\nBPHTB (Rp)", flex: 2),
        _headerCellMerged("NOTARIS", flex: 3),
      ],
    );
  }

  pw.Widget _headerCellMerged(String text, {required int flex}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: 46,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey300,
          border: pw.Border.all(width: 0.5),
        ),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
  }

  pw.Widget _headerCellGroup(
    String groupLabel,
    List<String> subLabels,
    List<int> subFlex,
  ) {
    final totalFlex = subFlex.fold<int>(0, (a, b) => a + b);
    return pw.Expanded(
      flex: totalFlex,
      child: pw.Column(
        children: [
          pw.Container(
            height: 22,
            width: double.infinity,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border.all(width: 0.5),
            ),
            child: pw.Text(
              groupLabel,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 6.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Row(
            children: List.generate(subLabels.length, (i) {
              return pw.Expanded(
                flex: subFlex[i],
                child: pw.Container(
                  height: 24,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border.all(width: 0.5),
                  ),
                  child: pw.Text(
                    subLabels[i],
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 6.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPpatDataRow(
    int no,
    PpatTransactionDetail item, {
    required bool isEven,
  }) {
    final addr = item.address;
    final cert = item.certificate;
    final rowColor = isEven ? PdfColors.white : PdfColors.grey100;

    final noText = "$no";
    final deedText = _deedText(cert);
    final rightTypeText = _orDash(cert.deedType);
    final rightText = _rightText(cert);
    final transferorText = _partyText(
      addr.transferorName,
      addr.transferorAddress,
      addr.transferorNpwp,
    );
    final transfereeText = _partyText(
      addr.transfereeName,
      addr.transfereeAddress,
      addr.transfereeNpwp,
    );
    final letakText = _letakText(addr);
    final landAreaText = addr.landArea > 0 ? _formatAngka(addr.landArea) : "-";
    final buildingAreaText = addr.buildingArea > 0
        ? _formatAngka(addr.buildingArea)
        : "-";
    final nopText = _orDash(addr.nop);
    final njopText = addr.njop > 0 ? _formatRibuan(addr.njop) : "-";
    final bphtbText = addr.bphtb > 0 ? _formatRibuan(addr.bphtb) : "-";
    final notaryText = _orDash(item.notaryName);
    final allTexts = [
      noText,
      deedText,
      rightTypeText,
      rightText,
      transferorText,
      transfereeText,
      letakText,
      landAreaText,
      buildingAreaText,
      nopText,
      njopText,
      bphtbText,
      notaryText,
    ];
    final maxLines = allTexts
        .map((t) => '\n'.allMatches(t).length + 1)
        .reduce((a, b) => a > b ? a : b);
    const lineHeight = 8.0;
    const verticalPadding = 8.0;
    final rowHeight = (maxLines * lineHeight) + verticalPadding;

    return pw.Row(
      children: [
        _dataCell(
          noText,
          flex: 1,
          color: rowColor,
          align: pw.TextAlign.center,
          height: rowHeight,
        ),
        _dataCell(deedText, flex: 2, color: rowColor, height: rowHeight),
        _dataCell(rightTypeText, flex: 2, color: rowColor, height: rowHeight),
        _dataCell(rightText, flex: 3, color: rowColor, height: rowHeight),
        _dataCell(transferorText, flex: 4, color: rowColor, height: rowHeight),
        _dataCell(transfereeText, flex: 4, color: rowColor, height: rowHeight),
        _dataCell(letakText, flex: 3, color: rowColor, height: rowHeight),
        _dataCell(
          landAreaText,
          flex: 1,
          color: rowColor,
          align: pw.TextAlign.center,
          height: rowHeight,
        ),
        _dataCell(
          buildingAreaText,
          flex: 1,
          color: rowColor,
          align: pw.TextAlign.center,
          height: rowHeight,
        ),
        _dataCell(nopText, flex: 3, color: rowColor, height: rowHeight),
        _dataCell(
          njopText,
          flex: 2,
          color: rowColor,
          align: pw.TextAlign.right,
          height: rowHeight,
        ),
        _dataCell(
          bphtbText,
          flex: 2,
          color: rowColor,
          align: pw.TextAlign.right,
          height: rowHeight,
        ),
        _dataCell(notaryText, flex: 3, color: rowColor, height: rowHeight),
      ],
    );
  }

  pw.Widget _dataCell(
    String text, {
    required int flex,
    required double height,
    PdfColor color = PdfColors.white,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    final alignment = align == pw.TextAlign.center
        ? pw.Alignment.center
        : align == pw.TextAlign.right
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft;

    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: height,
        alignment: alignment,
        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        decoration: pw.BoxDecoration(
          color: color,
          border: pw.Border.all(width: 0.5, color: PdfColors.grey600),
        ),
        child: pw.Text(
          text,
          textAlign: align,
          style: const pw.TextStyle(fontSize: 6.5),
        ),
      ),
    );
  }

  String _orDash(String value) => value.trim().isEmpty ? "-" : value.trim();
  String _partyText(String name, String address, String npwp) {
    final lines = <String>[];
    if (name.trim().isNotEmpty) lines.add(name.trim());
    if (address.trim().isNotEmpty) lines.add(address.trim());
    if (npwp.trim().isNotEmpty) lines.add("NPWP: ${npwp.trim()}");
    return lines.isEmpty ? "-" : lines.join("\n");
  }

  String _deedText(PpatCertificateDetail cert) {
    final lines = <String>[];
    if (cert.deedNumber.trim().isNotEmpty) lines.add(cert.deedNumber.trim());
    if (cert.deedDate.trim().isNotEmpty) lines.add(cert.deedDate.trim());
    return lines.isEmpty ? "-" : lines.join("\n");
  }

  String _rightText(PpatCertificateDetail cert) {
    final lines = <String>[];
    if (cert.rightType.trim().isNotEmpty) lines.add(cert.rightType.trim());
    if (cert.rightNumber.trim().isNotEmpty) lines.add(cert.rightNumber.trim());
    return lines.isEmpty ? "-" : lines.join("\n");
  }

  String _letakText(PpatAddressDetail addr) {
    final lines = <String>[];
    if (addr.hamlet.trim().isNotEmpty) lines.add(addr.hamlet.trim());
    if (addr.village.trim().isNotEmpty) lines.add(addr.village.trim());
    return lines.isEmpty ? "-" : lines.join("\n");
  }

  String _formatAngka(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  String _formatRibuan(num value) {
    final str = value.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Future<void> _onExportNotarisDetailedPdf() async {
    final doc = pw.Document();

    DateTime? parseTgl(String? s) {
      if (s == null || s.trim().isEmpty) return null;
      final parts = s.split('/');
      if (parts.length != 3) return null;
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d == null || m == null || y == null) return null;
      return DateTime(y, m, d);
    }

    final validItems = _notarisDetailItems
        .where((item) => item.aktaDate != null)
        .toList();

    validItems.sort((a, b) {
      final da = parseTgl(a.aktaDate) ?? DateTime(0);
      final db = parseTgl(b.aktaDate) ?? DateTime(0);
      return da.compareTo(db);
    });

    print(
      "🖨️ [EXPORT NOTARIS] Total item dari API: ${_notarisDetailItems.length}, "
      "setelah filter (hanya yang punya tanggal akta): ${validItems.length}",
    );

    int monthlyCounter = 0;
    int? lastMonthKey;

    const int noUrutStart = 1;

    final periodDate = _tanggalAkhir;
    final nomorSurat =
        "${validItems.length}/$_notaryOfficeCode/${_bulanRomawi[periodDate.month - 1]}/${periodDate.year}";
    final tanggalSurat =
        "${periodDate.day.toString().padLeft(2, '0')} ${_bulanIndonesia[periodDate.month - 1]} ${periodDate.year}";

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) {
          if (context.pageNumber != 1) return pw.SizedBox();
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 60,
                            child: pw.Text(
                              "Nomor",
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            ": $nomorSurat",
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 60,
                            child: pw.Text(
                              "Tanggal",
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Text(
                            ": $tanggalSurat",
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  "SALINAN DAFTAR AKTA",
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              _buildNotarisTableHeader(),
            ],
          );
        },
        build: (context) {
          final rows = <pw.Widget>[];
          for (int i = 0; i < validItems.length; i++) {
            final item = validItems[i];
            final tgl = parseTgl(item.aktaDate);
            final monthKey = tgl != null ? (tgl.year * 100 + tgl.month) : null;

            if (monthKey != null && monthKey != lastMonthKey) {
              monthlyCounter = 0;
              lastMonthKey = monthKey;
            }
            monthlyCounter++;

            rows.add(
              _buildNotarisDataRow(
                noUrut: noUrutStart + i,
                nomorBulanan: monthlyCounter,
                item: item,
              ),
            );
          }
          return rows;
        },
        footer: (context) {
          if (context.pageNumber != context.pagesCount) return pw.SizedBox();
          return pw.Padding(
            padding: const pw.EdgeInsets.only(top: 24),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                _notaryLocationLabel,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  pw.Widget _buildNotarisTableHeader() {
    return pw.Row(
      children: [
        _notarisHeaderCell("NO.\nURUT", flex: 2),
        _notarisHeaderCell("NOMOR\nBULANAN", flex: 3),
        _notarisHeaderCell("TANGGAL AKTA", flex: 3),
        _notarisHeaderCell("SIFAT AKTA", flex: 5),
        _notarisHeaderCell(
          "NAMA NAMA PENGHADAP DAN/ATAU YANG DIWAKILI/KUASA",
          flex: 8,
        ),
      ],
    );
  }

  pw.Widget _notarisHeaderCell(String text, {required int flex}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: 40,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(horizontal: 4),
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF5C4A3A)),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildNotarisDataRow({
    required int noUrut,
    required int nomorBulanan,
    required NotarisTransactionDetail item,
  }) {
    final noUrutText = "$noUrut";
    final nomorBulananText = nomorBulanan.toString().padLeft(2, '0');
    final tanggalAktaText = (item.aktaDate ?? '').replaceAll('/', '-');
    final sifatAktaText = item.sifatAktaDisplay.isEmpty
        ? "-"
        : item.sifatAktaDisplay.toUpperCase();
    final penghadapText = _penghadapText(item.penghadap);

    final allTexts = [
      noUrutText,
      nomorBulananText,
      tanggalAktaText,
      sifatAktaText,
      penghadapText,
    ];
    final maxLines = allTexts
        .map((t) => '\n'.allMatches(t).length + 1)
        .reduce((a, b) => a > b ? a : b);
    const lineHeight = 11.0;
    const verticalPadding = 12.0;
    final rowHeight = (maxLines * lineHeight) + verticalPadding;

    return pw.Row(
      children: [
        _notarisDataCell(
          noUrutText,
          flex: 2,
          height: rowHeight,
          align: pw.TextAlign.center,
        ),
        _notarisDataCell(
          nomorBulananText,
          flex: 3,
          height: rowHeight,
          align: pw.TextAlign.center,
        ),
        _notarisDataCell(
          tanggalAktaText,
          flex: 3,
          height: rowHeight,
          align: pw.TextAlign.center,
        ),
        _notarisDataCell(sifatAktaText, flex: 5, height: rowHeight),
        _notarisDataCell(penghadapText, flex: 8, height: rowHeight),
      ],
    );
  }

  pw.Widget _notarisDataCell(
    String text, {
    required int flex,
    required double height,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    final alignment = align == pw.TextAlign.center
        ? pw.Alignment.center
        : pw.Alignment.centerLeft;

    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: height,
        alignment: alignment,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
          ),
        ),
        child: pw.Text(
          text,
          textAlign: align,
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
    );
  }

  String _penghadapText(List<NotarisPenghadapDetail> list) {
    if (list.isEmpty) return "-";
    final lines = <String>[];
    for (var i = 0; i < list.length; i++) {
      final p = list[i];
      final name = p.name.trim();
      if (name.isEmpty) continue;
      final titlePart = p.title.trim().isNotEmpty ? "${p.title.trim()} " : "";
      lines.add("${i + 1}.$titlePart${name.toUpperCase()};");
    }
    return lines.isEmpty ? "-" : lines.join("\n");
  }

  String _formatDateForApi(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RekapLaporanPage(
          data: _currentData,
          tanggalAwal: _formatDateForApi(_tanggalAwal),
          tanggalAkhir: _formatDateForApi(_tanggalAkhir),
          jenisLayanan: _jenisLayanan,
          onJenisLayananChanged: _onJenisLayananChanged,
          onTanggalAwalTap: _onTanggalAwalTap,
          onTanggalAkhirTap: _onTanggalAkhirTap,
          onExportPdf: _onExportPdf,
          onBack: () => Navigator.pop(context),
          currentIndex: 0,
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.15),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}