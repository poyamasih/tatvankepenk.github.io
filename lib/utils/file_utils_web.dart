import 'dart:html' as html;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart' as image_picker;

Future<Uint8List> readFileAsBytes(dynamic file) async {
  if (file is html.File) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return reader.result as Uint8List;
  } else if (file is image_picker.XFile) {
    // XFile from image_picker
    return await file.readAsBytes();
  } else if (file is WebXFile) {
    return await file.readAsBytes();
  }
  throw UnsupportedError(
    'Unsupported file type for web platform: ${file.runtimeType}',
  );
}

String getFilePath(dynamic file) {
  if (file is html.File) {
    return file.name;
  } else if (file is image_picker.XFile) {
    // XFile from image_picker
    return file.path;
  } else if (file is WebXFile) {
    return file.name;
  }
  throw UnsupportedError(
    'Unsupported file type for web platform: ${file.runtimeType}',
  );
}

String getFileExtension(dynamic file) {
  String name = '';
  if (file is html.File) {
    name = file.name;
  } else if (file is image_picker.XFile) {
    // XFile from image_picker
    name = file.name;
  } else if (file is WebXFile) {
    name = file.name;
  } else {
    throw UnsupportedError(
      'Unsupported file type for web platform: ${file.runtimeType}',
    );
  }

  // Extract extension safely
  return name.contains('.')
      ? name.split('.').last
      : 'jpg'; // Default to jpg if no extension
}

// Custom wrapper for html.File to maintain compatibility
class WebXFile {
  final html.File _file;

  WebXFile(this._file);

  String get name => _file.name;
  String get path => _file.name;

  Future<Uint8List> readAsBytes() async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(_file);
    await reader.onLoad.first;
    return reader.result as Uint8List;
  }
}
