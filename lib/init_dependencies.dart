import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vievu/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vievu/core/network/connection_checker.dart';
import 'package:vievu/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vievu/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:vievu/features/auth/data/repositories/auth_repository_implementation.dart';
import 'package:vievu/features/auth/data/repositories/profile_repository_implementation.dart';
import 'package:vievu/features/auth/domain/repository/auth_repository.dart';
import 'package:vievu/features/auth/domain/repository/profile_repository.dart';
import 'package:vievu/features/auth/domain/usecases/current_user.dart';
import 'package:vievu/features/auth/domain/usecases/listen_auth_change.dart';
import 'package:vievu/features/auth/domain/usecases/send_reset_password_email.dart';
import 'package:vievu/features/auth/domain/usecases/update_password.dart';
import 'package:vievu/features/auth/domain/usecases/user_login.dart';
import 'package:vievu/features/auth/domain/usecases/user_logout.dart';
import 'package:vievu/features/auth/domain/usecases/user_signup.dart';
import 'package:vievu/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vievu/features/auth/presentation/bloc/profile_bloc.dart';
import 'package:vievu/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vievu/features/chat/data/datasources/message_remote_datasource.dart';
import 'package:vievu/features/chat/data/repositories/chat_repository_implementation.dart';
import 'package:vievu/features/chat/data/repositories/message_repository_implementation.dart';
import 'package:vievu/features/chat/domain/repositories/chat_repository.dart';
import 'package:vievu/features/chat/domain/repositories/message_repository.dart';
import 'package:vievu/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vievu/features/chat/presentation/bloc/message_bloc.dart';
import 'package:vievu/features/explore/data/datasources/attraction_remote_datasource.dart';
import 'package:vievu/features/explore/data/datasources/event_remote_datasource.dart';
import 'package:vievu/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vievu/features/explore/data/datasources/review_remote_datasource.dart';
import 'package:vievu/features/explore/data/repositories/attraction_repository_implementation.dart';
import 'package:vievu/features/explore/data/repositories/event_repository_implementation.dart';
import 'package:vievu/features/explore/data/repositories/location_repository_implementation.dart';
import 'package:vievu/features/explore/data/repositories/review_repository_implementation.dart';
import 'package:vievu/features/explore/domain/repositories/attraction_repository.dart';
import 'package:vievu/features/explore/domain/repositories/event_repository.dart';
import 'package:vievu/features/explore/domain/repositories/location_repository.dart';
import 'package:vievu/features/explore/domain/repositories/review_repository.dart';
import 'package:vievu/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vievu/features/explore/presentation/bloc/event/event_bloc.dart';
import 'package:vievu/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vievu/features/explore/presentation/cubit/attraction_details/attraction_details_cubit.dart';
import 'package:vievu/features/explore/presentation/cubit/location_info/location_info_cubit.dart';
import 'package:vievu/features/explore/presentation/cubit/nearby_attractions/nearby_attractions_cubit.dart';
import 'package:vievu/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vievu/features/explore/presentation/cubit/reviews/reviews_cubit.dart';
import 'package:vievu/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:vievu/features/notifications/data/repositories/notification_repository_implementation.dart';
import 'package:vievu/features/notifications/domain/repositories/notification_repository.dart';
import 'package:vievu/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:vievu/features/search/data/datasources/search_remote_datasource.dart';
import 'package:vievu/features/search/data/repositories/explore_search_repository_implementation.dart';
import 'package:vievu/features/search/domain/repositories/explore_search_repository.dart';
import 'package:vievu/features/search/presentation/bloc/search_bloc.dart';
import 'package:vievu/features/search/presentation/cubit/search_history_cubit.dart';
import 'package:vievu/features/trips/data/datasources/saved_service_remote_datasource.dart';
import 'package:vievu/features/trips/data/datasources/trip_itinerary_remote_datasource.dart';
import 'package:vievu/features/trips/data/datasources/trip_member_remote_datasource.dart';
import 'package:vievu/features/trips/data/datasources/trip_remote_datasource.dart';
import 'package:vievu/features/trips/data/datasources/trip_review_remote_datasource.dart';
import 'package:vievu/features/trips/data/repositories/saved_service_repository_implementation.dart';
import 'package:vievu/features/trips/data/repositories/trip_itinerary_repository_implement.dart';
import 'package:vievu/features/trips/data/repositories/trip_member_repository_implementation.dart';
import 'package:vievu/features/trips/data/repositories/trip_repository_implementation.dart';
import 'package:vievu/features/trips/data/repositories/trip_review_repository_implementation.dart';
import 'package:vievu/features/trips/domain/repositories/saved_service_repository.dart';
import 'package:vievu/features/trips/domain/repositories/trip_itinerary_repository.dart';
import 'package:vievu/features/trips/domain/repositories/trip_member_repository.dart';
import 'package:vievu/features/trips/domain/repositories/trip_repository.dart';
import 'package:vievu/features/trips/domain/repositories/trip_review_repository.dart';
import 'package:vievu/features/trips/presentation/bloc/saved_service/saved_service_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip/trip_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_itinerary/trip_itinerary_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_member/trip_member_bloc.dart';
import 'package:vievu/features/trips/presentation/bloc/trip_review_bloc.dart';
import 'package:vievu/features/trips/presentation/cubit/current_trip_member_info_cubit.dart';
import 'package:vievu/features/trips/presentation/cubit/trip_details_cubit.dart';
import 'package:vievu/features/user_preference/data/datasources/preferences_remote_datasource.dart';
import 'package:vievu/features/user_preference/data/datasources/travel_type_remote_datasource.dart';
import 'package:vievu/features/user_preference/data/repositories/preference_repository_implementation.dart';
import 'package:vievu/features/user_preference/data/repositories/travel_type_repository_implementation.dart';
import 'package:vievu/features/user_preference/domain/repositories/preference_repository.dart';
import 'package:vievu/features/user_preference/domain/repositories/travel_type_repository.dart';
import 'package:vievu/features/user_preference/presentation/bloc/preference/preference_bloc.dart';
import 'package:vievu/features/user_preference/presentation/bloc/travel_types/travel_types_bloc.dart';
import 'package:http/http.dart' as http;

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initPreference();
  _initExplore();
  _initLocation();
  _initEvent();
  _initSearch();
  _initReview();
  _initTrip();
  _initChat();
  _initMessage();
  _initSavedService();
  _initTripItinerary();
  _initTripMember();
  _initProfile();
  _initTripReview();
  _initNotification();

  final supabase = await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);

  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerLazySingleton(() => http.Client());
  // core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );

  serviceLocator.registerLazySingleton(
    () => NearbyAttractionsCubit(attractionRepository: serviceLocator()),
  );

  serviceLocator.registerFactory(
    () => NearbyServicesCubit(attractionRepository: serviceLocator()),
  );

  serviceLocator.registerFactory(
    () => AttractionDetailsCubit(attractionRepository: serviceLocator()),
  );

  serviceLocator.registerFactory(
    () => ReviewsCubit(reviewRepository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => TripDetailsCubit(tripRepository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => CurrentTripMemberInfoCubit(tripMemberRepository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => SearchHistoryCubit(repository: serviceLocator()),
  );

  serviceLocator.registerFactory(
    () => LocationInfoCubit(locationRepository: serviceLocator()),
  );
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogout(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ListenToAuthChanges(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => SendResetPasswordEmail(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdatePassword(
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        userLogout: serviceLocator(),
        appUserCubit: serviceLocator(),
        listenToAuthChanges: serviceLocator(),
        sendEmailReset: serviceLocator(),
        updatePassword: serviceLocator(),
      ),
    );
}

void _initPreference() {
  serviceLocator
    ..registerFactory<PreferencesRemoteDataSource>(
      () => PreferencesRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<PreferenceRepository>(
      () => PreferenceRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory<TravelTypeRemoteDatasource>(
      () => TravelTypeRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<TravelTypeRepository>(
      () => TravelTypeRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => PreferencesBloc(
        preferenceRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => TravelTypesBloc(
        travelTypeRepository: serviceLocator(),
      ),
    );
}

void _initExplore() {
  serviceLocator
    ..registerFactory<AttractionRemoteDatasource>(
      () => AttractionRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<AttractionRepository>(
      () => AttractionRepositoryImpl(
        attractionRemoteDatasource: serviceLocator(),
        connectionChecker: serviceLocator(),
        savedServiceRemoteDatasource: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AttractionBloc(
        attractionRepository: serviceLocator(),
      ),
    );
}

void _initLocation() {
  serviceLocator
    ..registerFactory<LocationRemoteDatasource>(
      () => LocationRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<LocationRepository>(
      () => LocationRepositoryImpl(
        attractionRemoteDatasource: serviceLocator(),
        locationRemoteDatasource: serviceLocator(),
        connectionChecker: serviceLocator(),
        savedServiceRemoteDatasource: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => LocationBloc(
        repository: serviceLocator(),
      ),
    );
}

void _initEvent() {
  serviceLocator
    ..registerFactory<EventRemoteDatasource>(
      () => EventRemoteDatasourceImpl(
        client: serviceLocator(),
        supabaseClient: serviceLocator(),
      ),
    )
    ..registerFactory<EventRepository>(
      () => EventRepositoryImpl(
        eventRemoteDatasource: serviceLocator(),
        locationRemoteDatasource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => EventBloc(
        repository: serviceLocator(),
      ),
    );
}

void _initSearch() {
  serviceLocator
    ..registerFactory<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory<SearchRepository>(
      () => SearchRepositoryImpl(
        searchRemoteDataSource: serviceLocator(),
        savedServiceRemoteDatasource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => SearchBloc(
        repository: serviceLocator(),
      ),
    );
}

void _initReview() {
  serviceLocator
    ..registerFactory<ReviewRepository>(
      () => ReviewRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory<ReviewRemoteDataSource>(
      () => ReviewRemoteDataSourceImpl(
        serviceLocator(),
      ),
    );
}

void _initTrip() {
  serviceLocator
    ..registerFactory<TripRemoteDatasource>(
      () => TripRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<TripRepository>(
      () => TripRepositoryImpl(
        tripRemoteDatasource: serviceLocator(),
        tripMemberRemoteDatasource: serviceLocator(),
        chatRemoteDatasource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    ..registerLazySingleton<TripBloc>(
      () => TripBloc(
        tripRepository: serviceLocator(),
      ),
    );
}

void _initSavedService() {
  serviceLocator
    ..registerFactory<SavedServiceRemoteDatasource>(
      () => SavedServiceRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<SavedServiceRepository>(
      () => SavedServiceRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => SavedServiceBloc(
        savedServiceRepository: serviceLocator(),
      ),
    );
}

void _initTripItinerary() {
  serviceLocator
    ..registerFactory<TripItineraryRemoteDatasource>(
      () => TripItineraryRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<TripItineraryRepository>(
      () => TripItineraryRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => TripItineraryBloc(
        tripItineraryRepository: serviceLocator(),
      ),
    );
}

void _initChat() {
  serviceLocator
    ..registerFactory<ChatRemoteDatasource>(
      () => ChatRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<ChatRepository>(
      () => ChatRepositoryImpl(
        chatRemoteDatasource: serviceLocator(),
        messageRemoteDatasource: serviceLocator(),
        connectionChecker: serviceLocator(),
        locationRemoteDatasource: serviceLocator(),
        savedServiceRemoteDatasource: serviceLocator(),
        tripItineraryRemoteDatasource: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => ChatBloc(
        chatRepository: serviceLocator(),
      ),
    );
}

void _initMessage() {
  serviceLocator
    ..registerFactory<MessageRemoteDatasource>(
      () => MessageRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<MessageRepository>(
      () => MessageRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => MessageBloc(
        messageRepository: serviceLocator(),
      ),
    );
}

void _initProfile() {
  serviceLocator
    ..registerFactory<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<ProfileRepository>(
      () => ProfileRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => ProfileBloc(
        profileRepository: serviceLocator(),
      ),
    );
}

void _initTripMember() {
  serviceLocator
    ..registerFactory<TripMemberRemoteDatasource>(
      () => TripMemberRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<TripMemberRepository>(
      () => TripMemberRepositoryImpl(
        chatRemoteDatasource: serviceLocator(),
        tripMemberRemoteDatasource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => TripMemberBloc(
        tripMemberRepository: serviceLocator(),
        currentTripMemberInfoCubit: serviceLocator(),
      ),
    );
}

void _initTripReview() {
  serviceLocator
    ..registerFactory<TripReviewRemoteDataSource>(
      () => TripReviewRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<TripReviewRepository>(
      () => TripReviewRepositoryImplementation(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => TripReviewBloc(
        tripReviewRepository: serviceLocator(),
      ),
    );
}

void _initNotification() {
  serviceLocator
    ..registerFactory<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
        tripMemberRemoteDatasource: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => NotificationBloc(
        notificationRepository: serviceLocator(),
      ),
    );
}
