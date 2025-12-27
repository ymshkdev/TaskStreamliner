const taskFormManager = {
  // 1. SlimSelectの初期化（リトライ機能付き）
  initSlimSelect(retryCount = 0) {
    const el = document.getElementById('team-select');
    if (!el || el.dataset.ssInit === "true") return;

    const SS = window.SlimSelect;
    if (SS) {
      try {
        new SS({
          select: el,
          settings: {
            placeholderText: 'プライベート（外部共有なし）',
            allowDeselect: true,
            closeOnSelect: false
          }
        });
        el.dataset.ssInit = "true";
        console.log("SlimSelect initialized");
      } catch (e) {
        console.error("SlimSelect error:", e);
      }
    } else if (retryCount < 50) {
      setTimeout(() => this.initSlimSelect(retryCount + 1), 100);
    }
  },

  // 2. 開始時間に合わせて終了時間を1時間後にセット
  handleAutoFill() {
    const startAtInput = document.querySelector('input[name="task[start_at]"]');
    const endAtInput = document.querySelector('input[name="task[end_at]"]');
    
    if (startAtInput && startAtInput.value && endAtInput) {
      const startDate = new Date(startAtInput.value);
      if (isNaN(startDate.getTime())) return;

      // 1時間加算
      startDate.setHours(startDate.getHours() + 1);
      
      const format = (num) => num.toString().padStart(2, '0');
      const value = `${startDate.getFullYear()}-${format(startDate.getMonth() + 1)}-${format(startDate.getDate())}T${format(startDate.getHours())}:${format(startDate.getMinutes())}`;
      
      endAtInput.value = value;
      console.log("Auto-filled end time to:", value);
    }
  },

  // 3. 表示項目の切り替え（TODO/予定）
  applyTaskTypeFields() {
    const todoFields = document.getElementById('todo-fields');
    const scheduleFields = document.getElementById('schedule-fields');
    const statusField = document.getElementById('status-field');
    const checkedElement = document.querySelector('.type-selector:checked');
    
    if (!todoFields || !scheduleFields || !checkedElement) return;

    const isTodo = checkedElement.value === 'todo';
    todoFields.style.display = isTodo ? 'block' : 'none';
    scheduleFields.style.display = isTodo ? 'none' : 'block';
    if (statusField) statusField.style.display = isTodo ? 'block' : 'none';

    // 初期値のセット（カレンダーからの遷移時）
    const urlParams = new URLSearchParams(window.location.search);
    const selectedDate = urlParams.get('selected_date') || urlParams.get('deadline');

    if (selectedDate) {
      if (isTodo) {
        const deadlineInput = document.querySelector('input[name="task[deadline]"]');
        if (deadlineInput && !deadlineInput.value) deadlineInput.value = `${selectedDate}T00:00`;
      } else {
        const startAtInput = document.querySelector('input[name="task[start_at]"]');
        if (startAtInput && !startAtInput.value) {
          startAtInput.value = `${selectedDate}T09:00`;
          this.handleAutoFill(); // 09:00セット時に10:00も自動セット
        }
      }
    }
  },

  // 4. 全体の初期化実行
  init() {
    console.log("Task Form Initialization...");

    this.applyTaskTypeFields();
    this.initSlimSelect();

    // 開始時間の変更イベントを監視
    const startAtInput = document.querySelector('input[name="task[start_at]"]');
    if (startAtInput) {
      // ユーザーが時間をカチカチ変えた瞬間に反応させる
      startAtInput.oninput = () => {
        console.log("Start time changed by user");
        this.handleAutoFill();
      };
      // 念のためフォーカスが外れた時も
      startAtInput.onchange = () => this.handleAutoFill();
    }

    // TODO/予定の切り替えイベント
    document.querySelectorAll('.type-selector').forEach(el => {
      el.onchange = () => this.applyTaskTypeFields();
    });
  }
};

// Turboイベントへの登録
document.addEventListener('turbo:load', () => setTimeout(() => taskFormManager.init(), 100));
document.addEventListener('turbo:render', () => setTimeout(() => taskFormManager.init(), 100));
document.addEventListener('turbo:frame-load', () => setTimeout(() => taskFormManager.init(), 100));