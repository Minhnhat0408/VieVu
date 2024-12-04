import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/common/widgets/loader.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/settings/presentation/pages/settings.dart';
import 'package:vn_travel_companion/features/user_preference/data/models/preference_model.dart';
import 'package:vn_travel_companion/features/user_preference/domain/entities/travel_type.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/bloc/preference/preference_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/widgets/budget.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/widgets/child_travel_types.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/widgets/parent_travel_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitialPreferences extends StatefulWidget {
  const InitialPreferences({super.key});

  @override
  State<InitialPreferences> createState() => _InitialPreferencesState();
}

class _InitialPreferencesState extends State<InitialPreferences> {
  int _currentStep = 0;
  final List<TravelType> _parentTravelTypes = [];
  final List<TravelType> _childTravelTypes = [];
  double budget = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 64.0,
          left: 24.0,
          right: 24.0,
        ),
        child: BlocConsumer<PreferencesBloc, PreferencesState>(
          listener: (context, state) {
            if (state is PreferencesFailure) {
              showSnackbar(context, state.message);
            } else if (state is PreferencesLoadedSuccess) {
              Navigator.pushAndRemoveUntil(
                  context, SettingsPage.route(), (route) => false);
            }
          },
          builder: (context, state) {
            if (state is PreferencesLoading) {
              return const Loader();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EasyStepper(
                  activeStep: _currentStep,
                  lineStyle: LineStyle(
                    lineLength: 80,
                    lineThickness: 4,
                    lineSpace: 4,
                    lineType: LineType.dotted,
                    defaultLineColor: Theme.of(context).colorScheme.surfaceDim,
                    finishedLineColor: Theme.of(context).colorScheme.primary,
                  ),
                  borderThickness: 3,
                  disableScroll: true,
                  internalPadding: 0,
                  showLoadingAnimation: false,
                  stepRadius: 14,
                  activeStepBackgroundColor:
                      Theme.of(context).colorScheme.primary,
                  stepAnimationDuration: const Duration(milliseconds: 1000),
                  finishedStepBackgroundColor:
                      Theme.of(context).colorScheme.primary,
                  unreachedStepBackgroundColor:
                      Theme.of(context).colorScheme.surfaceDim,
                  showStepBorder: false,
                  steps: stepList(),
                  onStepReached: (index) =>
                      setState(() => _currentStep = index),
                ),
                _currentStep == 0
                    ? const Text(
                        "Bạn thích loại hình du lịch nào?",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : _currentStep == 1
                        ? const Text(
                            "Hãy cho chúng tôi biết rõ hơn.",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : _currentStep == 2
                            ? const Text(
                                "Bạn muốn du lịch với chi phí?",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Text(
                                "Cảm ơn vì đã chia sẻ với chúng tôi🎉",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                _currentStep == 3
                    ? const SizedBox.shrink()
                    : const SizedBox(height: 32),
                Expanded(
                  child: _currentStep < 3
                      ? SingleChildScrollView(
                          child: _currentStep == 0
                              ? ParentTravelTypes(
                                  travelTypesList: _parentTravelTypes,
                                  onTravelTypesChanged: () => setState(() {}),
                                )
                              : _currentStep == 1
                                  ? ChildTravelTypes(
                                      parentTravelTypesList: _parentTravelTypes,
                                      childTravelTypesList: _childTravelTypes,
                                      onTravelTypesChanged: () =>
                                          setState(() {}),
                                    )
                                  : Budget(
                                      budget: budget,
                                      onBudgetChanged: (value) => setState(() {
                                        // Update budget
                                        budget = value;
                                      }),
                                    ))
                      : Center(
                          child: Image.asset(
                            'assets/images/celeb1.png',
                            width: 650,
                            height: 650,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _currentStep > 0
                              ? () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                }
                              : null,
                          child: const Text('Quay lại',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            disabledForegroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                          onPressed: _isButtonEnabled()
                              ? _currentStep == 3
                                  ? () {
                                      final userId = (context
                                              .read<AppUserCubit>()
                                              .state as AppUserLoggedIn)
                                          .user
                                          .id;
                                      context.read<PreferencesBloc>().add(
                                          InsertPreference(
                                              userId: userId,
                                              avgRating: 0,
                                              budget: budget,
                                              ratingCount: 0,
                                              prefsDF:
                                                  PreferenceModel.generatePref(
                                                      travelTypes:
                                                          _childTravelTypes,
                                                      point: 3)));
                                    }
                                  : () {
                                      setState(() {
                                        _currentStep++;
                                      });
                                    }
                              : null,
                          child: Text(
                              _currentStep == 3 ? 'Khám phá' : 'Tiếp theo',
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isButtonEnabled() {
    if (_currentStep == 0 && _parentTravelTypes.isEmpty) {
      return false;
    }
    if (_currentStep == 1 && _childTravelTypes.isEmpty) {
      return false;
    }
    return _currentStep <= stepList().length - 1;
  }

  List<EasyStep> stepList() => [
        EasyStep(
          customStep: CircleAvatar(
            backgroundColor: _currentStep >= 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceDim,
            child: Center(
              child: _currentStep > 0
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : Text(
                      '1',
                      style: TextStyle(
                        color: _currentStep >= 0
                            ? Colors.white
                            : Colors.black, // Adjust text color as needed
                        fontSize:
                            14, // Adjust the font size for better visibility
                      ),
                    ),
            ),
          ),
        ),
        EasyStep(
          customStep: CircleAvatar(
            backgroundColor: _currentStep >= 1
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceDim,
            child: Center(
              child: _currentStep > 1
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : Text(
                      '2',
                      style: TextStyle(
                        color: _currentStep >= 1
                            ? Colors.white
                            : Colors.black, // Adjust text color as needed
                        fontSize:
                            14, // Adjust the font size for better visibility
                      ),
                    ),
            ),
          ),
        ),
        EasyStep(
          customStep: CircleAvatar(
            backgroundColor: _currentStep >= 2
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceDim,
            child: Center(
              child: _currentStep > 2
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : Text(
                      '3',
                      style: TextStyle(
                        color: _currentStep >= 1
                            ? Colors.white
                            : Colors.black, // Adjust text color as needed
                        fontSize:
                            14, // Adjust the font size for better visibility
                      ),
                    ),
            ),
          ),
        ),
        EasyStep(
          customStep: CircleAvatar(
            backgroundColor: _currentStep >= 3
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceDim,
            child: const Center(
                child: Icon(
              Icons.star,
              color: Colors.white,
              size: 18,
            )),
          ),
        ),
      ];
}
