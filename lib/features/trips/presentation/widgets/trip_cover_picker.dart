import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vievu/core/utils/image_picker.dart';

class TripCoverPicker extends StatefulWidget {
  final File? image;
  final String coverImage;
  final Function(File) onImageSelected;
  const TripCoverPicker(
      {super.key,
      required this.onImageSelected,
      this.image,
      required this.coverImage});

  @override
  State<TripCoverPicker> createState() => _TripCoverPickerState();
}

class _TripCoverPickerState extends State<TripCoverPicker> {
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
        radius: const Radius.circular(10),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        child: SizedBox(
            height: 200,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: widget.image != null
                  ? Image.file(
                      widget.image!,
                      fit: BoxFit.cover,
                    )
                  : widget.coverImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.coverImage,
                          fit: BoxFit.cover,
                          cacheManager: CacheManager(
                            Config(
                              widget.coverImage,
                              stalePeriod: const Duration(seconds: 30),
                            ),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 40,
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Select your image',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
            )),
      ),
    );
  }
}
