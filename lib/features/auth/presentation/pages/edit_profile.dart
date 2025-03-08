import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:vn_travel_companion/core/constants/vn_province.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/image_picker.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/core/utils/validators.dart';
import 'package:vn_travel_companion/features/auth/domain/entities/user.dart';
import 'package:vn_travel_companion/features/auth/presentation/bloc/profile_bloc.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/avatar_picker.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? image;
  String coverImage = "";
  final phoneController = TextEditingController();
  String? selectedGender;
  final TextEditingController _provinceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.user.firstName;
    lastNameController.text = widget.user.lastName;
    descriptionController.text = widget.user.bio ?? "";
    phoneController.text = widget.user.phoneNumber ?? "";
    coverImage = widget.user.avatarUrl ?? "";
    selectedGender = widget.user.gender;
    log(widget.user.city ?? "");
    _provinceController.text = widget.user.city ?? "";
  }

  void selectImage() async {
    final pickedImage = await pickImage();

    if (pickedImage != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      setState(() {
        if (croppedFile == null) return;
        image = File(croppedFile.path);
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: 'Chỉnh sửa hồ sơ',
      centerTitle: true,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            Navigator.of(context).pop();
          }

          if (state is ProfileFailure) {
            showSnackbar(context, state.message, SnackBarState.error);
          }
        },
        builder: (context, state) {
          return Stack(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 70),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ảnh đại diện', // Label always on top
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: AvatarPicker(
                          image: image,
                          coverImage: coverImage,
                          onImageSelected: (file) {
                            setState(() {
                              image = file;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            // Ensure it takes up available space
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Họ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(*)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: lastNameController,
                                  onChanged: (value) => setState(() {}),
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    hintText: 'Nhập họ của bạn',
                                  ),
                                  validator: Validators.combineValidators(
                                    [
                                      Validators.checkEmpty,
                                      Validators.check80Characters
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Tên',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(*)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller:
                                      firstNameController, // Change to first name
                                  onChanged: (value) => setState(() {}),
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    hintText: 'Nhập tên của bạn',
                                  ),
                                  validator: Validators.combineValidators(
                                    [
                                      Validators.checkEmpty,
                                      Validators.check80Characters
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tỉnh/Thành phố', // Label always on tops
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return vietnamProvinces.where((String option) {
                                return option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            initialValue: _provinceController.value,
                            onSelected: (String selection) {
                              setState(() {
                                _provinceController.text = selection;
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode,
                                onEditingComplete) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                onTapOutside: (event) => focusNode.unfocus(),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  hintText: 'Nhâp tỉnh/thành phố',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mô tả', // Label always on top
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(
                              height: 8), // Space between label and input box
                          TextFormField(
                            onChanged: (value) => setState(() {}),
                            maxLines: 5,
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              hintText: 'Hãy viết mô tả về bản thân bạn',
                            ),
                            validator: Validators.check1000Characters,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${descriptionController.text.length}/1000", // Label always on top
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giới tính', // Label
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(
                                    height: 8), // Space between label and input
                                DropdownButtonFormField<String>(
                                  value: selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Nam',
                                        child: Row(
                                          children: [
                                            Text('Nam'),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.male,
                                              color: Colors.blue,
                                            )
                                          ],
                                        )),
                                    DropdownMenuItem(
                                        value: 'Nữ',
                                        child: Row(
                                          children: [
                                            Text('Nữ'),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.female,
                                              color: Colors.pink,
                                            ),
                                          ],
                                        )),
                                    DropdownMenuItem(
                                        value: 'Khác', child: Text('Khác')),
                                  ],
                                  validator: (value) => value == null
                                      ? 'Vui lòng chọn giới tính'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Số điện thoại', // Label always on top
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        8), // Space between label and input box
                                TextFormField(
                                  controller: phoneController,
                                  onTapOutside: (event) =>
                                      FocusScope.of(context).unfocus(),
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),

                                    hintText: 'Nhập số điện thoại của bạn',
                                    prefixText:
                                        '+84 ', // Default country code (Vietnam)
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        10), // Restrict to 10 digits
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập số điện thoại';
                                    } else if (!RegExp(r'^(0\d{9})$')
                                        .hasMatch(value)) {
                                      return 'Số điện thoại không hợp lệ';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 20,
              right: 20,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate() &&
                      state is! ProfileActionLoading) {
                    // check if anything changed

                    if (firstNameController.text == widget.user.firstName &&
                        lastNameController.text == widget.user.lastName &&
                        descriptionController.text == widget.user.bio &&
                        phoneController.text == widget.user.phoneNumber &&
                        selectedGender == widget.user.gender &&
                        _provinceController.text == widget.user.city &&
                        image == null) {
                      showSnackbar(
                          context,
                          'Không có thay đổi nào được thực hiện',
                          SnackBarState.warning);
                      return;
                    }

                    context.read<ProfileBloc>().add(
                          UpdateProfile(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            bio: descriptionController.text,
                            phone: phoneController.text,
                            gender: selectedGender,
                            avatar: image,
                            city: _provinceController.text,
                          ),
                        );
                  }
                },
                child: state is! ProfileActionLoading
                    ? const Text('Lưu thay đổi',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Đang lưu thay đổi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ),
              ),
            )
          ]);
        },
      ),
    );
  }
}
