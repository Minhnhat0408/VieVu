// filepath: d:\Mobile\flutter\vn_travel_companion\lib\core\utils\image_picker.dart
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart'; 
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart'; 

Future<File?> pickImage() async {
  try {
    log('Attempting to pick image...');

    PermissionStatus status;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 33) { 
      log('Requesting Permission.photos for Android 13+');
      status = await Permission.photos.request();
    } else { 
      log('Requesting Permission.storage for Android < 13');
      status = await Permission.storage.request();
    }

    log('Permission status: $status');

    if (status.isPermanentlyDenied) {
      log('Quyền truy cập bị từ chối vĩnh viễn. Mở cài đặt ứng dụng.');
 
      await openAppSettings();
      return null;
    }

    if (!status.isGranted) {
      log('Quyền truy cập không được cấp. Status: $status');
   
      return null;
    }

    log('Quyền đã được cấp. Đang chọn ảnh từ thư viện...');
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (xFile != null) {
      log('Ảnh đã được chọn: ${xFile.path}. Đang cắt ảnh...');
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: xFile.path,

        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Chỉnh sửa ảnh',
              toolbarColor: Color(0xff607d41),
              toolbarWidgetColor: Colors.white,
              activeControlsWidgetColor: Color(0xff607d41),
              // initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Chỉnh sửa ảnh',
            aspectRatioLockEnabled: false,
          ),
        ],
      );
      if (croppedFile == null) {
        log('Việc cắt ảnh bị hủy bởi người dùng.');
        return null;
      }
      log('Ảnh đã được cắt: ${croppedFile.path}');
      return File(croppedFile.path);
    } else {
      log('Việc chọn ảnh bị hủy bởi người dùng.');
    }
  } catch (e, s) {
    log('Lỗi khi chọn/cắt ảnh: $e\n$s');
    return null;
  }
  return null;
}