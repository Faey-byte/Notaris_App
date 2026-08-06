// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../Controller/notification_controller.dart';

// class NotificationBadge extends StatelessWidget {
//   final Widget child;
//   const NotificationBadge({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<NotificationController>();

//     return Obx(() {
//       final count = controller.unreadCount.value;
//       return Stack(
//         clipBehavior: Clip.none,
//         children: [
//           child,
//           if (count > 0)
//             Positioned(
//               right: -6,
//               top: -4,
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//                 constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
//                 child: Text(
//                   count > 99 ? '99+' : '$count',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//         ],
//       );
//     });
//   }
// }