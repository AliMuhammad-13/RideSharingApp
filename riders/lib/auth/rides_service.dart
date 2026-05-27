import 'package:supabase_flutter/supabase_flutter.dart';

class RidesService {
  final supabase = Supabase.instance.client;

  //creating ride
  Future ridesService({
    required String name,
    required String car,
    required String to,
    required String from,
    required String fare,
  }) async {
    await supabase.from('rides').insert({
      'name': name,
      'car': car,
      "to": to,
      "from": from,
      "fare": fare,
    });
  }

  //Getting data to display
  Future<List<Map<String, dynamic>>> getRides() async {
    final data = await supabase
        .from('rides')
        .select()
        .eq('status', 'active')
        .gt('seats', 0);

    return List<Map<String, dynamic>>.from(data);
  }
}
