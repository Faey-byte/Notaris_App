import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/profile_controller.dart';
import 'package:notaris_app/Widget/common/section_label.dart';
import 'package:notaris_app/Widget/profile/profile_header.dart';
import 'package:notaris_app/Widget/profile/profile_info_section.dart';
import 'package:notaris_app/Widget/profile/profile_logout_button.dart';
import 'package:notaris_app/Widget/profile/profile_settings_section.dart';
import 'package:notaris_app/Widget/profile/profile_top_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            ProfileTopBar(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(controller: controller),
                    const SizedBox(height: 28),
                    const SectionLabel(label: 'INFORMASI AKUN'),
                    const SizedBox(height: 8),
                    ProfileInfoSection(controller: controller),
                    const SizedBox(height: 24),
                    const SectionLabel(label: 'PENGATURAN'),
                    const SizedBox(height: 8),
                    const ProfileSettingsSection(),
                    const SizedBox(height: 28),
                    ProfileLogoutButton(controller: controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}