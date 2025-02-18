part of 'saved_service_bloc.dart';

@immutable
sealed class SavedServiceState {}

final class SavedServiceInitial extends SavedServiceState {}

final class SavedServiceLoading extends SavedServiceState {}

final class SavedServiceActionSucess extends SavedServiceState {
  final String tripId;
  final SavedService savedService;
  SavedServiceActionSucess({
    required this.tripId,
    required this.savedService,
  });
}

final class SavedServiceDeleteSuccess extends SavedServiceState {
  final String tripId;
  final int linkId;



  SavedServiceDeleteSuccess({
    required this.tripId,
    required this.linkId,

  });
}

final class SavedServiceFailure extends SavedServiceState {
  final String message;

  SavedServiceFailure({
    required this.message,
  });
}

final class SavedServicesLoadedSuccess extends SavedServiceState {
  final List<SavedService> savedServices;

  SavedServicesLoadedSuccess({
    required this.savedServices,
  });
}
