import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar and navigation bar colors
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8B5CF6),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("enzoXzodix")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {},
          onPageFinished: (_) {},
          onWebResourceError: (error) async {
            String htmlString = await rootBundle.loadString('assets/404.html');
            _controller.loadRequest(
              Uri.dataFromString(
                htmlString,
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8'),
              ),
            );
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith('https://coder8-33-63.vercel.app/')) {
              return NavigationDecision.navigate;
            } else {
              _launchExternalBrowser(request.url);
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://coder8-33-63.vercel.app/'));
  }

  Future<void> _launchExternalBrowser(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    final permissionStatus = await Permission.manageExternalStorage.request();

    if (permissionStatus.isGranted) {
      return true;
    } else {
      print("Storage permission denied.");
      return false;
    }
  }

  // Pick a file using the file picker
  Future<void> _pickFile() async {
    // Request permission before picking a file
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      return;
    }

    // Pick a file using the file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      print('Picked file: ${file.path}');
      // Handle the file, e.g., read, save, etc.
    } else {
      print('No file picked');
    }
  }

  // Save the content to a file in Downloads/Decoder directory
  Future<void> _saveFile(String fileName, String content) async {
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      return;
    }

    try {
      final directory = await _getDownloadsDirectory();
      if (directory != null) {
        final file = File('${directory.path}/Decoder/$fileName');
        await file.create(recursive: true);
        await file.writeAsString(content);
        print('File saved at: ${file.path}');
      }
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  // Get the path to the Downloads directory
  Future<Directory?> _getDownloadsDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final downloadsDir = Directory('${directory.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return downloadsDir;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Color(0xFF8B5CF6),
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile, // Trigger file picker
        child: Icon(Icons.file_present),
      ),
    );
  }
}
 
