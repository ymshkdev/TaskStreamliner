import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "container" ]

  // サイドバーを切り替える（開いてれば閉じ、閉じてれば開く）
  toggle() {
    this.containerTarget.classList.toggle("is-opened")
  }

  // 強制的に閉じる（×ボタンや背景クリック用）
  close() {
    this.containerTarget.classList.remove("is-opened")
  }

  toggleSection(event) {
    // クリックされたヘッダーの親要素（section）を探して、クラスを切り替える
    const section = event.currentTarget.closest(".sidebar-section");
    section.classList.toggle("section-opened");
  }

  toggleTeamDisplay(event) {
    const teamId = event.target.dataset.teamId;
    const isChecked = event.target.checked;
    
    // カレンダー内の特定のチームIDを持つ要素をすべて取得
    const taskElements = document.querySelectorAll(`.task-entry[data-team-id="${teamId}"]`);
    
    taskElements.forEach(el => {
      isChecked ? el.classList.remove("is-faded") : el.classList.add("is-faded");
    });
  }

  toggleMyTasksOnly(event) {
  const showOnlyMine = event.target.checked;
  // すべてのタスク要素を取得
  const allTasks = document.querySelectorAll('.task-entry');

  allTasks.forEach(el => {
    // data-team-id が空（""）または "null"、あるいは設定されていないものが「自分の予定」
    const teamId = el.dataset.teamId;
    const isPersonal = (!teamId || teamId === "" || teamId === "null");

    if (showOnlyMine) {
      // 「自分の予定のみ」にチェックが入った時：チームタスクを消す
      if (!isPersonal) {
        el.style.display = 'none';
      }
    } else {
      // チェックが外れた時：すべて表示に戻す
      el.style.display = '';
    }
   });
  }
}

