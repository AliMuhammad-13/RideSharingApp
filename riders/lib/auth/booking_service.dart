import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final supabase = Supabase.instance.client;

  // BOOK RIDE
  Future bookRide({required int rideId}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // 1. Create a pending booking
      final response = await supabase.from('bookings').insert({
        'ride_id': rideId,
        'rider_id': user.id, // Fixed: use rider_id from database schema
        'status': 'pending', // Starts as pending until captain approves
      }).select();

      // 2. Notify the Captain
      final ride = await supabase.from('rides').select('captain_id, to').eq('id', rideId).single();
      final captainId = ride['captain_id'];

      final riderProfile = await supabase.from('profiles').select('name').eq('id', user.id).single();
      final riderName = riderProfile['name'] ?? 'Rider';

      if (captainId != null) {
        try {
          await supabase.from('notifications').insert({
            'user_id': captainId,
            'title': 'New Booking Request',
            'message': '$riderName has requested to join your ride to ${ride['to'] ?? 'destination'}.',
            'is_read': false,
          });
        } catch (e) {
          print("Warning: Could not insert notification: $e");
        }
      }

      print("BOOK SUCCESS: $response");
    } catch (e) {
      print("BOOK ERROR: $e");
      rethrow;
    }
  }

  // GET ACTIVE RIDES
  Future<List<Map<String, dynamic>>> getActiveRides() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('bookings')
        .select('*, rides(*)')
        .eq('rider_id', user.id) // Fixed: use rider_id
        .eq('status', 'active'); // Active bookings are those approved by Captain

    return List<Map<String, dynamic>>.from(data);
  }

  // GET RIDE HISTORY
  Future<List<Map<String, dynamic>>> getRideHistory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('bookings')
        .select('*, rides(*)')
        .eq('rider_id', user.id) // Fixed: use rider_id
        .eq('status', 'completed'); // Completed bookings

    return List<Map<String, dynamic>>.from(data);
  }
}
