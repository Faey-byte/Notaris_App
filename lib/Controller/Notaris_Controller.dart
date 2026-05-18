import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusItem {
  final String label;
  final Color textColor;
  final Color bgColor;
  StatusItem({required this.label, required this.textColor, required this.bgColor});
}

class AktaItem {
  final String nama;
  final String jenis;
  final String no;
  final String tanggal;
  final String status;
  const AktaItem({required this.nama, required this.jenis, required this.no, required this.tanggal, required this.status});
}

class NotarisController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'SEMUA'.obs;

  final statusList = [
    StatusItem(label: 'SEMUA',   textColor: const Color(0xFF64748B), bgColor: const Color(0xFFF1F5F9)),
    StatusItem(label: 'SELESAI', textColor: const Color(0xFF15803D), bgColor: const Color(0xFFDCFCE7)),
    StatusItem(label: 'PROSES',  textColor: const Color(0xFFB45309), bgColor: const Color(0xFFFEF3C7)),
    StatusItem(label: 'REVISI',  textColor: const Color(0xFF1D4ED8), bgColor: const Color(0xFFDBEAFE)),
  ];

  final RxList<AktaItem> allItems = <AktaItem>[
    const AktaItem(nama: 'PT. Teknologi Nusantara', jenis: 'Pendirian Perseroan Terbatas',
        no: '124/Leg/X/2023', tanggal: '12 Okt 2023', status: 'SELESAI'),
    const AktaItem(nama: 'Bapak Ahmad Subardjo', jenis: 'Akta Jual Beli Tanah',
        no: '45/AJB/XI/2023', tanggal: '28 Nov 2023', status: 'PROSES'),
    const AktaItem(nama: 'CV. Mandiri Sejahtera', jenis: 'Perubahan Anggaran Dasar',
        no: '12/PAD/XII/2023', tanggal: '05 Des 2023', status: 'REVISI'),
    const AktaItem(nama: 'Ibu Maria Simatupang', jenis: 'Akta Hibah',
        no: '08/HB/I/2024', tanggal: '12 Jan 2024', status: 'SELESAI'),
  ].obs;

  List<AktaItem> get filteredItems {
    List<AktaItem> hasil = allItems;

    if (selectedStatus.value != 'SEMUA') {
      hasil = hasil.where((e) => e.status == selectedStatus.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      hasil = hasil.where((e) =>
        e.nama.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        e.no.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    return hasil;
  }

  void setStatus(String val) => selectedStatus.value = val;
  void setSearch(String val) => searchQuery.value = val;
}