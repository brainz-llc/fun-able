import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    dismissAfter: { type: Number, default: 5000 }
  }

  connect() {
    if (this.dismissAfterValue > 0) {
      setTimeout(() => this.dismiss(), this.dismissAfterValue)
    }
  }

  dismiss() {
    this.element.classList.add("opacity-0", "transition-opacity")
    setTimeout(() => this.element.remove(), 300)
  }
}
