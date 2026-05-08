import 'package:flutter/material.dart';
import 'package:notaris_app/Model/Ppat_Model.dart';

class DetailBerkasPage extends StatelessWidget {
  final BerkasModel data;

  const DetailBerkasPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Detail Berkas"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    data.nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "No. Berkas: ${data.no}",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Jenis: ${data.jenis}",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Tanggal: ${data.tanggal}",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Status: ${data.status}",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}