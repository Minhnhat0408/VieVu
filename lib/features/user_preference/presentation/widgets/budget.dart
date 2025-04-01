import 'package:flutter/material.dart';
import 'package:vievu/features/user_preference/presentation/widgets/preferences_option.dart';

class Budget extends StatelessWidget {
  final double budget;
  final Function onBudgetChanged;
  const Budget(
      {super.key, required this.budget, required this.onBudgetChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      PrefOption(
        title: '0 - 1,000,000 VND',
        isSelected: budget == 0.3,
        onTap: () {
          onBudgetChanged(0.3);
        },
      ),
      PrefOption(
        title: '1,000,000 - 5,000,000 VND',
        isSelected: budget == 0.6,
        onTap: () {
          onBudgetChanged(0.6);
        },
      ),
      PrefOption(
        title: '> 5,000,000 VND',
        isSelected: budget == 0.9,
        onTap: () {
          onBudgetChanged(0.9);
        },
      ),
    ]);
  }
}
