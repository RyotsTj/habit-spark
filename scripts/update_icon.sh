#!/bin/bash

# Flutterプロジェクトのルートディレクトリで実行すること

echo "▶ アプリアイコンを再生成します..."

# flutter_launcher_iconsを実行（pubspec.yaml に設定済みであること）
flutter pub get
flutter pub run flutter_launcher_icons:main

# 成功メッセージ
if [ $? -eq 0 ]; then
    echo "✅ アイコンの再生成が完了しました。"
else
    echo "❌ エラー：アイコンの生成に失敗しました。"
fi
