import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vn_travel_companion/core/error/exceptions.dart';
import 'package:vn_travel_companion/features/trips/data/models/trip_review_model.dart';

abstract interface class TripReviewRemoteDataSource {
  Future<List<TripReviewModel>> getTripReviews({
    required String tripId,
    String sortType = 'latest',
  });

  Future<TripReviewModel> upsertTripReview({
    required String tripId,
    String? review,
    required double rating,
    required int memberId,
  });

  Future<void> deleteTripReview({
    required int id,
  });
}

class TripReviewRemoteDatasourceImpl implements TripReviewRemoteDataSource {
  final SupabaseClient supabaseClient;

  TripReviewRemoteDatasourceImpl(
    this.supabaseClient,
  );

  @override
  Future<List<TripReviewModel>> getTripReviews({
    required String tripId,
    String sortType = 'latest',
  }) async {
    try {
      final res = await supabaseClient
          .from('trip_reviews')
          .select('*, trip_participants(profiles(*))')
          .eq('trip_id', tripId)
          .order('created_at', ascending: sortType == 'latest' ? false : true);
      log(res.toString());

      return res.map((e) => TripReviewModel.fromJson(e)).toList();
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripReviewModel> upsertTripReview({
    required String tripId,
    String? review,
    required double rating,
    required int memberId,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const ServerException("Không tìm thấy người dùng");
      }
      final res = await supabaseClient
          .from('trip_reviews')
          .upsert({
            'trip_id': tripId,
            'review': review,
            'rating': rating.toInt(),
            'trip_participant_id': memberId,
          }, onConflict: "trip_participant_id")
          .select('*, trip_participants(profiles(*))')
          .single();

      await supabaseClient.from('trip_participants').update({
        'reviewed': true,
      }).eq('id', memberId);
      final pref = await supabaseClient
          .from('user_preferences')
          .select()
          .eq('user_id', user.id)
          .single();
      final newRatingCount = pref['rating_count'] + 1;
      final newRating =
          (pref['rating'] * pref['rating_count'] + rating) / newRatingCount;
      await supabaseClient.from('user_preferences').update({
        'avg_rating': newRating,
        'rating_count': newRatingCount,
      });
      return TripReviewModel.fromJson(res);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTripReview({
    required int id,
  }) async {
    try {
      await supabaseClient.from('trip_reviews').delete().eq('id', id);
      await supabaseClient.from('trip_participants').update({
        'reviewed': false,
      }).eq('id', id);
    } catch (e) {
      log(e.toString());
      throw ServerException(e.toString());
    }
  }
}
