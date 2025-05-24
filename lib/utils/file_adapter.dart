// Export file adapter based on platform
export 'file_adapter_io.dart' if (dart.library.html) 'file_adapter_web.dart';
