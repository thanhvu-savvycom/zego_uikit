// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

export 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(Permission permission) async {
  var status = await permission.request();
  if (status != PermissionStatus.granted) {
    debugPrint(
        'Error: ${permission.toString()} permission not granted, $status');
    return false;
  }

  return true;
}
