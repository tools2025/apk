import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _promptUserForFileName(BuildContext context, Uint8List data, String mimeType) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Save File"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter filename"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String fileName = controller.text.trim().isNotEmpty
                    ? controller.text.trim()
                    : "XD-TOOLS_${DateTime.now().millisecondsSinceEpoch}.txt";

                await _saveFileToDownloads(fileName, data, mimeType);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveFileToDownloads(String fileName, Uint8List data, String mimeType) async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        return;
      }
    }

    Directory? downloadsDir = await getExternalStorageDirectory();
    if (downloadsDir == null) return;

    String downloadsPath = "${downloadsDir.path}/DECODE";
    Directory(downloadsDir).createSync(recursive: true);

    File file = File("$downloadsPath/$fileName");
    await file.writeAsBytes(data);

    final params = SaveFileDialogParams(sourceFilePath: file.path);
    await FlutterFileDialog.saveFile(params: params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Color(0xFF8B5CF6),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                Uint8List data = utf8.encode("Sample text file");
                _promptUserForFileName(context, data, "text/plain");
              },
              child: Icon(Icons.save),
              backgroundColor: Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }
}
