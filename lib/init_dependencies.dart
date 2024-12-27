import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vn_travel_companion/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:vn_travel_companion/core/network/connection_checker.dart';
import 'package:vn_travel_companion/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vn_travel_companion/features/auth/data/repositories/auth_repository_implementation.dart';
import 'package:vn_travel_companion/features/auth/domain/repository/auth_repository.dart';
import 'package:vn_travel_companion/features/auth/domain/usecases/current_user.dart';
import 'package:vn_travel_companion/features/auth/domain/usecases/listen_auth_change.dart';
import 'package:vn_travel_companion/features/auth/domain/usecases/send_reset_password_email.dart';
import 'package:vn_travel_companion/features/auth/domain/usecases/update_password.dart';
import 'package:vn_travel_companion/features/auth/domain/usecases/user_login.dart';
import 'package:vn_travel_companion/features/auth/domain/usecases/user_logout.dart';
import 'package:vn_travel_companion/features/auth/domain/usecases/user_signup.dart';
import 'package:vn_travel_companion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/attraction_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/event_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/location_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/data/datasources/review_remote_datasource.dart';
import 'package:vn_travel_companion/features/explore/data/repositories/attraction_repository_implementation.dart';
import 'package:vn_travel_companion/features/explore/data/repositories/event_repository_implementation.dart';
import 'package:vn_travel_companion/features/explore/data/repositories/location_repository_implementation.dart';
import 'package:vn_travel_companion/features/explore/data/repositories/review_repository_implementation.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/attraction_repository.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/event_repository.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/location_repository.dart';
import 'package:vn_travel_companion/features/explore/domain/repositories/review_repository.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/attraction/attraction_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/event/event_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/bloc/location/location_bloc.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/attraction_details/attraction_details_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_attractions/nearby_attractions_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/nearby_services/nearby_services_cubit.dart';
import 'package:vn_travel_companion/features/explore/presentation/cubit/reviews_cubit.dart';
import 'package:vn_travel_companion/features/search/data/datasources/search_remote_datasource.dart';
import 'package:vn_travel_companion/features/search/data/repositories/explore_search_repository_implementation.dart';
import 'package:vn_travel_companion/features/search/domain/repositories/explore_search_repository.dart';
import 'package:vn_travel_companion/features/search/presentation/bloc/search_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/data/datasources/preferences_remote_datasource.dart';
import 'package:vn_travel_companion/features/user_preference/data/datasources/travel_type_remote_datasource.dart';
import 'package:vn_travel_companion/features/user_preference/data/repositories/preference_repository_implementation.dart';
import 'package:vn_travel_companion/features/user_preference/data/repositories/travel_type_repository_implementation.dart';
import 'package:vn_travel_companion/features/user_preference/domain/repositories/preference_repository.dart';
import 'package:vn_travel_companion/features/user_preference/domain/repositories/travel_type_repository.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/bloc/preference/preference_bloc.dart';
import 'package:vn_travel_companion/features/user_preference/presentation/bloc/travel_types/travel_types_bloc.dart';
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
        serviceLocator(),
        serviceLocator(),
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
        serviceLocator(),
        serviceLocator(),
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
        serviceLocator(),
      ),
    )
    ..registerFactory<EventRepository>(
      () => EventRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
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
    ..registerFactory<ExploreSearchRepository>(
      () => ExploreSearchRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
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
