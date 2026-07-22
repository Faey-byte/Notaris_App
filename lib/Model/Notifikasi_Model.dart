import 'package:flutter/material.dart';

class NotifikasiModel {
  final int id;
  final String title;
  final String message;
  final String type; // 'berkas', 'pembayaran', 'sistem'
  final DateTime createdAt;
  bool isRead;

  NotifikasiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'sistem',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }
}