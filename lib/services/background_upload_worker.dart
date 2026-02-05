import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'photo_service.dart';

const uploadTask = "backgroundUploadTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case uploadTask:
        try {
          await PhotoService.uploadImagesToServer(null, silent: true);
          return Future.value(true);
        } catch (e) {
          return Future.value(false);
        }
      default:
        return Future.value(false);
    }
  });
}
