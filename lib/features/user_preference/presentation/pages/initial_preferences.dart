import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:vievu/authenticated_view.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/common/widgets/loader.dart';
import 'package:vievu/core/utils/generate_pref_map.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/user_preference/domain/entities/travel_type.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/user_preference/presentation/widgets/preferences_inquiry.dart';

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
  final preferenceInquiryHeadlines = [
    "Bạn thích loại hình du lịch nào?",
    "Hãy cho chúng tôi biết rõ hơn.",
    "Bạn muốn du lịch với chi phí?",
    "Cảm ơn vì đã chia sẻ với chúng tôi🎉"
  ];

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
                  context,
                  MaterialPageRoute(builder: (_) => const AuthenticatedView()),
                  (route) => false);
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
                  steps: _stepList(),
                  onStepReached: (index) =>
                      setState(() => _currentStep = index),
                ),
                Text(
                  preferenceInquiryHeadlines[_currentStep],
                  style: const TextStyle(
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
                          child: PreferencesInquiry(
                            currentStep: _currentStep,
                            parentTravelTypes: _parentTravelTypes,
                            childTravelTypes: _childTravelTypes,
                            budget: budget,
                            onTravelTypesChanged: () => setState(() {}),
                            onBudgetChanged: (value) => setState(() {
                              budget = value;
                            }),
                          ),
                        )
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
                          onPressed: _handleNextButton(),
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

  VoidCallback? _handleNextButton() {
    if (_isButtonEnabled() == false) {
      return null;
    }

    if (_currentStep == 3) {
      return () {
        final userId =
            (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
        context.read<PreferencesBloc>().add(InsertPreference(
            userId: userId,
            avgRating: 0,
            budget: budget,
            ratingCount: 0,
            prefsDF: generatePref(travelTypes: _childTravelTypes, point: 3)));
      };
    } else {
      return () {
        setState(() {
          _currentStep++;
        });
      };
    }
  }

  bool _isButtonEnabled() {
    if (_currentStep == 0 && _parentTravelTypes.isEmpty) {
      return false;
    }
    if (_currentStep == 1 && _childTravelTypes.isEmpty) {
      return false;
    }
    if (_currentStep == 2 && budget == 0) {
      return false;
    }
    return _currentStep <= _stepList().length - 1;
  }

  List<EasyStep> _stepList() => [
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
