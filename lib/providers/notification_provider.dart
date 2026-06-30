import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_model.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';
import '../services/local_notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _currentUserId;
  bool _isFirstLoad = true;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('notifications');

  void loadNotifications(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    _isFirstLoad = true;

    _subscription?.cancel();
    _subscription = _collection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        if (!_isFirstLoad) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final newNotification = NotificationModel.fromFirestore(change.doc);
              LocalNotificationService.showNotification(
                title: newNotification.title,
                body: newNotification.message,
              );
              _showInAppNotification(newNotification.title, newNotification.message, newNotification.type);
            }
          }
        }
        
        _notifications = snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
        _isFirstLoad = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('NotificationProvider real-time listener error: $e');
      },
    );
  }

  void clearUser() {
    _currentUserId = null;
    _subscription?.cancel();
    _notifications = [];
    notifyListeners();
  }

  Future<void> addNotification(String userId, String title, String message, {NotificationType type = NotificationType.general, String bookingId = ''}) async {
    final notification = NotificationModel(
      id: '', // Will be assigned by Firestore
      userId: userId,
      bookingId: bookingId,
      type: type,
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );

    try {
      await _collection.add(notification.toFirestore());
      // Removed _showInAppNotification from here because the Firestore 
      // listener will now pick up the addition and show it.
    } catch (e) {
      debugPrint('Error adding notification to Firestore: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      // Optimistic update
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      try {
        await _collection.doc(id).update({'isRead': true});
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
        // Revert on error
        _notifications[index] = _notifications[index].copyWith(isRead: false);
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    final batch = FirebaseFirestore.instance.batch();
    bool hasUpdates = false;

    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        batch.update(_collection.doc(_notifications[i].id), {'isRead': true});
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      notifyListeners();
      try {
        await batch.commit();
      } catch (e) {
        debugPrint('Error marking all notifications as read: $e');
      }
    }
  }

  void _showInAppNotification(String title, String message, NotificationType type) {
    final messenger = messengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(type.icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
