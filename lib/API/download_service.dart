import 'package:dio/dio.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

abstract class DownloadService {
  Future<void> download({required String url});
}

class WebDownloadService implements DownloadService {
  @override
  Future<void> download({required String url}) async {
    html.window.open(url, "_blank");
  }
}

class MobileDownloadService implements DownloadService {
  @override
  Future<void> download({required String url}) async {
    bool hasPermission = await _requestWritePermission();
    if (!hasPermission) return;

    Dio dio = Dio();
    var dir = await getApplicationDocumentsDirectory();


    String fileName = 'myFile';
    await dio.download(url, "${dir.path}/$fileName");
    OpenFile.open("${dir.path}/$fileName", type: 'application/excel');
  }

  Future<bool> _requestWritePermission() async {
    await Permission.storage.request();
    return await Permission.storage.request().isGranted;
  }
}