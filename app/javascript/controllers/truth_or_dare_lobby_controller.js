import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["code", "codeValue", "copyFeedback", "playersList", "playerCount"]
  static values = {
    gameId: Number
  }

  connect() {
    this.subscribeToChannel()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create(
      { channel: "TruthOrDareChannel", game_id: this.gameIdValue },
      {
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleReceived(data) {
    switch (data.type) {
      case "player_joined":
        this.refreshPage()
        break
      case "player_left":
      case "player_kicked":
        this.refreshPage()
        break
      case "settings_updated":
        this.refreshPage()
        break
      case "game_started":
        // Navigate to game play
        window.location.href = window.location.href.replace("/lobby", "/play")
        break
    }
  }

  refreshPage() {
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  copyCode() {
    const code = this.codeValueTarget.textContent.trim()

    navigator.clipboard.writeText(code).then(() => {
      if (this.hasCopyFeedbackTarget) {
        this.copyFeedbackTarget.textContent = "Copiado!"
        this.copyFeedbackTarget.classList.add("animate-bounce-in")
        setTimeout(() => {
          this.copyFeedbackTarget.textContent = "Toca para copiar"
          this.copyFeedbackTarget.classList.remove("animate-bounce-in")
        }, 2000)
      }
    })
  }

  shareGame() {
    const code = this.codeValueTarget.textContent.trim()
    const shareUrl = window.location.origin + "/truth-or-dare/join-by-code?code=" + encodeURIComponent(code)
    const shareText = `Unete a mi partida de Verdad o Reto! Codigo: ${code}`

    // Use Web Share API if available (mobile)
    if (navigator.share) {
      navigator.share({
        title: "Verdad o Reto - Unete!",
        text: shareText,
        url: shareUrl
      }).catch((err) => {
        // User cancelled or error, fallback to copy
        if (err.name !== "AbortError") {
          this.copyShareLink(shareUrl)
        }
      })
    } else {
      // Fallback: copy link to clipboard
      this.copyShareLink(shareUrl)
    }
  }

  copyShareLink(url) {
    navigator.clipboard.writeText(url).then(() => {
      if (this.hasCopyFeedbackTarget) {
        this.copyFeedbackTarget.textContent = "Enlace copiado!"
        this.copyFeedbackTarget.classList.add("animate-bounce-in")
        setTimeout(() => {
          this.copyFeedbackTarget.textContent = "Toca para copiar"
          this.copyFeedbackTarget.classList.remove("animate-bounce-in")
        }, 2000)
      }
    })
  }
}
