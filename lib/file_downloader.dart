// file_downloader.dart
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloader {
  Future<void> downloadFile(String url, String fileName) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final externalDir = await getExternalStorageDirectory();
      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir!.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      print('Permission denied');
    }
  }
}
