import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = {
    expiresAt: String
  }

  connect() {
    if (this.expiresAtValue) {
      this.startCountdown()
    }
  }

  disconnect() {
    this.stopCountdown()
  }

  startCountdown() {
    this.updateDisplay()
    this.interval = setInterval(() => this.updateDisplay(), 1000)
  }

  stopCountdown() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  updateDisplay() {
    const remaining = this.calculateRemaining()

    if (remaining <= 0) {
      this.displayTarget.textContent = "0"
      this.element.classList.add("timer-critical")
      this.stopCountdown()
      return
    }

    this.displayTarget.textContent = remaining

    // Update styling based on time remaining
    this.element.classList.remove("timer-warning", "timer-critical")
    if (remaining <= 10) {
      this.element.classList.add("timer-critical")
    } else if (remaining <= 20) {
      this.element.classList.add("timer-warning")
    }
  }

  calculateRemaining() {
    if (!this.expiresAtValue) return 0

    const expiresAt = new Date(this.expiresAtValue)
    const now = new Date()
    return Math.max(0, Math.floor((expiresAt - now) / 1000))
  }

  updateFromServer(remaining) {
    // Sync with server time
    const newExpiresAt = new Date(Date.now() + remaining * 1000)
    this.expiresAtValue = newExpiresAt.toISOString()
    this.updateDisplay()
  }

  expiresAtValueChanged() {
    this.stopCountdown()
    if (this.expiresAtValue) {
      this.startCountdown()
    }
  }
}
