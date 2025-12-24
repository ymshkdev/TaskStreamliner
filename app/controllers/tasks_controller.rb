class TasksController < ApplicationController
 before_action :authenticate_user! # ログイン必須にする
 before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
   # 1. 基準となる日付（@start_date）を決定する
   if params[:year] && params[:month]
    # 年月セレクトボックスからジャンプしてきた場合
    @start_date = Date.new(params[:year].to_i, params[:month].to_i, 1)
   elsif params[:start_date].present?
    # 文字列が空でないか、正しくパースできるかチェック
    begin
      @start_date = Date.parse(params[:start_date].to_s)
    rescue ArgumentError, Date::Error
      @start_date = Date.today
    end
   else
    # 何も指定がない場合は今日の日付
    @start_date = Date.today
   end
    # 2. 決定した @start_date を元に、その月のタスクと予定を取得する
    # beginning_of_month（月初）から end_of_month（月末）の範囲を指定
    # current_user.tasks と書くことで、タスクが0件でも nil ではなく
    # 「空のデータセット」が返るため、カレンダーが表示されるようにする
    # 1. 月の範囲を「時間の端から端まで」定義
    month_start = @start_date.beginning_of_month.beginning_of_day
    month_end   = @start_date.end_of_month.end_of_day

    # --- 2. 「表示対象のタスク（自分作成 + チーム共有）」のベースを作成 ---
    # 自分が所属しているチームのIDを取得
    my_team_ids = current_user.team_ids
    # 自分が作った、または、自分のチームに共有されたタスクを統合
    # left_outer_joins を使うことで、チーム共有がない（プライベートな）タスクも取得できます
    all_visible_tasks = Task.left_outer_joins(:task_shares)
                        .where(user_id: current_user.id)
                        .or(Task.where(task_shares: { team_id: my_team_ids }))
                        .distinct
    # --- 3. カレンダー表示用（@tasks） ---
    # all_visible_tasks に対して、期間の絞り込みをかける
    @tasks = all_visible_tasks.where(start_at: month_start..month_end)
                              .or(all_visible_tasks.where(deadline: month_start..month_end))
    # --- 4. サイドバー等のToDoリスト用（@todo_list） ---
    # all_visible_tasks に対して、未完了の絞り込みをかける
    @todo_list = all_visible_tasks.todo
                                  .where(status: [:todo, :doing]) # status_todo.or(status_doing)をスッキリ記述
                                  .order(priority: :desc, deadline: :asc)
  end
  
  def new
   # current_user.tasks.build にすることで、最初から user_id がセットされた状態で作成
   @task = current_user.tasks.build
   # --- 追加：戻り先情報の保持 ---
   @return_to = params[:return_to]
   @start_date = params[:start_date]
   # ----------------------------
   # カレンダーの「＋」ボタンから selected_date が送られてきた場合
   if params[:selected_date].present?
    # 文字列を日付オブジェクトに変換
    date = Date.parse(params[:selected_date])
    # 1. 予定（schedule）用の初期値（その日の 09:00 〜 10:00 など）
    @task.start_at = date.in_time_zone.change(hour: 9, min: 0)
    @task.end_at   = date.in_time_zone.change(hour: 10, min: 0)
    # 2. タスク（todo）用の初期値（その日の 00:00）
    @task.deadline = date.in_time_zone.beginning_of_day
   else
    # 直接「新規登録」ボタンを押した場合は、現在時刻を基準にする
    @task.deadline = Time.current.end_of_day
    @task.start_at = Time.current.change(hour: 9, min: 0)
    @task.end_at   = Time.current.change(hour: 10, min: 0)
  end
 end

 def create
  @task = current_user.tasks.build(task_params)
  # 保存前に、タイプに合わせて不要な項目をクリアする
  if @task.todo?
    @task.start_at = nil
    @task.end_at = nil
  elsif @task.schedule?
    @task.deadline = nil
    @task.status = :todo # 予定の場合はステータスをデフォルトに戻す
  end

  if @task.save
    # --- 戻り先による分岐 ---
    if params[:return_to] == 'day'
      # dayページに戻る。表示していた月(start_date)も引き継ぐ
      redirect_to day_tasks_path(date: (@task.start_at || @task.deadline).to_date, start_date: params[:start_date]), notice: "保存しました"
    else
      # 通常のカレンダー画面に戻る
      redirect_to tasks_path(start_date: (@task.start_at || @task.deadline).to_date), notice: "保存しました"
    end
    # ----------------------------
  else
    # バリデーションエラー時は入力を保持して再描画
    @return_to = params[:return_to]
    @start_date = params[:start_date]
    render :new, status: :unprocessable_entity
  end
end

def show
end

 def edit
  @return_to = params[:return_to]
  @start_date = params[:start_date]
 end

 def update
  if @task.update(task_params)
    redirect_to tasks_path, notice: "予定を更新しました"
  else
    render :edit, status: :unprocessable_entity
  end
 end

 def destroy
  @task.destroy
  # 削除した後はカレンダー画面に戻る
  # status: :see_other は Rails 7 (Turbo) で推奨されているリダイレクトのステータスです
  redirect_to tasks_path, notice: "予定を削除しました", status: :see_other
 end

 def day
  # 1. 右側に表示する「特定の1日」のデータ
  @date = params[:date] ? Date.parse(params[:date]) : Date.today
  day_range = @date.beginning_of_day..@date.end_of_day
  # --- 1. 「自分が見て良い全タスク」のベース ---
  my_team_ids = current_user.team_ids
  visible_tasks = Task.left_outer_joins(:task_shares)
                      .where(user_id: current_user.id)
                      .or(Task.where(task_shares: { team_id: my_team_ids }))
                      .distinct
   # --- 2. その中から、特定の日のデータを抽出 ---
  @day_tasks = visible_tasks.where(start_at: day_range)
                            .or(visible_tasks.where(deadline: day_range))
                            .order(:start_at, :deadline)

  # 3. 左側の「ミニカレンダー」が「何月」を表示するかを決定
  # URLにstart_dateがあればそれを優先。なければ表示中の日の月初にする。
  @start_date = params[:start_date] ? Date.parse(params[:start_date]) : @date.beginning_of_month
  
  # ミニカレンダーに表示するドット（予定ありマーク）を取得するための範囲
  month_start = @start_date.beginning_of_month.beginning_of_day
  month_end   = @start_date.end_of_month.end_of_day
  
  @month_tasks = visible_tasks.where(start_at: month_start..month_end)
                              .or(visible_tasks.where(deadline: month_start..month_end))

  # 3. 未完了タスク
  @todo_list = visible_tasks.todo
                            .where(status: [:todo, :doing])
                            .order(priority: :desc, deadline: :asc)
end

private

def task_params
  params.require(:task).permit(:title, :description, :deadline, :priority, :status, :task_type, :start_at, :end_at, :task_type,team_ids: [])
end

def set_task
  @task = Task.left_outer_joins(:teams)
              .where(user_id: current_user.id)
              .or(Task.left_outer_joins(:teams).where(teams: { id: current_user.team_ids }))
              .distinct
              .find(params[:id])
end

end
