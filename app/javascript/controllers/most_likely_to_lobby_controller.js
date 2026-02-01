import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["playersList", "playerCount"]
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
      { channel: "MostLikelyToChannel", game_id: this.gameIdValue },
      {
        connected: () => console.log("Connected to MostLikelyToChannel (lobby)"),
        disconnected: () => console.log("Disconnected from MostLikelyToChannel (lobby)"),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleReceived(data) {
    console.log("Lobby received:", data.type, data)

    switch (data.type) {
      case "player_joined":
      case "player_left":
      case "player_status_changed":
        // Refresh page to update player list
        window.Turbo.visit(window.location.href, { action: "replace" })
        break
      case "game_started":
        // Navigate to game play
        window.Turbo.visit(window.location.href.replace("/lobby", "/play"))
        break
    }
  }
}
