import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/attraction_details_page.dart';
import 'package:vn_travel_companion/features/explore/presentation/pages/explore_main_page.dart';
import 'package:vn_travel_companion/features/trips/presentation/bloc/saved_service_bloc.dart';

class ExploreNestedRoutes extends StatelessWidget {
  const ExploreNestedRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: MaterialApp.createMaterialHeroController(),
      child: BlocListener<SavedServiceBloc, SavedServiceState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is SavedServiceActionSucess) {
            showSavedChangeSuccess(context, 'Lưu thành công');
          }

          if (state is SavedServiceDeleteSuccess) {
            showSavedChangeSuccess(context, 'Xóa thành công');
          }
        },
        child: Navigator(
          onGenerateRoute: (RouteSettings settings) {
            Widget page;
            switch (settings.name) {
              case '/attraction':
                final attractionId = settings.arguments as int;
                page = AttractionDetailPage(attractionId: attractionId);
              default:
                page = const ExploreMainPage();
            }

            return MaterialPageRoute(builder: (_) => page);
          },
        ),
      ),
    );
  }
}

void showSavedChangeSuccess(context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
}
