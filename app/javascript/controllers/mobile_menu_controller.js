import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open() {
    this.element.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.element.classList.add("hidden")
    document.body.style.overflow = ""
  }

  toggle() {
    if (this.element.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  disconnect() {
    document.body.style.overflow = ""
  }
}
