import 'package:flutter/widgets.dart';
import 'package:vievu/features/user_preference/domain/entities/travel_type.dart';
import 'package:vievu/features/user_preference/presentation/widgets/budget.dart';
import 'package:vievu/features/user_preference/presentation/widgets/child_travel_types.dart';
import 'package:vievu/features/user_preference/presentation/widgets/parent_travel_types.dart';

class PreferencesInquiry extends StatelessWidget {
  final int currentStep;
  final List<TravelType> parentTravelTypes;
  final List<TravelType> childTravelTypes;
  final double budget;
  final Function onTravelTypesChanged;
  final Function onBudgetChanged;
  const PreferencesInquiry(
      {super.key,
      required this.currentStep,
      required this.parentTravelTypes,
      required this.childTravelTypes,
      required this.budget,
      required this.onTravelTypesChanged,
      required this.onBudgetChanged});

  @override
  Widget build(BuildContext context) {
    if (currentStep == 0) {
      return ParentTravelTypes(
        travelTypesList: parentTravelTypes,
        onTravelTypesChanged: onTravelTypesChanged,
      );
    } else if (currentStep == 1) {
      return ChildTravelTypes(
        parentTravelTypesList: parentTravelTypes,
        childTravelTypesList: childTravelTypes,
        onTravelTypesChanged: onTravelTypesChanged,
      );
    } else {
      return Budget(
        budget: budget,
        onBudgetChanged: onBudgetChanged,
      );
    }
  }
}
