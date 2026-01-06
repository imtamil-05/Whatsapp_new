import 'package:firebase_auth/firebase_auth.dart'as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUserService {
  static final _supabase = Supabase.instance.client;

  static Future<void> syncFirebaseUser(firebase_auth.User user) async {
    await _supabase.from('users').upsert({
      'id': user.uid,                     // Firebase UID
      'phone': user.phoneNumber,
      'online': true,
      'last_seen': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateOnline(bool online) async {
    final firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _supabase.from('users').update({
      'online': online,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', user.uid);
  }


  /// Create user if not exists (first login)
  static Future<void> createOrUpdateUser({
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    final userId = user.id;

    // Check if user already exists
    final existingUser = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (existingUser == null) {
      // Insert new user
      await _supabase.from('users').insert({
        'id': userId,
        'name': name,
        'phone': phone,
        'photo_url': photoUrl,
        'online': true,
        'last_seen': DateTime.now().toIso8601String(),
      });
    } else {
      // Update existing user
      await _supabase.from('users').update({
        'name': name,
        'phone': phone,
        'photo_url': photoUrl,
        'online': true,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    }
  }

  /// Update online / offline
  static Future<void> updateOnlineStatus(bool online) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('users').update({
      'online': online,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }
  static Future<void> setTyping(bool typing) async {
  final user = firebase_auth.FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await _supabase.from('users').update({
    'is_typing': typing,
  }).eq('id', user.uid);
}

}
