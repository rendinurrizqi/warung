import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalStorageService {
  static Future<String> saveBackupFile(String fileName, List<int> bytes) async {
    await Permission.storage.request();

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/backup";

    final backupDir = Directory(path);
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }

    final file = File("$path/$fileName");
    file.writeAsBytesSync(bytes, flush: true);

    return file.path;
  }
}
