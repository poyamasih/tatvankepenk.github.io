import 'dart:io';

class FileAdapter {
  static bool exists(String path) {
    try {
      return File(path).existsSync();
    } catch (e) {
      return false; // On web platform, handle gracefully
    }
  }
}
