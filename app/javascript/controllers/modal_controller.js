import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "content"]

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
    
    const modalWidth = content.offsetWidth;
    const modalHeight = content.offsetHeight;
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;

    // 左右位置
    let leftPos = rect.right + 10;
    if (leftPos + modalWidth > viewportWidth) {
      leftPos = rect.left - modalWidth - 10;
    }

    // 上下位置（ここが1回目だとmodalHeightが正しく取れずに失敗する）
    let topPos = rect.top;
    if (topPos + modalHeight > viewportHeight) {
      topPos = viewportHeight - modalHeight - 20;
    }
    if (topPos < 10) topPos = 10;

    content.style.left = `${leftPos}px`;
    content.style.top = `${topPos}px`;
  }

  // 3. Turbo Frameの中身が読み込まれた時に呼ばれる
  // HTML側で <turbo-frame data-action="turbo:frame-load->modal#reposition"> と書く
  close() {
    this.overlayTarget.classList.remove("is-visible");
    const frame = this.element.querySelector("turbo-frame");
    if (frame) frame.src = "";
  }

  closeOutside(event) {
    if (event.target === this.overlayTarget) {
      this.close();
    }
  }
}