import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:webview_flutter/webview_flutter.dart';

import '../domain/downloaded_file.dart';

const _csp = "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob: file:";

class WebsitePage extends StatefulWidget {
  const WebsitePage({super.key, required this.site});

  final DownloadedFile site;

  @override
  State<WebsitePage> createState() => _WebsitePageState();
}

class _WebsitePageState extends State<WebsitePage> {
  late WebViewController _controller;
  bool _sandboxed = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    if (_sandboxed) {
      await _loadSandboxed();
    } else {
      await _controller.loadFile(widget.site.filePath);
    }

    if (mounted) setState(() {});
  }

  Future<void> _loadSandboxed() async {
    final file = File(widget.site.filePath);
    final html = await file.readAsString();

    // Inject CSP into <head> to block external network requests
    final secured = html.contains('<head>')
        ? html.replaceFirst(
            '<head>',
            '<head><meta http-equiv="Content-Security-Policy" content="$_csp">',
          )
        : '<meta http-equiv="Content-Security-Policy" content="$_csp">$html';

    // Write secured version next to original
    final securedFile = File(
      p.join(p.dirname(file.path), '.sandboxed_${p.basename(file.path)}'),
    );
    await securedFile.writeAsString(secured);
    await _controller.loadFile(securedFile.path);
  }

  void _toggleSandbox() {
    setState(() => _sandboxed = !_sandboxed);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.site.title),
        actions: [
          IconButton(
            icon: Icon(_sandboxed ? Icons.lock : Icons.lock_open),
            tooltip: _sandboxed ? 'Network restricted' : 'Network allowed',
            onPressed: _toggleSandbox,
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
