import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionHelper {
  static const String _initialLanguageSelectionKey = "initialLanguageSelection";
  static const String _quizLanguageSelectionKey = "quizLanguageSelection";

  static Future<bool> isInitialLanguageSelectionCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initialLanguageSelectionKey) ?? false;
  }

  static Future<void> markInitialLanguageAsSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_initialLanguageSelectionKey, true);
  }

  static Future<bool> isQuizLanguageSelectionCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_quizLanguageSelectionKey) ?? false;
  }

  static Future<void> markQuizLanguageAsSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quizLanguageSelectionKey, true);
  }
}