import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

Future<void> downloadPdfWeb(Uint8List bytes, String fileName, BuildContext context) async {
  print('🔧 Debug: Triggering PDF download for web...');
  
  try {
    // Create blob and download link for web
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    
    // Add to document body, click, and remove
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    
    print('🔧 Debug: PDF download triggered successfully');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF download started: $fileName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    print('🔧 Debug: Web PDF download error: $e');
    rethrow;
  }
}

Future<void> savePdfMobile(Uint8List bytes, String fileName, BuildContext context) async {
  throw UnsupportedError('Mobile PDF save not supported on web platforms');
}