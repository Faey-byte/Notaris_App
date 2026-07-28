import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notaris_app/Controller/Notification_Controller.dart';
import '../data/services/websocket_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: const Text(
              'Tandai semua dibaca',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.notifications;

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada notifikasi',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notif = items[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: notif.isRead
                    ? Colors.grey.shade300
                    : Colors.blue.shade100,
                child: Icon(
                  Icons.notifications,
                  color: notif.isRead ? Colors.grey : Colors.blue,
                ),
              ),
              title: Text(
                notif.message,
                style: TextStyle(
                  fontWeight:
                      notif.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(notif.timestamp),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: notif.isRead
                  ? null
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
              onTap: () {
                controller.markAsRead(notif.id);
                if (notif.ppatId != null) {
                  Get.toNamed('/ppat', arguments: notif.ppatId);
                }
              },
            );
          },
        );
      }),
    );
  }
}