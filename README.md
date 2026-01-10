# アプリケーション名：TaskStreamliner

## アプリケーション概要
タスクの締め切りと予定を一つのタイムラインで可視化するスケジュール管理ツール。
タスクや予定はチームで共有することも、個人のものとして非公開にすることができる。
また、タスクには重要度や進捗のステータスを反映することができ、より効率的な処理が可能。
コメントの機能も付けているため、共有事項があった場合にはコメントで同じタスクや予定を共有するメンバーとコミュニケーションをとることができる。

## URL
https://taskstreamliner.onrender.com

## テスト用アカウント
- Basic認証用ID：
- Basic認証パスワード：
- メールアドレス：test@test
- パスワード：testtest1

# 利用方法
1. **ユーザー登録・ログイン**:
 - アカウントを作成してログイン。既存ユーザーはメールアドレスとパスワードでログイン。
2. **予定・タスクの登録**: 
 - 登録したい日付の＋マークをクリックし「タスク」又は「予定」を選ぶ。
 - 「タスク」は締切日を入力。
 - 「予定」は期間（開始〜終了）を入力。
3. **カレンダー・タイムライン確認**: 
   - 左側のミニカレンダーで日付を選択。
   - 右側のタイムラインで、その日の詳細なスケジュールを確認。
4. **チーム共有**: 必要に応じてタスクを他のユーザーと共有。

## アプリケーションを作成した背景
複数のプロジェクトを兼務していた際、締切直前になって予定が重なっていることに気づくことや、タスクがどの程度まで終わっているのかがわからず混乱することがあった。
「いつやるか」の期間と「いつまでか」の締切を同時に、かつ直感的に把握したいという課題やチーム(プロジェクト)ごとにわかりやすく整理したいという思いを解決するために開発を行った。

## 実装した機能について
### 1. マルチデイ・タイムライン表示
- 複数日にわたる予定を、中断することなく連続した予定として登録可能。
https://gyazo.com/931a202949fcf48286cd86e12e925b79

### 2. 直感的な入力UI
- 登録した後のステータス変更、コメントの際、Javascriptを使用し、ページ読み込み不要に。

### 3. 期間重複の判定ロジック
  SQLのクエリを工夫し、`(start_at <= 今日 AND end_at >= 今日)` という条件を用いることで、初日・中日・最終日のすべてのパターンを効率的に1つのクエリで取得するよう実装。

### 4. データの整合性管理 
  モデルレベルでのバリデーション（`validates :priority, presence: true`など）を徹底し、入力漏れによるデータの不整合を防ぐ。

### 5.カレンダーの年月にJavascriptを使用し、数か月、数年先へのアクセスも容易に
  前月、次月ボタンでの月の切り替えは煩わしいと考え、年月の部分をクリックすることで数か月先のカレンダーへのアクセスを容易に。

### 6.SlimSelectorを導入し、複数のチームとタスクや予定を共有可能に
  同じタスク、予定を複数のチームで共有することもあると考え、複数のチームへ共有ができるように実装。

### 7.チームはリーダーのみが解散権を持つ
  チームを作成したユーザーがリーダーとなり、チームの解散はリーダーのみが可能とした。
  リーダー権限はenumにて管理。
  タスクや予定の登録や削除はメンバーもできないと不便であると感じ、こちらはメンバーも可能。
  また、タスクや予定にかかれたコメントについては書いた本人、または共有されているチームのリーダーのみが削除可能とした。

### 8.左メニューにて所属チームとプライベートの表示を切り替え可能に
  チームのチェックマークを外すことでチームのタスクや予定をグレーアウトさせ、チームごとのタスクを可視化することが可能。
  また、「自分の予定のみ表示」にチェックマークをつけることで、プライベートな予定も可視化可能。
  また、所属チーム名をクリックすることでチーム詳細へアクセスが可能。

### 9.未完了タスクのリストアップ
  タスクの中でも未完了タスクをメニュー内にリストアップ。
  タスクの未処理によるトラブル防止が目的。

## 改善点（今後の展望）
- **重複した予定の警告**: 重複した予定が重なった場合、アラートを表示する機能を追加。
- **通知機能の実装**: コメントがされた際の通知機能を追加。
- **自動テストの拡充**: RSpecを用いて、日またぎの境界値テスト（深夜0時を跨ぐ場合など）の自動化を強化する。

## データベース設計
```mermaid
erDiagram
    users ||--o{ tasks : "作成"
    users ||--o{ comments : "投稿"
    users ||--o{ memberships : "所属"
    teams ||--o{ memberships : "所属"
    teams ||--o{ task_shares : "共有"
    tasks ||--o{ task_shares : "共有"
    tasks ||--o{ comments : "紐付け"

    users {
        bigint id
        string name
        string email
        string encrypted_password
    }

    memberships {
        bigint id
        bigint user_id FK
        bigint team_id FK
        string role
    }

    teams {
        bigint id
        string name
    }

    tasks {
        bigint id
        bigint user_id FK
        string title
        text description
        integer task_type
        integer status
        integer priority
        datetime start_at
        datetime end_at
        date deadline
    }

    task_shares {
        bigint id
        bigint task_id FK
        bigint team_id FK
    }

    comments {
        bigint id
        bigint task_id FK
        bigint user_id FK
        text content
        datetime created_at
    }
  ```

## 画面変遷図
```mermaid
graph TD
    %% ログイン前
    Start((開始)) --> Login[ログイン画面]
    Start --> Signup[ユーザー新規登録画面]
    
    %% ログイン後
    Login --> Calendar[カレンダーページ / メイン]
    Signup --> Calendar
    
    %% メインからの遷移
    Calendar --> TaskNew[タスク・予定作成モーダル/画面]
    Calendar --> DayDetail[Day詳細 / タイムラインページ]
    
    %% 詳細への遷移
    DayDetail --> TaskDetail[タスク・予定詳細ページ]
    TaskNew --> DayDetail
    
    %% 編集・削除の流れ
    TaskDetail --> TaskEdit[編集・削除アクション]
    TaskEdit --> DayDetail
    
    %% スタイル設定
    style Start fill:#f9f,stroke:#333,stroke-width:2px
    style Calendar fill:#bbf,stroke:#333,stroke-width:4px
```

## 開発環境
- **言語・フレームワーク**: Ruby / Ruby on Rails
- **データベース**: PostgreSQL
- **フロントエンド**: Bootstrap 5, Sass, JavaScript (Stimulus)
- **インフラ**: Render

## ローカルでの動作方法
```bash
git clone https://github.com/ymshkdev/TaskStreamliner.git
cd TaskStreamliner
bundle install
rails db:create
rails db:migrate
rails s