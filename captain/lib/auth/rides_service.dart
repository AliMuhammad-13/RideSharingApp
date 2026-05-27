import 'package:supabase_flutter/supabase_flutter.dart';

class RidesService {
  final supabase = Supabase.instance.client;

  // CREATE RIDE (Captain)
  Future<void> createRide({
    required String name,
    required String car,
    required String to,
    required String pickup,
    required String fare,
    required int seats,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await supabase.from('rides').insert({
      'name': name,
      'car': car,
      'to': to,
      'from': pickup,
      'fare': fare,
      'seats': seats,
      'captain_id': user.id,
      'status': 'active',
    });
  }

  // GET ALL ACTIVE RIDES
  Future<List<Map<String, dynamic>>> getRides() async {
    final data = await supabase.from('rides').select().eq('status', 'active');
    return List<Map<String, dynamic>>.from(data);
  }

  // GET RIDES BY CAPTAIN
  Future<List<Map<String, dynamic>>> getCaptainRides() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('rides')
        .select()
        .eq('captain_id', user.id);

    return List<Map<String, dynamic>>.from(data);
  }

  // GET ACTIVE RIDES BY CAPTAIN
  Future<List<Map<String, dynamic>>> getCaptainActiveRides() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('rides')
        .select()
        .eq('captain_id', user.id)
        .eq('status', 'active');

    return List<Map<String, dynamic>>.from(data);
  }

  // GET COMPLETED RIDES BY CAPTAIN
  Future<List<Map<String, dynamic>>> getCaptainHistoryRides() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from('rides')
        .select()
        .eq('captain_id', user.id)
        .eq('status', 'completed');

    return List<Map<String, dynamic>>.from(data);
  }

  // GET PENDING REQUESTS FOR CAPTAIN'S RIDES
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    // 1. Get all active rides for this captain
    final ridesData = await supabase
        .from('rides')
        .select('id')
        .eq('captain_id', user.id)
        .eq('status', 'active');

    if (ridesData.isEmpty) return [];
    final rideIds = ridesData.map((r) => r['id']).toList();

    // 2. Get bookings for these rides that are in 'pending' status
    final bookingsData = await supabase
        .from('bookings')
        .select('*, rides(*)')
        .inFilter('ride_id', rideIds)
        .eq('status', 'pending');

    final dataList = List<Map<String, dynamic>>.from(bookingsData);

    // 3. Fetch user profiles for these bookings
    if (dataList.isNotEmpty) {
      final riderIds = dataList.map((b) => b['rider_id'] as String).toSet().toList();
      final profilesData = await supabase
          .from('profiles')
          .select()
          .inFilter('id', riderIds);
      final profilesMap = {for (var p in profilesData) p['id'] as String: p};

      for (var booking in dataList) {
        booking['rider_profile'] = profilesMap[booking['rider_id']];
      }
    }

    return dataList;
  }

  // ACCEPT BOOKING REQUEST
  Future<void> acceptBooking(int bookingId, int rideId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 1. Check if seats are available
    final ride = await supabase.from('rides').select('seats').eq('id', rideId).single();
    final int currentSeats = ride['seats'] ?? 0;
    if (currentSeats <= 0) {
      throw Exception("No seats available on this ride.");
    }

    // 2. Accept booking
    await supabase.from('bookings').update({'status': 'active'}).eq('id', bookingId);

    // 3. Decrease seats
    await supabase.from('rides').update({'seats': currentSeats - 1}).eq('id', rideId);

    // 4. Send notification to the Rider
    final booking = await supabase.from('bookings').select('rider_id').eq('id', bookingId).single();
    final riderId = booking['rider_id'];

    final captainProfile = await supabase.from('profiles').select('name').eq('id', user.id).single();
    final captainName = captainProfile['name'] ?? 'Captain';

    try {
      await supabase.from('notifications').insert({
        'user_id': riderId,
        'title': 'Booking Approved!',
        'message': '$captainName has accepted your booking request.',
        'is_read': false,
      });
    } catch (e) {
      print("Warning: Could not insert notification: $e");
    }
  }

  // REJECT BOOKING REQUEST
  Future<void> rejectBooking(int bookingId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 1. Fetch rider details first
    final booking = await supabase.from('bookings').select('rider_id').eq('id', bookingId).single();
    final riderId = booking['rider_id'];

    // 2. Reject booking
    await supabase.from('bookings').update({'status': 'rejected'}).eq('id', bookingId);

    // 3. Send notification to the Rider
    final captainProfile = await supabase.from('profiles').select('name').eq('id', user.id).single();
    final captainName = captainProfile['name'] ?? 'Captain';

    try {
      await supabase.from('notifications').insert({
        'user_id': riderId,
        'title': 'Booking Declined',
        'message': '$captainName has declined your booking request.',
        'is_read': false,
      });
    } catch (e) {
      print("Warning: Could not insert notification: $e");
    }
  }

  // COMPLETE RIDE
  Future<void> completeRide(int rideId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 1. Update ride status to completed
    await supabase.from('rides').update({'status': 'completed'}).eq('id', rideId);

    // 2. Find active bookings to notify riders and complete bookings
    final activeBookings = await supabase
        .from('bookings')
        .select('rider_id')
        .eq('ride_id', rideId)
        .eq('status', 'active');

    // 3. Update bookings status to completed
    await supabase
        .from('bookings')
        .update({'status': 'completed'})
        .eq('ride_id', rideId)
        .eq('status', 'active');

    // 4. Send notification to riders
    final captainProfile = await supabase.from('profiles').select('name').eq('id', user.id).single();
    final captainName = captainProfile['name'] ?? 'Captain';

    for (var b in activeBookings) {
      final riderId = b['rider_id'];
      try {
        await supabase.from('notifications').insert({
          'user_id': riderId,
          'title': 'Ride Completed',
          'message': 'Your ride with $captainName has been completed. Hope you had a nice journey!',
          'is_read': false,
        });
      } catch (e) {
        print("Warning: Could not insert notification: $e");
      }
    }
  }
}
