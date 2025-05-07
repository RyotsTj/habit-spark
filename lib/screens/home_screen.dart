import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/task_database.dart';
import '../models/task.dart';
import './settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final autoDeleteDays = prefs.getInt('autoDeleteDays') ?? 7; // デフォルト7日

    final today = DateTime.now();
    final data = await TaskDatabase.instance.getTasks();

    // 完了済みかつ、期限からautoDeleteDays以上経過したタスクを削除
    for (final task in data) {
      if (task.isDone == 1) {
        try {
          final deadline = DateFormat('yyyy/MM/dd').parse(task.deadline);
          final diff = today.difference(deadline).inDays;
          if (diff >= autoDeleteDays) {
            await TaskDatabase.instance.deleteTasks([task.id!]);
          }
        } catch (e) {
          print('日付パース失敗: ${task.deadline}');
        }
      }
    }

    // 再取得して状態反映
    final refreshed = await TaskDatabase.instance.getTasks();
    setState(() => tasks = refreshed);
  }

  Future<void> _addTask() async {
    if (_titleController.text.isEmpty) return;
    final task = Task(
      title: _titleController.text,
      deadline: DateFormat('yyyy/MM/dd').format(_selectedDate),
      isDone: 0,
    );
    await TaskDatabase.instance.insertTask(task);
    _titleController.clear();
    _selectedDate = DateTime.now();
    _loadTasks();
  }

  Future<void> _updateTask(Task task) async {
    _titleController.text = task.title;
    _selectedDate = DateFormat('yyyy/MM/dd').parse(task.deadline);
    await showDialog(
      context: context,
      builder: (_) => _buildAddDialog(onConfirm: () async {
        final updated = task.copyWith(
          title: _titleController.text,
          deadline: DateFormat('yyyy/MM/dd').format(_selectedDate),
        );
        await TaskDatabase.instance.updateTask(updated);
        _titleController.clear();
        _loadTasks();
      }),
    );
  }

  Future<void> _deleteTask(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('はい')),
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('いいえ')),
        ],
      ),
    );
    if (confirm == true) {
      await TaskDatabase.instance.deleteTasks([id]);
      _loadTasks();
    }
  }

  Widget _buildAddDialog({required VoidCallback onConfirm}) {
    return AlertDialog(
      title: Text('New Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'New Task'),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text('Deadline: ${DateFormat('yyyy/MM/dd').format(_selectedDate)}'),
              Spacer(),
              IconButton(
                icon: Image.asset('assets/icon/edit_icon.png', width: 24, height: 24), // 編集アイコン
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ],
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('キャンセル')),
        ElevatedButton(onPressed: () { Navigator.pop(context); onConfirm(); }, child: Text('保存')),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      color: task.isDone == 1 ? Colors.teal.shade100 : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(task.title, style: TextStyle(fontSize: 18)),
        subtitle: Text('期限: ${task.deadline}'),
        trailing: Wrap(
          spacing: 8,
          children: [
            // 編集ボタンをカスタムアイコンに変更
            IconButton(
              icon: Image.asset('assets/icon/edit_icon.png', width: 24, height: 24), // 編集アイコン
              onPressed: () => _updateTask(task),
            ),
            // 削除ボタンをカスタムアイコンに変更
            IconButton(
              icon: Image.asset('assets/icon/delete_icon.png', width: 24, height: 24), // 削除アイコン
              onPressed: () => _deleteTask(task.id!),
            ),
          ],
        ),
        onTap: () async {
          final updated = task.copyWith(isDone: task.isDone == 0 ? 1 : 0);
          await TaskDatabase.instance.updateTask(updated);
          _loadTasks();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unfinished = tasks.where((t) => t.isDone == 0).toList();
    final finished = tasks.where((t) => t.isDone == 1).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Habit Spark'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // 設定アイコン
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },

          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => _buildAddDialog(onConfirm: _addTask),
        ),
        backgroundColor: Colors.teal,
        child: Text('+', style: TextStyle(fontSize: 32)),
      ),
      body: Row(
        children: [
          // 左側（未完了）
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 16),
                Text('Active', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView(
                    children: unfinished.map(_buildTaskCard).toList(),
                  ),
                ),
              ],
            ),
          ),
          // 境界線
          Container(width: 3, color: Colors.black),
          // 右側（完了）
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 16),
                Text('Completed', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView(
                    children: finished.map(_buildTaskCard).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
