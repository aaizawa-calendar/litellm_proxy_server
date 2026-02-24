#!/bin/bash

IMAGE_NAME="litellm-proxy"
CONTAINER_NAME="litellm-proxy-instance"

# 🔍 使うコマンドの判定
if command -v docker >/dev/null 2>&1; then
    CMD="docker"
else
    echo "❌ Error: 'docker' command not found."
    exit 1
fi

echo "🔍 Using engine: $CMD"

# 既存の同名コンテナを削除
$CMD rm -f $CONTAINER_NAME 2>/dev/null

# イメージのビルド
echo "🔨 Building image..."
$CMD build --tag $IMAGE_NAME .

# コンテナの起動
echo "🚀 Starting LiteLLM Proxy on http://localhost:4000"
$CMD run \
  --name $CONTAINER_NAME \
  -p 4000:4000 \
  -v "$(pwd)/config.yaml:/app/config.yaml" \
  -v "$(pwd)/github_copilot_token:/root/.config/litellm/github_copilot" \
  --env-file .env \
  --restart unless-stopped \
  -d \
  $IMAGE_NAME

echo "🚀 Starting LiteLLM Proxy..."
echo "⏳ Checking authentication status (waiting 5s)..."

# 5秒待ってから判定（LiteLLMが通信を終えるのを待つ）
sleep 5

# コンテナが生きているか確認
if ! $CMD ps | grep -q "$CONTAINER_NAME"; then
    echo "❌ Error: コンテナが異常終了しました。ログを確認してください："
    $CMD logs $CONTAINER_NAME
    exit 1
fi

# 判定ロジック
if $CMD logs "$CONTAINER_NAME" 2>&1 | grep -q "code"; then
    echo "-------------------------------------------------------"
    echo "🔑 認証が必要です。以下のコマンドでコードを確認してください："
    echo "   $CMD logs -f $CONTAINER_NAME"
    echo "-------------------------------------------------------"
else
    # ログイン済みか、あるいは起動エラーの可能性も考慮
    if $CMD logs "$CONTAINER_NAME" 2>&1 | grep -q "Uvicorn running"; then
        echo "✅ ログイン済みです！LiteLLM Proxy は正常に稼働しています。"
    else
        echo "⚠️ 起動を確認中... ログを確認してください："
        echo "   $CMD logs $CONTAINER_NAME"
    fi
fi
