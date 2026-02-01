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
      { channel: "NeverHaveIEverChannel", game_id: this.gameIdValue },
      {
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleReceived(data) {
    switch (data.type) {
      case "player_joined":
        this.addPlayer(data.player)
        this.updatePlayerCount(data.player_count)
        break
      case "player_left":
      case "player_kicked":
        this.removePlayer(data.player_id)
        this.updatePlayerCount(data.player_count)
        break
      case "settings_updated":
        window.Turbo.visit(window.location.href, { action: "replace" })
        break
      case "game_started":
        window.Turbo.visit(window.location.href.replace("/lobby", ""))
        break
    }
  }

  addPlayer(player) {
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  removePlayer(playerId) {
    const playerElement = document.getElementById(`nhie_player_${playerId}`)
    if (playerElement) {
      playerElement.remove()
    }
  }

  updatePlayerCount(count) {
    if (this.hasPlayerCountTarget) {
      this.playerCountTarget.textContent = count
    }
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
    const shareUrl = window.location.origin + "/never-have-i-ever/join?code=" + encodeURIComponent(code)
    const shareText = `Unete a mi partida de Yo Nunca Nunca! Codigo: ${code}`

    if (navigator.share) {
      navigator.share({
        title: "Yo Nunca Nunca - Unete a la partida!",
        text: shareText,
        url: shareUrl
      }).catch((err) => {
        if (err.name !== "AbortError") {
          this.copyShareLink(shareUrl)
        }
      })
    } else {
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
