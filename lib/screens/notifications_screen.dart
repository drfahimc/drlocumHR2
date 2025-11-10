import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/notification_model.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/notifications/notification_item.dart';
import '../widgets/common/empty_state.dart';
import '../services/notifications_service.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsService _notificationsService = NotificationsService();
  final AuthService _authService = AuthService();
  int _unreadCount = 0;

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.getCurrentUserId();

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarWithBack(
          title: 'Notifications',
        ),
        body: const Center(
          child: Text(
            'Please log in to view notifications',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: 'Notifications',
        notificationCount: _unreadCount > 0 ? _unreadCount : null,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationsService.streamNotifications(currentUserId),
        builder: (context, snapshot) {
          // Update unread count
          if (snapshot.hasData) {
            final unreadCount = snapshot.data!.where((n) => !n.read).length;
            if (unreadCount != _unreadCount) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _unreadCount = unreadCount;
                  });
                }
              });
            }
          }
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Retry
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              message: 'No notifications',
              subtitle: 'You\'re all caught up!',
            );
          }

          // Notifications list
          return RefreshIndicator(
            onRefresh: () async {
              // Stream will automatically update
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationItem(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) async {
    // Mark as read if not already read
    if (!notification.read) {
      try {
        await _notificationsService.markAsRead(notification.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error marking notification as read: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.application:
        // TODO: Navigate to job details or applications screen
        if (notification.relatedEntityId != null) {
          // Navigator.push(...)
        }
        break;
      case NotificationType.shift:
        // TODO: Navigate to shift details
        break;
      case NotificationType.payment:
        // TODO: Navigate to payment details
        break;
      case NotificationType.approval:
        // TODO: Navigate to approved job
        break;
      case NotificationType.message:
        // TODO: Navigate to messages
        break;
    }
  }
}
