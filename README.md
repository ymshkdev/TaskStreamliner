1. Users（ユーザー）
| Column             | Type   | Options     |
| ------------------ | ------ | ----------- |
|id	                 |integer	|null: false  |
|name	               |string	|null: false  |
|email	             |string	|null: false, unique: true |
|password_digest	   |string	|null: false  |

Association
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships      # 所属しているチーム一覧
  has_many :tasks, dependent: :destroy          # 自分が作成したタスク一覧
  has_many :comments, dependent: :destroy       # 自分が書いたコメント一覧
自分が作成者またはチームのリーダーであればタスクの削除が可能

2. Teams（チーム）
| Column             | Type   | Options     |
| ------------------ | ------ | ----------- |
|id                  |integer |null: false
|name（チーム名）     |string  |null: false

Association
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships       # チームメンバー一覧
  has_many :task_shares, dependent: :destroy
  has_many :tasks, through: :task_shares       # チームに共有されたタスク一覧

3. Memberships（チーム所属：中間テーブル）
| Column                         | Type     | Options     |
| ------------------             | ------   | ----------- |
|id                              |integer   |null: false
|user_id（外部キー）              |references|null: false, foreign_key: true
|team_id（外部キー）              |references|null: false, foreign_key: true
|role（enum: 0:member, 1:leader）|integer    |null: false, default: 0

Association
  belongs_to :user
  belongs_to :team
  enum :role, { member: 0, leader: 1 }

4. Tasks（タスク・予定本体）編集はメンバー可能、削除はリーダーのみ
| Column                                | Type      | Options     |
| ------------------                    | ------    | ----------- |
|id                                     |integer    |null: false
|user_id（作成者の外部キー）              |references|null: false, foreign_key: true
|title                                  |string     |null: false
|description（詳細ページで表示する説明文） |text|
|task_type                              |integer    |null: false, default: 0 (0:todo, 1:schedule)
|status（enum: todo, doing, done）      |integer    |null: false, default: 0
|priority（enum: low, medium, high）    |integer    |null: false, default: 0
|start_at / end_at（予定の場合に使用）    |datetime|
|deadline（タスクの場合に使用）           |datetime|

Association
  belongs_to :user                               # 作成者
  has_many :task_shares, dependent: :destroy
  has_many :teams, through: :task_shares         # 共有先のチーム一覧
  has_many :comments, dependent: :destroy        # このタスクへのコメント一覧
  enum :task_type, { todo: 0, schedule: 1 }
  enum :status, { todo: 0, doing: 1, done: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

5. TaskShares（共有先管理：中間テーブル）
| Column             | Type     | Options     |
| ------------------ | ------   | ----------- |
|id                  |integer   |null: false
|task_id（外部キー）  |references|null: false, foreign_key: true
|team_id（外部キー）  |references|null: false, foreign_key: true
※ これがあることで、1つの予定を「プロジェクトA」と「プロジェクトB」の両方に同時に出せるように。

Association
  belongs_to :task
  belongs_to :team

6. Comments
| Column                                   | Type     | Options     |
| ------------------                       | ------   | ----------- |
|id                                        |integer   |null: false
|task_id（どのタスクへのコメントか：外部キー）|references|null: false, foreign_key: true
|user_id（誰が書いたか：外部キー）           |references|null: false, foreign_key: true
|content（コメント本文：text型）             |text      |null: false
|created_at（投稿日時）                     |datetime  |null: false

Association
  belongs_to :task
  belongs_to :user

