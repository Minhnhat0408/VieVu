import 'dart:developer';
import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  try {
    log('pickImage');
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (xFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: xFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            // toolbarColor: Colors.deepOrange,
            // toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );
      if (croppedFile == null) {
        return null;
      }
      return File(croppedFile.path);
    }
  } catch (e) {
    return null;
  }
  return null;
}
