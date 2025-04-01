import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/features/explore/domain/entities/attraction.dart';
import 'package:vievu/features/explore/domain/repositories/attraction_repository.dart';

part 'attraction_details_state.dart';

class AttractionDetailsCubit extends Cubit<AttractionDetailsState> {
  final AttractionRepository _attractionRepository;
  AttractionDetailsCubit({
    required AttractionRepository attractionRepository,
  })  : _attractionRepository = attractionRepository,
        super(AttractionDetailsInitial());

  Future<void> fetchAttractionDetails(int attractionId) async {
    emit(AttractionDetailsLoading());
    final result =
        await _attractionRepository.getAttraction(attractionId: attractionId);
    result.fold(
      (failure) => emit(AttractionDetailsFailure(failure.message)),
      (attraction) => emit(AttractionDetailsLoadedSuccess(attraction)),
    );
  }
}
