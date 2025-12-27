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
}