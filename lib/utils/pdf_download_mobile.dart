import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadPdfWeb(Uint8List bytes, String fileName, BuildContext context) async {
  throw UnsupportedError('Web PDF download not supported on mobile platforms');
}

Future<void> savePdfMobile(Uint8List bytes, String fileName, BuildContext context) async {
  print('🔧 Debug: Saving PDF to mobile documents directory...');
  
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsBytes(bytes);
    
    print('🔧 Debug: PDF saved successfully to ${file.path}');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exported successfully to: $fileName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    print('🔧 Debug: Mobile PDF save error: $e');
    rethrow;
  }
}