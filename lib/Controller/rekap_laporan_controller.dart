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

  JenisLayanan _jenisLayanan = JenisLayanan.notaris;

  // ✅ default: awal bulan ini s.d. hari ini (bukan hardcode 2021-2022)
  late DateTime _tanggalAwal = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime _tanggalAkhir = DateTime.now();

  bool _isLoading = false;

  // Data hasil fetch dari server. Null selama belum berhasil fetch.
  RekapLaporanModel? _ppatFetchedData;
  RekapLaporanModel? _notarisFetchedData;

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

  // ============================================================
  // FETCH LAPORAN PPAT DARI /api/v1/generate/report/PPAT
  // ============================================================
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

      final uri = Uri.parse('$baseUrl/api/v1/generate/report/PPAT')
          .replace(queryParameters: queryParams);

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
        });
        return;
      }

      final rawList = decoded as List<dynamic>;
      print("📦 [LAPORAN PPAT] Total item mentah dari API: ${rawList.length}");

      final model = RekapLaporanModel.fromPpatTransactionList(
        rawList,
        startDate: _tanggalAwal,
        endDate: _tanggalAkhir,
      );

      print(
        "✅ [LAPORAN PPAT] Total Berkas: ${model.totalBerkas}, "
        "Selesai: ${model.totalSelesai}, Proses: ${model.totalProses}, "
        "Pemasukan: ${model.pemasukan}",
      );

      setState(() => _ppatFetchedData = model);
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

  // ============================================================
  // FETCH LAPORAN NOTARIS DARI /api/v1/generate/report/Notaris
  // 🔧 ASUMSI: struktur response sama dengan PPAT (array transaksi
  // mentah dengan field amount, case_name, status, created_at, dst).
  // Kalau ternyata beda, kirim contoh response-nya biar disesuaikan.
  // ============================================================
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

      final uri = Uri.parse('$baseUrl/api/v1/generate/report/Notary')
          .replace(queryParameters: queryParams);

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
        print("⚠️ [LAPORAN NOTARIS] Response null — tidak ada data dari server.");
        setState(() {
          _notarisFetchedData = const RekapLaporanModel(
            totalBerkas: 0,
            totalSelesai: 0,
            totalProses: 0,
            pemasukan: 0,
            chartData: [],
          );
        });
        return;
      }

      final rawList = decoded as List<dynamic>;
      print("📦 [LAPORAN NOTARIS] Total item mentah dari API: ${rawList.length}");

      final model = RekapLaporanModel.fromNotarisTransactionList(
        rawList,
        startDate: _tanggalAwal,
        endDate: _tanggalAkhir,
      );

      print(
        "✅ [LAPORAN NOTARIS] Total Berkas: ${model.totalBerkas}, "
        "Selesai: ${model.totalSelesai}, Proses: ${model.totalProses}, "
        "Pemasukan: ${model.pemasukan}",
      );

      setState(() => _notarisFetchedData = model);
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

  // ============================================================
  // EXPORT PDF — generate dari data yang lagi ditampilkan
  // ============================================================
  Future<void> _onExportPdf() async {
    final data = _currentData;
    final jenisLabel =
        _jenisLayanan == JenisLayanan.notaris ? "Notaris" : "PPAT";

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Laporan $jenisLabel",
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Periode: ${_formatDateForApi(_tanggalAwal)} - ${_formatDateForApi(_tanggalAkhir)}",
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  _pdfRow("Total Berkas", "${data.totalBerkas}"),
                  _pdfRow("Total Selesai", "${data.totalSelesai}"),
                  _pdfRow("Total Proses", "${data.totalProses}"),
                  _pdfRow("Pemasukan", "Rp ${data.pemasukan.toStringAsFixed(0)}"),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Detail Bulanan",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  pw.TableRow(children: [
                    _pdfCellHeader("Bulan"),
                    _pdfCellHeader("Nilai"),
                  ]),
                  ...data.chartData.map(
                    (e) => pw.TableRow(children: [
                      _pdfCell(e.label),
                      _pdfCell(e.value.toStringAsFixed(0)),
                    ]),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  pw.TableRow _pdfRow(String label, String value) {
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(label),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(value),
      ),
    ]);
  }

  pw.Widget _pdfCellHeader(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      );

  pw.Widget _pdfCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text),
      );

  // ✅ Format DD/MM/YYYY sesuai layout Go "02/01/2006"
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}