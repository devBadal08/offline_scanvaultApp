import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path/path.dart' as p;

class PdfViewerScreen extends StatelessWidget {
  final dynamic pdfFile; // can be File or String (URL)
  final int? sharedFolderId;

  const PdfViewerScreen({
    super.key,
    required this.pdfFile,
    this.sharedFolderId,
  });

  @override
  Widget build(BuildContext context) {
    print("🧩 PdfViewerScreen received: ${pdfFile.runtimeType}");
    print("📁 sharedFolderId: $sharedFolderId");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pdfFile is File
              ? p.basename(pdfFile.path)
              : p.basename(pdfFile.toString()),
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (_) {
          try {
            if (pdfFile is File) {
              // ✅ Local PDF
              print("📂 Opening local PDF: ${pdfFile.path}");
              if (!pdfFile.existsSync()) {
                print("❌ Local file does not exist: ${pdfFile.path}");
                return const Center(
                  child: Text("❌ PDF file not found on device."),
                );
              }
              return SfPdfViewer.file(pdfFile);
            } else if (pdfFile is String && pdfFile.startsWith('http')) {
              // ✅ Shared PDF from server
              print("🌐 Opening PDF from URL: $pdfFile");
              return SfPdfViewer.network(pdfFile);
            } else {
              // ❌ Invalid case
              print("⚠️ Invalid PDF input: $pdfFile");
              return const Center(child: Text("❌ Invalid PDF file."));
            }
          } catch (e) {
            print("🔥 Error preparing PDF: $e");
            return Center(child: Text("⚠️ Error loading PDF: $e"));
          }
        },
      ),
    );
  }
}
