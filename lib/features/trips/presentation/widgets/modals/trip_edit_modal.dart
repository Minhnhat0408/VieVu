import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:vn_travel_companion/core/constants/transport_options.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/image_picker.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/core/utils/validators.dart';
import 'package:vn_travel_companion/features/trips/domain/entities/trip.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vn_travel_companion/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vn_travel_companion/features/trips/presentation/widgets/trip_cover_picker.dart';

class TripEditModal extends StatefulWidget {
  final Trip trip;
  const TripEditModal({
    super.key,
    required this.trip,
  });

  @override
  State<TripEditModal> createState() => _TripEditModalState();
}

class _TripEditModalState extends State<TripEditModal> {
  final descriptionController = TextEditingController();
  final maxMemberController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTimeRange? selectedDateRange;
  final controller = MultiSelectController<TransportOption>();
  File? image;
  String coverImage = "";

  void selectImage() async {
    log("Select image");
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

  final List<DropdownItem<TransportOption>> items = transportOptions.map(
    (option) {
      return DropdownItem(
        label: option.label,
        value: option,
      );
    },
  ).toList();

  @override
  void initState() {
    super.initState();
    var tripTmp = widget.trip;

    nameController.text = tripTmp.name;
    descriptionController.text = tripTmp.description ?? "";
    selectedDateRange = tripTmp.startDate != null
        ? DateTimeRange(
            start: tripTmp.startDate!,
            end: tripTmp.endDate!,
          )
        : null;
    if (tripTmp.transports != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectWhere(
          (option) => tripTmp.transports!.contains(option.value.value),
        );
      });
    }
    log(tripTmp.maxMember.toString());
    maxMemberController.text = tripTmp.maxMember?.toString() ?? "";
    coverImage = tripTmp.cover ?? "";
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    maxMemberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      appBarTitle: 'Chỉnh sửa chuyến đi',
      centerTitle: true,
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state is TripActionSuccess) {
            Navigator.of(context).pop();
          }

          if (state is TripLoadedFailure) {
            showSnackbar(context, state.message, SnackBarState.error);
          }
        },
        builder: (context, state) => Stack(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 70),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lưu ý: Cập nhật tất cả thông tin không bắt buộc để công khai chuyến đi của bạn',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ảnh bìa', // Label always on top
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    TripCoverPicker(
                      image: image,
                      coverImage: coverImage,
                      onImageSelected: (file) {
                        setState(() {
                          image = file;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Tên chuyến đi', // Label always on top
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(*)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 8), // Space between label and input box
                        TextFormField(
                          controller: nameController,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            hintText: 'Hãy đặt tên cho chuyến đi của bạn',
                          ),
                          maxLength: 80,
                          validator: Validators.combineValidators(
                            [
                              Validators.checkEmpty,
                              Validators.check80Characters,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thời gian', // Label always on top
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(
                            height: 8), // Space between label and input box
                        OutlinedButton(
                          onPressed: () async {
                            bool answer = true;

                            if (widget.trip.hasTripItineraries) {
                              answer = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Thông báo'),
                                      content: const Text(
                                          'Chuyến đi đã có lịch trình, thay đổi thời gian có thể ảnh hưởng đến lịch trình của bạn. Bạn có chắc chắn muốn thay đổi không?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Tiếp tục'),
                                        ),
                                      ],
                                    );
                                  });
                            }
                            if (!answer) return;
                            final DateTimeRange? picked =
                                await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDateRange: selectedDateRange,
                              locale: const Locale('vi', 'VN'),
                            );
                            if (picked != null && picked != selectedDateRange) {
                              setState(() {
                                selectedDateRange = picked;
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                  selectedDateRange != null
                                      ? "${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)}-${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}"
                                      : 'Chọn thời gian',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)),
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
                          'Mô tả', // Label always on top
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(
                            height: 8), // Space between label and input box
                        TextFormField(
                          maxLines: 5,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            hintText: 'Hãy viết mô tả chuyến đi của bạn',
                          ),
                          validator: Validators.check1000Characters,
                          maxLength: 1000,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Số lượng thành viên', // Label always on top
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(
                            height: 8), // Space between label and input box
                        TextFormField(
                          controller: maxMemberController,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            hintText: 'Nhập số lượng thành viên tối đa',
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: Validators.checkZero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phương tiện', // Label always on top
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(
                            height: 8), // Space between label and input box

                        MultiDropdown<TransportOption>(
                          items: items,
                          controller: controller,
                          enabled: true,
                          chipDecoration: ChipDecoration(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            wrap: true,
                            runSpacing: 2,
                            spacing: 10,
                          ),
                          selectedItemBuilder: (item) {
                            return item.value.badge;
                          },
                          fieldDecoration: FieldDecoration(
                            hintText: 'Chọn phương tiện',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            prefixIcon: const Icon(Icons.connecting_airports),
                            showClearIcon: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2),
                            ),
                          ),
                          dropdownDecoration: DropdownDecoration(
                            marginTop: 2,
                            maxHeight: 500,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                            header: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Chọn phương tiện cho chuyến đi',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          dropdownItemDecoration: DropdownItemDecoration(
                            selectedIcon: const Icon(Icons.check_box,
                                color: Colors.green),
                            disabledIcon:
                                Icon(Icons.lock, color: Colors.grey.shade300),
                            selectedBackgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          onSelectionChange: (selectedItems) {
                            debugPrint("OnSelectionChange: $selectedItems");
                          },
                        ),
                      ],
                    ),
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              onPressed: () {
                if (formKey.currentState!.validate() &&
                    state is! TripActionLoading) {
                  // check if anything changed
                  final tripTmp = (context.read<TripDetailsCubit>().state
                          as TripDetailsLoadedSuccess)
                      .trip;

                  if (nameController.text == tripTmp.name &&
                      descriptionController.text ==
                          (tripTmp.description ?? "") &&
                      selectedDateRange ==
                          (tripTmp.startDate != null
                              ? DateTimeRange(
                                  start: tripTmp.startDate!,
                                  end: tripTmp.endDate!,
                                )
                              : null) &&
                      listEquals(
                          controller.selectedItems
                              .map((e) => e.value.value)
                              .toList(),
                          tripTmp.transports) &&
                      image == null &&
                      maxMemberController.text ==
                          (tripTmp.maxMember?.toString() ?? "")) {
                    showSnackbar(
                        context,
                        'Không có thay đổi nào được thực hiện',
                        SnackBarState.warning);
                    return;
                  }

                  context.read<TripBloc>().add(
                        UpdateTrip(
                            description:
                                descriptionController.text.trim().isEmpty
                                    ? null
                                    : descriptionController.text,
                            startDate: selectedDateRange?.start,
                            endDate: selectedDateRange?.end,
                            transports: controller.selectedItems.isEmpty
                                ? null
                                : controller.selectedItems
                                    .map((e) => e.value.value)
                                    .toList(),
                            cover: image,
                            name: nameController.text,
                            tripId: (context.read<TripDetailsCubit>().state
                                    as TripDetailsLoadedSuccess)
                                .trip
                                .id,
                            maxMember: maxMemberController.text.isNotEmpty
                                ? int.parse(maxMemberController.text)
                                : null),
                      );
                }
              },
              child: state is! TripActionLoading
                  ? const Text('Lưu thay đổi',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
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
        ]),
      ),
    );
  }
}
