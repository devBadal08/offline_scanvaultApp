import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class BackupService {
  static Future<void> backupAllPhotos(
    BuildContext context,
    Directory sourceDir,
  ) async {
    try {
      if (!await sourceDir.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No photos found to backup")),
        );
        return;
      }

      // Ask user to pick destination folder
      String? selectedPath = await FilePicker.platform.getDirectoryPath();

      if (selectedPath == null) {
        // User cancelled
        return;
      }

      final targetDir = Directory(selectedPath);

      int copied = 0;

      await for (final entity in sourceDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = entity.path.replaceFirst(sourceDir.path, '');
          final newFile = File('${targetDir.path}/$relativePath');

          await newFile.parent.create(recursive: true);
          await entity.copy(newFile.path);

          copied++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Backup completed. $copied media items copied")),
      );
    } catch (e) {
      debugPrint("❌ Backup error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Backup failed")));
    }
  }

  static Future<void> backupSelectedPhotos(
    BuildContext context,
    List<String> selectedPaths,
  ) async {
    try {
      if (selectedPaths.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No photos selected")));
        return;
      }

      // Ask user to choose backup location
      String? selectedDir = await FilePicker.platform.getDirectoryPath();

      if (selectedDir == null) return;

      final targetDir = Directory(selectedDir);

      int copied = 0;

      for (final path in selectedPaths) {
        // Skip network images
        if (path.startsWith("http")) continue;

        final file = File(path);

        if (!await file.exists()) continue;

        final fileName = file.path.split('/').last;
        final newFile = File('${targetDir.path}/$fileName');

        await newFile.parent.create(recursive: true);
        await file.copy(newFile.path);

        copied++;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$copied media items backed up")));
    } catch (e) {
      debugPrint("❌ Backup selected error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Backup failed")));
    }
  }
}
