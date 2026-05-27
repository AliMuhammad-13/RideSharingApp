import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // SIGN UP (create auth user + profile row)
  Future signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception("Signup failed");
    }

    // Create profile row (IMPORTANT)
    await supabase.from('profiles').insert({
      'id': user.id,
      'name': name,
      'phone': '',
      'bio': '',
      'avatar_url': null,
    });
  }

  // LOGIN
  Future signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  // LOGOUT
  Future signOut() async {
    await supabase.auth.signOut();
  }
}
