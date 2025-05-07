// Flutterの基本パッケージをインポート
import 'package:flutter/material.dart';
// 自作のホーム画面をインポート
import 'screens/home_screen.dart';

void main() {
  // アプリの実行を開始
  runApp(const MyApp());
}

// アプリ全体のウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // コンストラクタ

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小さな習慣形成アプリ', // アプリ名
      theme: ThemeData(
        primarySwatch: Colors.teal, // メインカラー
        useMaterial3: true, // Material3デザインの使用
      ),
      debugShowCheckedModeBanner: false, // デバッグ表示の非表示
      home: HomeScreen(), // ホーム画面へ（constは削除済）
    );
  }
}
