import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageServices with ChangeNotifier{
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _images = [];
  bool _isLoading = false;
  bool _isuploading = false;

  List<String> get images => _images;

  bool get isLoading => _isLoading;

  bool get isUploading => _isuploading;

  Future<void> fetchImages() async {
    _isLoading = true;
    notifyListeners();
    final result = await _storage.ref('images').listAll();
    //final listResult = await result.listAll();
    final url=<String>[];

    for (final ref in result.items) {
      url.add(await ref.getDownloadURL());
    }
    _images..clear()
      ..addAll(url);

    _isLoading = false;
    notifyListeners();
 
  }

  Future<void> uploadImage() async {
  _isuploading = true;
  notifyListeners();

  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      _isuploading = false;
      notifyListeners();
      return;
    }

    final file = File(pickedFile.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child('images/$fileName.jpg');

    // Upload image
    await ref.putFile(file);

    // Get download URL
    final downloadUrl = await ref.getDownloadURL();

    _images.add(downloadUrl);
  } on FirebaseException catch (e) {
    debugPrint('Firebase error: ${e.code} - ${e.message}');
  } catch (e) {
    debugPrint('Unknown error: $e');
  } finally {
    _isuploading = false;
    notifyListeners();
  }
}


  Future<void> deleteImage(String url) async {
  _images.remove(url);
  notifyListeners();
  try{
    final path=extractPathFromUrl(url);
    final ref = _storage.ref().child(path);
    await ref.delete();
  }catch(e){
    debugPrint(e.toString());
  }
  }

  String extractPathFromUrl(String url) {
    final uri = Uri.parse(url); 
    final fullPath = uri.pathSegments.skipWhile((s) => s != 'o').skip(1).join('/'); 
    return Uri.decodeFull(fullPath.split('?').first); 
  }
}