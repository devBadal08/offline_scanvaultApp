import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photomanager_practice/screen/scan_screen.dart';
import 'package:photomanager_practice/services/photo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

class BottomTabs extends StatelessWidget {
  final TabController? controller;
  final bool showCamera;
  final bool cameraDisabled;
  final bool scanDisabled;
  final void Function(int)? onCreateFolder;
  final VoidCallback? onCameraTap;
  final VoidCallback? onScanTap;
  final VoidCallback? onUploadTap;
  final VoidCallback? onUploadComplete;

  static ValueNotifier<Set<String>> uploadedFiles = ValueNotifier<Set<String>>(
    {},
  );

  static Future<void> loadUploadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('uploaded_files') ?? [];
    uploadedFiles.value = saved.toSet();
  }

  static Future<void> saveUploadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('uploaded_files', uploadedFiles.value.toList());
  }

  final String userId;
  final String folderName;

  BottomTabs({
    super.key,
    this.controller,
    this.showCamera = true,
    this.cameraDisabled = false,
    this.scanDisabled = false,
    this.onCreateFolder,
    this.onCameraTap,
    this.onScanTap,
    this.onUploadTap,
    this.onUploadComplete,
    required this.userId,
    required this.folderName,
  });

  bool isImage(String filePath) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'docx'];
    final extension = filePath.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.path,
      "${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}",
    );

    final XFile? compressedXFile =
        await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: 85,
        );

    if (compressedXFile == null) {
      throw Exception("Image compression failed");
    }

    return File(compressedXFile.path);
  }

  @override
  Widget build(BuildContext context) {
    final tabController = controller ?? DefaultTabController.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: TabBar(
        controller: tabController,
        onTap: (index) async {
          if (index == 1) {
            // Upload tab
            _resetTab(tabController);
            if (onUploadTap != null) {
              onUploadTap!();
            } else {
              await PhotoService.uploadImagesToServer(null, context: context);
            }
            return;
          }

          if (index == 2) {
            // Scan tab
            if (scanDisabled) {
              _resetTab(tabController);
              return;
            }

            _resetTab(tabController);

            if (onScanTap != null) {
              onScanTap!(); // ✅ Now PhotoListScreen._openScanScreen() runs
            } else {
              // fallback if no callback passed
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ScanScreen(userId: userId, folderName: folderName),
                ),
              );
            }
            return;
          }

          if (index == 3) {
            // Camera tab
            if (cameraDisabled) {
              _resetTab(tabController);
              return;
            }
            if (showCamera && onCameraTap != null) {
              onCameraTap!();
              _resetTab(tabController);
              return;
            }
          }

          if (index == 4 && onCreateFolder != null) {
            print("CREATE TAB CLICKED");

            onCreateFolder!(index);

            print("CREATE CALLBACK EXECUTED");

            _resetTab(tabController);
            return;
          }

          controller?.index = index;
        },
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface,
        indicatorColor: colorScheme.primary,
        tabs: [
          const Tab(
            icon: Icon(Icons.folder),
            child: const Text(
              'Folder',
              style: TextStyle(
                fontSize: 12, // ✅ set your desired size
                fontWeight: FontWeight.bold, // optional
              ),
            ),
          ),
          const Tab(
            icon: Icon(Icons.cloud_upload),
            child: const Text(
              'Upload',
              style: TextStyle(
                fontSize: 12, // ✅ set your desired size
                fontWeight: FontWeight.bold, // optional
              ),
            ),
          ),
          if (showCamera)
            Tab(
              icon: Icon(
                Icons.document_scanner,
                color: scanDisabled ? Colors.grey : null,
              ),
              child: const Text(
                'Scan',
                style: TextStyle(
                  fontSize: 12, // ✅ set your desired size
                  fontWeight: FontWeight.bold, // optional
                ),
              ),
            ),
          Tab(
            icon: Icon(
              Icons.camera_alt,
              color: cameraDisabled ? Colors.grey : null,
            ),
            child: const Text(
              'Camera',
              style: TextStyle(
                fontSize: 11, // ✅ set your desired size
                fontWeight: FontWeight.bold, // optional
              ),
            ),
          ),
          const Tab(
            icon: Icon(Icons.create_new_folder),
            child: const Text(
              'Create',
              style: TextStyle(
                fontSize: 12, // ✅ set your desired size
                fontWeight: FontWeight.bold, // optional
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetTab(TabController controller) {
    Future.microtask(() {
      controller.index = 0;
    });
  }
}
