import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

// 設定画面のStateクラス
class _SettingsScreenState extends State<SettingsScreen> {
  // リマインダー通知のON/OFF状態を保持
  bool _isReminderOn = false;
  // 通知時刻
  TimeOfDay _notificationTime = TimeOfDay(hour: 9, minute: 0);
  // 自動削除の設定（日数）
  int _deleteDays = 7;

  // 画面初期化時に保存された設定を読み込み
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // SharedPreferencesから設定を読み込む
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReminderOn = prefs.getBool('reminder') ?? false;
      final hour = prefs.getInt('notif_hour') ?? 9;
      final minute = prefs.getInt('notif_minute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
      _deleteDays = prefs.getInt('delete_days') ?? 7;
    });
  }

  // 通知時間を選ぶダイアログ
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null) {
      setState(() {
        _notificationTime = picked;
      });
      SettingsService.saveNotificationTime(picked);
    }
  }

  // ドロップダウンで選択可能な日数の候補
  final List<int> _dayOptions = [1, 3, 7, 14, 30];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200, // ← ここを追加
      appBar: AppBar(
          title: Text('設定'),
          backgroundColor: Colors.teal, // メイン画面のAppBarと同じ色
          foregroundColor: Colors.white // 白文字で統一
      ),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 通知ON/OFFスイッチ
          SwitchListTile(
            title: Text('リマインダー通知'),
            value: _isReminderOn,
            onChanged: (value) {
              setState(() {
                _isReminderOn = value;
              });
              SettingsService.saveReminder(value);
            },
          ),

          // 通知時間選択
          ListTile(
            title: Text('通知時間: ${_notificationTime.format(context)}'),
            trailing: Icon(Icons.access_time),
            onTap: _pickTime,
          ),

          // 自動削除設定（ドロップダウン）
          ListTile(
            title: Text('完了済みを自動削除（${_deleteDays}日後）'),
            trailing: DropdownButton<int>(
              value: _deleteDays,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _deleteDays = value;
                  });
                  SettingsService.saveDeleteDays(value);
                }
              },
              items: _dayOptions
                  .map((d) => DropdownMenuItem(value: d, child: Text('$d日')))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
