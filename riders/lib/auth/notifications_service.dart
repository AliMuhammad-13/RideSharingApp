import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsService {
  final supabase = Supabase.instance.client;

  // FETCH ALL NOTIFICATIONS FOR CURRENT USER
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Warning: Could not fetch notifications: $e");
      return [];
    }
  }

  // MARK ALL NOTIFICATIONS AS READ
  Future<void> markAllAsRead() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id);
    } catch (e) {
      print("Warning: Could not mark notifications as read: $e");
    }
  }

  // GET UNREAD COUNT
  Future<int> getUnreadCount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return 0;

    try {
      final data = await supabase
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      return data.length;
    } catch (e) {
      print("Warning: Could not get unread count: $e");
      return 0;
    }
  }
}
