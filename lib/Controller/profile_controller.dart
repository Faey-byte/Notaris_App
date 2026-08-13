import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notaris_app/data/services/profile_service.dart';
import 'package:notaris_app/config/base_url.dart';
import '../Routes/routes.dart';
import 'package:notaris_app/utils/logger.dart';

class ProfileController extends GetxController {
  static const String baseUrl = ApiConfig.baseUrl;

  final RxString nama = ''.obs;
  final RxString tanggalLahir = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  DateTime? selectedBirthDay;

  @override
  void onInit() {
    super.onInit();
    loadProfileFromPrefs();
  }

  Future<void> loadProfileFromPrefs() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();

      nama.value = prefs.getString('nama') ?? '-';
      tanggalLahir.value = prefs.getString('tanggal_lahir') ?? '-';
    } catch (e) {
      AppLogger.log("❌ [PROFILE] Gagal memuat data profil: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void openEditDialog() {
    final nameController = TextEditingController(text: nama.value);
    selectedBirthDay = null;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Profil",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Nama Lengkap",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tanggal Lahir",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedBirthDay = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedBirthDay != null
                            ? "${selectedBirthDay!.year}-${selectedBirthDay!.month.toString().padLeft(2, '0')}-${selectedBirthDay!.day.toString().padLeft(2, '0')}"
                            : "Pilih tanggal lahir",
                        style: TextStyle(
                          color: selectedBirthDay != null
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: isUpdating.value
                                ? null
                                : () async {
                                    if (nameController.text.trim().isEmpty ||
                                        selectedBirthDay == null) {
                                      Get.snackbar(
                                        "Peringatan",
                                        "Nama dan tanggal lahir wajib diisi",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }
                                    await _submitUpdate(
                                      nameController.text.trim(),
                                      selectedBirthDay!,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF913632),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isUpdating.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Simpan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitUpdate(String newName, DateTime birthDay) async {
    try {
      isUpdating.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final message = await ProfileService.updateProfile(
        token: token,
        currentName: nama.value,
        newName: newName,
        birthDay: birthDay,
      );

      final birthDayFormatted =
          "${birthDay.year}-${birthDay.month.toString().padLeft(2, '0')}-${birthDay.day.toString().padLeft(2, '0')}";

      nama.value = newName;
      tanggalLahir.value = birthDayFormatted;

      await prefs.setString('nama', newName);
      await prefs.setString('tanggal_lahir', birthDayFormatted);

      Get.back();

      Get.snackbar(
        "Berhasil",
        message,
        backgroundColor: const Color(0xFFF0FDF4),
        colorText: const Color(0xFF15803D),
      );
    } catch (e) {
      Get.snackbar(
        "Gagal",
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFF913632),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void confirmLogout() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF913632),
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Konfirmasi Keluar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Apakah Anda yakin ingin keluar dari aplikasi?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        backgroundColor: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF913632),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Ya, Keluar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _logout() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('nama');
      await prefs.remove('tanggal_lahir');

      AppLogger.log("✅ [PROFILE] Logout berhasil, data lokal dibersihkan");

      Get.snackbar(
        "Logout Berhasil",
        "Anda telah keluar dari akun",
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFF913632),
      );

      Get.offAllNamed(AppRoutes.loginpage);
    } catch (e) {
      AppLogger.log("❌ [PROFILE] ERROR LOGOUT: $e");
      Get.snackbar("Error", "Gagal melakukan logout, coba lagi.");
    }
  }
}
