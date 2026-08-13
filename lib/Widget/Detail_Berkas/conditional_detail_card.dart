import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detail_info_card.dart';

class ConditionalDetailCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool Function() hasData;
  final List<String> Function() linesBuilder;

  const ConditionalDetailCard({
    super.key,
    required this.title,
    required this.hasData,
    required this.linesBuilder,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!hasData()) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DetailInfoCard(
          title: title,
          content: linesBuilder().join('\n'),
          icon: icon,
        ),
      );
    });
  }
}