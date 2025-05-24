class FileAdapter {
  static bool exists(String path) {
    return false; // Web doesn't support File.existsSync
  }
}
