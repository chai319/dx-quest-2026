#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

REPO_NAME="dx-quest-2026"

echo "=========================================================="
echo "🚀 9/30 高1 DX実習 シャーロック風進行サイト GitHub Pages 公開スクリプト"
echo "=========================================================="

# 一時的な独立gitリポジトリとして初期化
if [ ! -d ".git" ]; then
  git init -b main
fi

# .gitignore 作成（公開用アセットのみコミット）
cat << 'EOF' > .gitignore
*.json
*.bak*
*.py
HANDOFF_TO_SAE.md
lesson-plan.md
teacher-checklist.md
student-guide.md
review-decisions.md
emo-review.md
2026-09-27_daily-report-entry.md
SLIDE_SCRIPT_FOR_VIDES.md
gas_slide_builder/
.clasp.json
EOF

git add index.html slides.html README.md deploy.sh .gitignore *.png prompt-*.txt
git commit -m "feat: 9/30高1DX実習進行サイト公開（シャーロック風Canvas開発クエスト＆スライド埋め込み完了）" || echo "コミット対象なし（すでに最新です）"

if command -v gh &> /dev/null; then
  echo "GitHub CLI (gh) を検出しました。リポジトリ作成とプッシュを自動実行します..."
  
  # リポジトリを作成してプッシュ（既にある場合はプッシュのみ）
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push 2>/dev/null || {
    echo "リポジトリが既存または連携済みです。プッシュを実行します..."
    git push -u origin main --force
  }

  echo "GitHub Pages を有効化しています..."
  gh api "repos/:owner/$REPO_NAME/pages" -X POST -F "source[branch]=main" -F "source[path]=/" 2>/dev/null || true

  USER_NAME=$(gh api user -q .login 2>/dev/null || echo "chai319")
  
  echo ""
  echo "=========================================================="
  echo "🎉 GitHub Pages への公開が完了しました！"
  echo "🌐 公開URL: https://${USER_NAME}.github.io/${REPO_NAME}/"
  echo "=========================================================="
  
  # ブラウザで開く
  gh browse || true
else
  echo "GitHub CLI が見つかりませんでした。"
  echo "以下のコマンドで直接プッシュできます:"
  echo "git remote add origin https://github.com/chai319/$REPO_NAME.git"
  echo "git push -u origin main"
fi
