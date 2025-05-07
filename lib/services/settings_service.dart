import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// SharedPreferencesを使って設定を保存・読み込み
class SettingsService {
  // 通知のON/OFFを保存
  static Future<void> saveReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder', value);
  }

  // 通知時間を保存
  static Future<void> saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_hour', time.hour);
    await prefs.setInt('notif_minute', time.minute);
  }

  // 自動削除日数を保存
  static Future<void> saveDeleteDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('delete_days', days);
  }
}
