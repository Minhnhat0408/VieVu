import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/utils/open_url.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vievu/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vievu/features/explore/presentation/pages/attraction_details_page.dart';
import 'package:vievu/features/explore/presentation/pages/location_detail_page.dart';
import 'package:vievu/features/explore/presentation/pages/all_nearby_service_page.dart';

import 'package:vievu/features/search/domain/entities/explore_search_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/search/presentation/bloc/search_bloc.dart';
import 'package:vievu/init_dependencies.dart';

class ExploreSearchItem extends StatelessWidget {
  final ExploreSearchResult? result;
  final Function changeSearchText;
  final bool isDetailed;

  const ExploreSearchItem({
    super.key,
    this.result,
    this.isDetailed = false,
    required this.changeSearchText,
  });

  Widget _getIconForType(String type) {
    switch (type) {
      case 'attractions':
        return const Icon(
          Icons.attractions,
          size: 30,
        );
      case 'locations':
        return const Icon(
          Icons.place,
          size: 30,
        );
      case 'keyword':
        return const Icon(
          Icons.search,
          size: 30,
        );
      case 'travel_types':
        return const Icon(
          Icons.terrain_outlined,
          size: 30,
        );
      default:
        return const FaIcon(
          FontAwesomeIcons.locationArrow,
          size: 30,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('result: ${result?.title}');
    return InkWell(
      onTap: () async {
        // Navigate to the detail page
        if (result == null) {
          LocationPermission permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            showSnackbar(context, 'Vui lòng bật dịch vụ định vị để sử dụng',SnackBarState.warning);
            return;
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) => serviceLocator<NearbyServicesCubit>(),
                    ),
                    BlocProvider(
                      create: (_) => serviceLocator<LocationInfoCubit>(),
                    ),
                  ],
                  child: const AllNearbyServicePage(),
                ),
              ),
            );
          }
        }

        final userId =
            (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
        if (result?.type == 'event') {
          context.read<SearchBloc>().add(SearchHistory(
                cover: result!.cover,
                userId: userId,
                title: result!.title,
                address: result!.address,
                externalLink: result!.externalLink,
                linkId: result!.id,
              ));

          openDeepLink(result!.externalLink!);
        } else if (result?.type == 'attractions') {
          context.read<SearchBloc>().add(SearchHistory(
                cover: result!.cover,
                userId: userId,
                title: result!.title,
                address: result!.address,
                linkId: result!.id,
              ));

          //  final currentPref = (context.read<PreferencesBloc>().state
          //             as PreferencesLoadedSuccess)
          //         .preference;
          //     for (var item in state.attraction.travelTypes ?? []) {
          //       context.read<PreferencesBloc>().add(UpdatePreferenceDF(
          //           travelType:
          //               item is String ? item : item['type_name'] as String,
          //           currentPref: currentPref,
          //           action: 'view'));
          //     }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AttractionDetailPage(
                        attractionId: result!.id,
                        isSearch: true,
                      )));
        } else if (result?.type == 'hotel' ||
            result?.type == 'restaurant' ||
            result?.type == 'shop') {
          // check if result.id contains http or https if not add https://vn.trip.com
          if (result!.externalLink!.contains('http') ||
              result!.externalLink!.contains('https')) {
            openDeepLink(result!.externalLink!);

            context.read<SearchBloc>().add(SearchHistory(
                  cover: result!.cover,
                  userId: userId,
                  title: result!.title,
                  address: result!.address,
                  externalLink: result!.externalLink,
                  linkId: result!.id,
                ));
          } else {
            openDeepLink('https://vn.trip.com${result!.id}');
            context.read<SearchBloc>().add(SearchHistory(
                  cover: result!.cover,
                  userId: userId,
                  title: result!.title,
                  address: result!.address,
                  externalLink: 'https://vn.trip.com${result!.externalLink}',
                  linkId: result!.id,
                ));
          }
        } else if (result?.type == 'locations') {
          context.read<SearchBloc>().add(SearchHistory(
                userId: userId,
                title: result!.title,
                address: result!.address,
                linkId: result!.id,
              ));
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LocationDetailPage(
              locationId: result!.id,
              locationName: result!.title,
            ),
          ));
        } else {
          context.read<SearchBloc>().add(SearchHistory(
                userId: userId,
                searchText: result!.title,
              ));
          changeSearchText(result!.title);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceBright,
                  width: 2.0,
                ),
              ),
              width: 80,
              height: 80,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: (result == null ||
                      (result!.type != 'attractions' &&
                          result!.type != 'event' &&
                          result!.type != 'hotel' &&
                          result!.type != 'restaurant' &&
                          result!.type != 'shop'))
                  ? _getIconForType(result == null ? 'nearby' : result!.type)
                  : CachedNetworkImage(
                      imageUrl: "${result!.cover}", // Use optimized size
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      fadeInDuration: Duration
                          .zero, // Remove fade-in animation for faster display
                      filterQuality: FilterQuality.low,
                      useOldImageOnUrlChange: true, // Avoid unnecessary reloads
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
            ),
            const SizedBox(width: 20),
            Expanded(
              // Ensure this widget allows text to take available space
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      result == null
                          ? 'Lân cận'
                          : result!.type == 'keyword'
                              ? '"${result!.title}"'
                              : result!.title,
                      minFontSize: 14, // Minimum font size to shrink to
                      maxLines: 2, // Allow up to 2 lines for wrapping
                      overflow: TextOverflow
                          .ellipsis, // Add ellipsis if it exceeds maxLines
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Default starting font size
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isDetailed &&
                        (result!.type == 'attractions' ||
                            result!.type == 'hotel' ||
                            result!.type == 'restaurant' ||
                            result!.type == 'shop'))
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: result?.avgRating ?? 0,
                            itemSize: 20,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, _) => Icon(
                              Icons.favorite,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                          ),
                          Text(
                            '(${result?.ratingCount ?? 0})',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 10),
                          if (result?.hotScore != null)
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.fire,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    result?.hotScore.toString() ?? '0',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    if (result != null && result!.address != null)
                      Text(
                        result!.address!,
                        softWrap: true, // Wrap the address to the next line
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
