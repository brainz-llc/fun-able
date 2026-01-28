import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Store original body overflow
    this.originalBodyOverflow = document.body.style.overflow
  }

  open() {
    this.element.classList.remove("hidden")
    // Prevent body scroll when menu is open
    document.body.style.overflow = "hidden"
    // Focus trap - focus the close button
    requestAnimationFrame(() => {
      const closeButton = this.element.querySelector('[aria-label="Close menu"]')
      if (closeButton) closeButton.focus()
    })
  }

  close() {
    this.element.classList.add("hidden")
    // Restore body scroll
    document.body.style.overflow = this.originalBodyOverflow || ""
  }

  toggle() {
    if (this.element.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  disconnect() {
    // Ensure body scroll is restored on disconnect
    document.body.style.overflow = this.originalBodyOverflow || ""
  }
}
