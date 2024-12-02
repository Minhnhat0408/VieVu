import 'package:flutter/material.dart';
import 'package:easy_stepper/easy_stepper.dart';

class InitialPreferences extends StatefulWidget {
  const InitialPreferences({super.key});

  @override
  State<InitialPreferences> createState() => _InitialPreferencesState();
}

class _InitialPreferencesState extends State<InitialPreferences> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 64.0,
          left: 24.0,
          right: 24.0,
        ),
        child: Column(
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
              activeStepBackgroundColor: Theme.of(context).colorScheme.primary,
              stepAnimationDuration: const Duration(milliseconds: 1000),
              finishedStepBackgroundColor:
                  Theme.of(context).colorScheme.primary,
              unreachedStepBackgroundColor:
                  Theme.of(context).colorScheme.surfaceDim,
              showStepBorder: false,
              steps: stepList(),
              onStepReached: (index) => setState(() => _currentStep = index),
            ),
            const Text(
              "Bạn thích loại hình du lịch nào?",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(10, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        iconAlignment: IconAlignment.end,
                        child: const Text(
                          'Du lịch',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  }),
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
                      onPressed: _currentStep > 0
                          ? () {
                              setState(() {
                                _currentStep--;
                              });
                            }
                          : null,
                      child: const Text('Back', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        disabledBackgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        disabledForegroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      onPressed: _currentStep < stepList().length - 1
                          ? () {
                              setState(() {
                                _currentStep++;
                              });
                            }
                          : null,
                      child: const Text('Next', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
