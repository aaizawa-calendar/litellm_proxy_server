# llm_proxy_server

LiteLLM Proxy を使用して、GitHub Copilot 等の LLM プロバイダーを OpenAI 互換 API 形式で一括管理するためのサーバー環境です。

## 📂 プロジェクト構成
```
.
├── .env                # マスターキー等の環境変数（Git管理対象外）
├── .gitignore          # 秘密情報の除外設定
├── Dockerfile          # プロキシサーバーの実行環境
├── config.yaml         # モデルのルーティング設定
├── start.sh            # ビルド・起動・認証ステータス確認スクリプト
└── github_copilot_token/ # GitHub Copilot の認証情報保存先（自動生成）
```

## 🚀 セットアップ

### 1. 環境変数の準備
.env ファイルを作成し、サーバーへのアクセスキーを設定します。

```
# プロキシ自体へのアクセスを制限するマスターキー（クライアント側で API Key として使用）
LITELLM_MASTER_KEY=sk-your-secure-key
```

### 2. サーバーの起動
付属の start.sh を使用して、ビルドから起動、認証状態の確認までを自動で行います。

```bash
sh ./start.sh
```

### 3. 認証（GitHub Copilot を使用する場合）
起動後、スクリプトが自動で認証状態を判定します。

- 「🔑 認証が必要です」 と表示された場合、以下のコマンドを実行して 8 桁のデバイスコードを確認してください。
  ```
  docker logs -f litellm-proxy-instance
  ```
  
- ログに表示されたURLにアクセスし、コードを入力してログインを完了させてください。

## 🛠 使い方
起動したサーバーは http://localhost:4000 で OpenAI 互換 API として動作します。

### API エンドポイント
- Base URL: http://localhost:4000/v1
- API Key: `.env` に設定した LITELLM_MASTER_KEY

### モデル一覧の確認（テスト）
サーバーが正しく稼働しているか、以下のコマンドで確認できます。
```
curl http://localhost:4000/v1/models \
  -H "Authorization: Bearer <LITELLM_MASTER_KEY>"
```

### チャットリクエストの例
```
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <LITELLM_MASTER_KEY>" \
  -d '{
    "model": "gpt-5-mini",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## ⚠️ 注意事項
- セキュリティ: `github_copilot_token/` フォルダには認証済みトークンが保存されます。`.env` と共に、このディレクトリをパブリックなリポジトリに公開しないでください。
- 永続化: 認証情報はホスト側の `github_copilot_token/` にマウントされているため、コンテナを削除・再作成しても再ログインの必要はありません。
