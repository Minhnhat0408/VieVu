import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class TripCoverPicker extends StatefulWidget {
  final Function(File?) onAvatarSelected;

  const TripCoverPicker({super.key, required this.onAvatarSelected});

  @override
  State<TripCoverPicker> createState() => _TripCoverPickerState();
}

class _TripCoverPickerState extends State<TripCoverPicker> {
  File? _avatarImage;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _avatarImage = File(pickedFile.path);
        widget.onAvatarSelected(_avatarImage); // Notify parent widget
      } else {
        log('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              _avatarImage != null ? FileImage(_avatarImage!) : null,
          child: _avatarImage == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text('Gallery'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text('Camera'),
            ),
          ],
        ),
        if (_avatarImage != null) ...[
          const SizedBox(height: 10),
          Text(_avatarImage!.path), // Display the path (optional)

          // Optional: Add a button to remove the selected avatar
          ElevatedButton(
            onPressed: () {
              setState(() {
                _avatarImage = null;
                widget.onAvatarSelected(null); // Notify parent widget
              });
            },
            child: const Text('Remove'),
          ),
        ],
      ],
    );
  }
}
