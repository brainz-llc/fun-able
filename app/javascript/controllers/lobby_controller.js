import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["code", "copyFeedback", "playersList", "playerCount"]
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
      { channel: "GameChannel", game_id: this.gameIdValue },
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
        // Refresh to show new settings
        window.Turbo.visit(window.location.href, { action: "replace" })
        break
      case "game_started":
        // Navigate to game play
        window.Turbo.visit(window.location.href.replace("/lobby", ""))
        break
    }
  }

  addPlayer(player) {
    // Refresh player list via Turbo
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  removePlayer(playerId) {
    const playerElement = document.getElementById(`player_${playerId}`)
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
    const code = this.codeTarget.textContent.trim()

    navigator.clipboard.writeText(code).then(() => {
      if (this.hasCopyFeedbackTarget) {
        this.copyFeedbackTarget.textContent = "Copiado!"
        setTimeout(() => {
          this.copyFeedbackTarget.textContent = ""
        }, 2000)
      }
    })
  }
}
