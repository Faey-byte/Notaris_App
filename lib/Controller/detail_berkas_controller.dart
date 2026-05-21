import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:notaris_app/Model/Ppat_Model.dart';
import 'package:notaris_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

class DokumenModel {
  final String nama;
  final String url;
  final String tanggal;
  final bool isImage;

  DokumenModel({
    required this.nama,
    required this.url,
    required this.tanggal,
    required this.isImage,
  });
}

class DetailBerkasController extends GetxController {
  final BerkasModel data;
  DetailBerkasController(this.data);

  final String apiUrl =
      'https://reef-counsel-answer-responding.trycloudflare.com/api/v1/show-detailing-byClient';
  final String updateStatusUrl =
      'https://reef-counsel-answer-responding.trycloudflare.com/api/v1/update-status';

  var isLoading = false.obs;

  var publicId = "".obs;
  var alamat = "Tidak ada lokasi".obs;
  var totalBiaya = "Rp 0".obs;
  var statusPajak = "Belum Bayar".obs;
  var statusPekerjaan = "PENDING".obs;
  var namaStaff = "Sistem Otomatis".obs;

  var dokumenList = <DokumenModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    publicId.value = data.client.publicID;
    statusPekerjaan.value = data.status;
    fetchDetailBerkas();
  }

  Future<void> fetchDetailBerkas() async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "client_name": data.client.name,
          "publicID": data.client.publicID,
        }),
      );

      print("Response Body API Detail: ${response.body}");

      if (response.statusCode == 200) {
        final resBody = json.decode(response.body);

        if (resBody['status'] == true && resBody['data'] != null) {
          final rawData = resBody['data'];

          publicId.value =
              rawData['client']?['publicID'] ?? data.client.publicID;
          statusPekerjaan.value = rawData['status'] ?? "PENDING";

          String statusBayarRaw = rawData['status'] ?? "pending";
          statusPajak.value =
              (statusBayarRaw.toLowerCase() == "success" ||
                  statusBayarRaw.toLowerCase() == "lunas")
              ? "Lunas"
              : "Belum Bayar";

          if (rawData['staff'] != null) {
            namaStaff.value = rawData['staff']['name'] ?? "Sistem Otomatis";
          } else if (rawData['created_by'] != null) {
            namaStaff.value = rawData['created_by'].toString();
          } else if (rawData['client']?['staff_name'] != null) {
            namaStaff.value = rawData['client']['staff_name'];
          }

          final docTx = rawData['document_transaction'];
          if (docTx != null) {
            if (docTx['staff_name'] != null) {
              namaStaff.value = docTx['staff_name'];
            }

            final asset = docTx['asset'];
            if (asset != null && asset['metadata'] != null) {
              final metadata = asset['metadata'];

              final dynamic rawAmount =
                  metadata['amount'] ??
                  metadata['total_biaya'] ??
                  metadata['price'];
              int amountInt = 0;
              if (rawAmount is int) {
                amountInt = rawAmount;
              } else if (rawAmount is double) {
                amountInt = rawAmount.toInt();
              } else if (rawAmount is String) {
                amountInt = int.tryParse(rawAmount) ?? 0;
              }
              final currencyFormatter = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );
              totalBiaya.value = currencyFormatter.format(amountInt);

              if (metadata['location'] != null) {
                final location = metadata['location'];
                if (location is Map) {
                  final lat = location['latitude'] ?? location['lat'];
                  final lng = location['longitude'] ?? location['lng'];
                  final addressString = location['address'] ?? location['name'];

                  if (addressString != null) {
                    alamat.value = addressString.toString();
                  } else if (lat != null && lng != null) {
                    alamat.value =
                        "Kebayoran Baru, Jakarta (Lat: $lat, Lng: $lng)";
                  }
                } else {
                  alamat.value = location.toString();
                }
              } else if (metadata['address'] != null) {
                alamat.value = metadata['address'].toString();
              }

              final dynamic rawFiles =
                  metadata['files'] ??
                  metadata['documents'] ??
                  metadata['attachments'];
              if (rawFiles != null && rawFiles is List) {
                List<DokumenModel> tempDocs = [];

                for (var f in rawFiles) {
                  String fileName = "Dokumen Persyaratan";
                  String fileUrl = "";

                  if (f is Map) {
                    fileName =
                        f['name'] ??
                        f['filename'] ??
                        f['title'] ??
                        "Dokumen Tanpa Nama";
                    fileUrl = f['url'] ?? f['secure_url'] ?? f['path'] ?? "";
                  } else if (f is String) {
                    fileUrl = f;
                    fileName = f.split('/').last;
                  }

                  if (fileUrl.isEmpty) continue;

                  bool checkImg =
                      fileUrl.toLowerCase().endsWith(".jpg") ||
                      fileUrl.toLowerCase().endsWith(".png") ||
                      fileUrl.toLowerCase().endsWith(".jpeg") ||
                      fileName.toLowerCase().contains(".jpg") ||
                      fileName.toLowerCase().contains(".png");

                  tempDocs.add(
                    DokumenModel(
                      nama: fileName,
                      url: fileUrl,
                      tanggal: "13 Nov 2023",
                      isImage: checkImg,
                    ),
                  );
                }
                dokumenList.value = tempDocs;
              }
            }
          }
        }
      }
    } catch (e) {
      print("EROR PARSING DETAIL: Tolong periksa struktur JSON Anda. Eror: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusPekerjaan(String value) async {
    statusPekerjaan.value = value;
    try {
      final response = await http.post(
        Uri.parse(updateStatusUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id": data.id,
          "status": value.toLowerCase(),
          "type": "pengerjaan",
        }),
      );
      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Status pengerjaan diperbarui");
        fetchDetailBerkas();
      }
    } catch (e) {
      print("Gagal update status pengerjaan: $e");
    }
  }

  Future<void> updateStatusPajak(String value) async {
    statusPajak.value = value;
    try {
      final response = await http.post(
        Uri.parse(updateStatusUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id": data.id,
          "status": value == "Lunas" ? "success" : "pending",
          "type": "pembayaran",
        }),
      );
      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Status pembayaran diperbarui");
        fetchDetailBerkas();
      }
    } catch (e) {
      print("Gagal update status pajak: $e");
    }
  }

  Color getStatusPekerjaanColor(String status) =>
      status.toUpperCase() == "SUCCESS" || status.toUpperCase() == "SELESAI"
      ? AppColors.statusSelesai
      : AppColors.statusProses;
  Color getStatusPekerjaanBg(String status) =>
      status.toUpperCase() == "SUCCESS" || status.toUpperCase() == "SELESAI"
      ? AppColors.statusSelesaiBg
      : AppColors.statusProsesBg;
  Color getStatusPajakColor(String status) =>
      status.toLowerCase() == "lunas" ? AppColors.statusSelesai : Colors.orange;
  Color getStatusPajakBg(String status) => status.toLowerCase() == "lunas"
      ? AppColors.statusSelesaiBg
      : Colors.orange.withOpacity(0.1);
}
