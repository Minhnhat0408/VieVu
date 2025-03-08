import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vn_travel_companion/core/utils/image_picker.dart';

class AvatarPicker extends StatefulWidget {
  final File? image;
  final String coverImage;
  final Function(File) onImageSelected;
  const AvatarPicker(
      {super.key,
      required this.onImageSelected,
      this.image,
      required this.coverImage});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  void selectImage() async {
    final pickedImage = await pickImage();

    if (pickedImage != null) {
      widget.onImageSelected(File(pickedImage.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectImage();
      },
      child: DottedBorder(
        color: Theme.of(context).colorScheme.primary,
        dashPattern: const [10, 4],
        borderType: BorderType.Circle,
        strokeCap: StrokeCap.round,
        child: CircleAvatar(
          radius: 70,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          foregroundImage: widget.image != null
              ? FileImage(widget.image!)
              : widget.coverImage.isNotEmpty
                  ? CachedNetworkImageProvider(
                      widget.coverImage,
                      cacheManager: CacheManager(
                        Config(
                          widget.coverImage,
                          stalePeriod: const Duration(seconds: 30),
                        ),
                      ),
                    )
                  : null,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera_front_outlined,
                size: 40,
              ),
              SizedBox(height: 5),
              Text(
                'Chọn ảnh',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
