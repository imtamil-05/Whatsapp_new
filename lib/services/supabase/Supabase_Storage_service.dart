import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final _supabase = Supabase.instance.client;


  Future<String> uploadChatImage(File file, String userId) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    
    final path ='$userId/$fileName';
    await _supabase.storage.from('chat-images').upload(
          '$userId/$fileName',
          file,
        );

    return _supabase.storage
        .from('chat-images')
        .getPublicUrl('$userId/$fileName');
  }

   Future<String> uploadStatusImage(File file, String userId) async {
    final fileName ='${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'status/$userId/$fileName'; 

    final bytes = await file.readAsBytes();

    await _supabase.storage
        .from('status')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
          ));

    final imageUrl = _supabase.storage
        .from('status')
        .getPublicUrl(path);

    return imageUrl;
  }
  Future<String> uploadChatOrStatusImage({required File file,
    required String userId,
    required String folder,
  }) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final path = '$folder/$userId/$fileName';

      final bytes = await file.readAsBytes();

      await _supabase.storage
          .from('chat-images') // ✅ ONLY ONE BUCKET
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = _supabase.storage
          .from('chat-images')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  
}


