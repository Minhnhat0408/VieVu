part of 'attraction_details_cubit.dart';

@immutable
sealed class AttractionDetailsState {}

final class AttractionDetailsInitial extends AttractionDetailsState {}

final class AttractionDetailsLoading extends AttractionDetailsState {}

final class AttractionDetailsFailure extends AttractionDetailsState {
  final String message;

  AttractionDetailsFailure(this.message);
}

final class AttractionDetailsLoadedSuccess extends AttractionDetailsState {
  final Attraction attraction;

  AttractionDetailsLoadedSuccess(this.attraction);
}