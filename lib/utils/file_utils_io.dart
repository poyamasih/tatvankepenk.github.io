import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List> readFileAsBytes(dynamic file) async {
  if (file is File) {
    return await file.readAsBytes();
  } else if (file is XFile) {
    return await file.readAsBytes();
  }
  throw UnsupportedError(
    'Unsupported file type for IO platform: ${file.runtimeType}',
  );
}

String getFilePath(dynamic file) {
  if (file is File) {
    return file.path;
  } else if (file is XFile) {
    return file.path;
  }
  throw UnsupportedError(
    'Unsupported file type for IO platform: ${file.runtimeType}',
  );
}

String getFileExtension(dynamic file) {
  if (file is File) {
    return file.path.split('.').last.toLowerCase();
  } else if (file is XFile) {
    return file.name.split('.').last.toLowerCase();
  }
  // Default to jpg if we can't determine the extension
  return 'jpg';
}
