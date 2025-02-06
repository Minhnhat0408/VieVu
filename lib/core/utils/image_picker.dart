import 'dart:developer';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImage() async {
  try {
    log('pickImage');
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (xFile != null) {
      return File(xFile.path);
    }
    log('pickImage: null');
    return null;
  } catch (e) {
    return null;
  }
}
