import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "content"]
  
  connect() {
    // ページが読み込まれた（または遷移した）時にモーダルを確実に閉じる
    this.close();
  }

  // 1. 最初にクリックされた時
  open(event) {
    // クリックした位置を一旦保存しておく（再計算で使うため）
    this.lastClickRect = event.currentTarget.getBoundingClientRect();
    
    this.overlayTarget.classList.add("is-visible");
    
    // 1回目：とりあえず表示（この時点では中身が空で高さが足りない可能性が高い）
    this.reposition();
  }

  // 2. 位置を計算する本体
  reposition() {
  if (!this.lastClickRect || !this.hasContentTarget) return;

  const rect = this.lastClickRect;
  const content = this.contentTarget;
  const isDayPage = !!document.querySelector(".day-timeline"); // Dayページ判定
  
  // 1. 基本となる要素のサイズと画面情報を取得
    const modalWidth = content.offsetWidth;
    const modalHeight = content.offsetHeight;
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    const scrollY = window.pageYOffset || document.documentElement.scrollTop;

  // 1. 左右位置の計算（画面右端での折り返し）
  if (isDayPage) {
      // --- Dayページの場合は画面中央に固定（画像の問題を確実に防ぐ） ---
      content.style.position = "fixed";
      content.style.top = "50%";
      content.style.left = "50%";
      content.style.transform = "translate(-50%, -50%)";
      content.style.margin = "0";
    } else {
      // --- それ以外（index等）はクリック位置に合わせる ---
      content.style.position = "absolute";
      content.style.transform = "none";

      // サイドバーの右端を取得して左側の限界線にする
      const sidebar = document.querySelector(".sidebar");
      const leftLimit = sidebar ? sidebar.getBoundingClientRect().right + 10 : 10;

      // 左右位置の計算
      let leftPos = rect.right + 10;
      // 右にはみ出すなら左側に置く
      if (leftPos + modalWidth > viewportWidth - 10) {
        leftPos = rect.left - modalWidth - 10;
      }
      // 【重要】左に置いた結果、左限界（サイドバー）を突き抜けるなら限界線で止める
      if (leftPos < leftLimit) {
        leftPos = leftLimit;
      }

      // 上下位置の計算
      let topPos = rect.top + scrollY;
      const viewTop = scrollY + 10;
      const viewBottom = scrollY + viewportHeight - 20;

      if (topPos + modalHeight > viewBottom) {
        topPos = viewBottom - modalHeight;
      }
      if (topPos < viewTop) {
        topPos = viewTop;
      }

      content.style.left = `${leftPos}px`;
      content.style.top = `${topPos}px`;
    }
  }

  // 3. Turbo Frameの中身が読み込まれた時に呼ばれる
  // HTML側で <turbo-frame data-action="turbo:frame-load->modal#reposition"> と書く

  closeOutside(event) {
    // クリックされたのが overlay（暗い背景）そのものだった場合のみ閉じる
    if (event.target === this.overlayTarget) {
      this.close();
    }
  }
  
  close() {
    this.lastClickRect = null;
    this.overlayTarget.classList.remove("is-visible");
    
    // スタイルをリセットして次の表示に備える
    const content = this.contentTarget;
    content.style.transform = "";
    content.style.top = "";
    content.style.left = "";
    content.style.position = "absolute"; // 基本の absolute に戻す

    const frame = this.element.querySelector("turbo-frame");
    if (frame) frame.src = "";
  }
}