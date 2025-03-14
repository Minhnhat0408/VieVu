import 'package:shared_preferences/shared_preferences.dart';

class OnboardingHelper {
  static const String hasSeenReactionGuideKey = "hasSeenReactionGuide";
  static const String hasSeenTagGuideKey = "hasSeenTagGuide";
  static const String hasSeenChatGuideKey = "hasSeenChatGuide";
  static const String hasSeenTripReviewGuideKey = "hasSeenTripReviewGuide";

  static Future<bool> hasSeenReactionGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hasSeenReactionGuideKey) ?? false;
  }

  static Future<void> setSeenReactionGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenReactionGuideKey, true);
  }

  static Future<void> resetSeenReactionGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenReactionGuideKey, false);
  }

  static Future<bool> hasSeenTagGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hasSeenTagGuideKey) ?? false;
  }

  static Future<void> setSeenTagGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenTagGuideKey, true);
  }

  static Future<void> resetSeenTagGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenTagGuideKey, false);
  }

  static Future<bool> hasSeenChatGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hasSeenChatGuideKey) ?? false;
  }

  static Future<void> setSeenChatGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenChatGuideKey, true);
  }

  static Future<void> resetSeenChatGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenChatGuideKey, false);
  }

  static Future<bool> hasSeenTripReviewGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hasSeenTripReviewGuideKey) ?? false;
  }

  static Future<void> setSeenTripReviewGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenTripReviewGuideKey, true);
  }

  static Future<void> resetSeenTripReviewGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasSeenTripReviewGuideKey, false);
  }
}
