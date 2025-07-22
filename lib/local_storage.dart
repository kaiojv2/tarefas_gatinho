import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonTasks = jsonEncode(tasks);
    await prefs.setString('tasks', jsonTasks);
  }

  static Future<List<Map<String, dynamic>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('tasks');
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json));
  }

  static Future<void> saveProgress(double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('progress', progress);
  }

  static Future<double> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('progress') ?? 0.0;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
