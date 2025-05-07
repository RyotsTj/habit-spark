// タスクモデルクラス
class Task {
  final int? id; // タスクの一意なID（null許可）
  final String title; // タスク名
  final String deadline; // 期限（文字列形式）
  final int isDone; // 0 = 未完了, 1 = 完了

  // コンストラクタ
  Task({
    this.id,
    required this.title,
    required this.deadline,
    required this.isDone,
  });

  // DBへ保存するMap形式に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'isDone': isDone,
    };
  }

  // DBから取得したMapをTaskに変換
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      deadline: map['deadline'],
      isDone: map['isDone'],
    );
  }

  // タスクの一部だけ変更したコピーを作るためのメソッド
  Task copyWith({int? id, String? title, String? deadline, int? isDone}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isDone: isDone ?? this.isDone,
    );
  }
}
