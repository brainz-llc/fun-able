import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = [
    "card", "cardContent", "drinkButton", "nextButton", "scoreboard",
    "playersList", "readerIndicator", "pointsDisplay", "victoryModal",
    "victoryTitle", "mobileScoreboardOverlay", "mobileScoreboardBackdrop",
    "mobileScoreboardPanel"
  ]

  static values = {
    gameId: Number,
    playerId: Number,
    isReader: Boolean,
    isHost: Boolean
  }

  connect() {
    this.reconnectAttempts = 0
    this.maxReconnectAttempts = 10
    this.subscribeToChannel()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer)
    }
  }

  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create(
      { channel: "NeverHaveIEverChannel", game_id: this.gameIdValue },
      {
        connected: () => this.handleConnected(),
        disconnected: () => this.handleDisconnected(),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleConnected() {
    console.log("Connected to NeverHaveIEverChannel")
    this.reconnectAttempts = 0
    this.subscription.perform("request_state")
  }

  handleDisconnected() {
    console.log("Disconnected from NeverHaveIEverChannel")
    this.attemptReconnect()
  }

  attemptReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      this.showToast("Conexion perdida. Recarga la pagina.", "error")
      return
    }

    this.reconnectAttempts++
    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts - 1), 30000)

    this.reconnectTimer = setTimeout(() => {
      if (consumer.connection.isOpen()) {
        this.subscription.perform("request_state")
      }
    }, delay)
  }

  showToast(message, type = "info") {
    const existing = document.getElementById("nhie-toast")
    if (existing) existing.remove()

    const toast = document.createElement("div")
    toast.id = "nhie-toast"
    toast.className = `fixed bottom-20 left-1/2 transform -translate-x-1/2 px-6 py-3 rounded-lg shadow-lg z-50 text-white font-medium transition-all ${
      type === "success" ? "bg-green-500" : type === "error" ? "bg-red-500" : "bg-pink-500"
    }`
    toast.textContent = message
    document.body.appendChild(toast)

    setTimeout(() => {
      toast.style.opacity = "0"
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }

  handleReceived(data) {
    console.log("Received:", data.type, data)

    switch (data.type) {
      case "game_state":
        this.updateGameState(data)
        break
      case "player_joined":
      case "player_left":
      case "player_status_changed":
        window.Turbo.visit(window.location.href, { action: "replace" })
        break
      case "game_started":
      case "new_card":
        this.handleNewCard(data)
        break
      case "player_drank":
        this.handlePlayerDrank(data)
        break
      case "player_eliminated":
        this.handlePlayerEliminated(data)
        break
      case "game_ended":
        this.handleGameEnded(data)
        break
      case "settings_updated":
        window.Turbo.visit(window.location.href, { action: "replace" })
        break
    }
  }

  updateGameState(data) {
    // State is updated via page refresh when needed
  }

  handleNewCard(data) {
    // Refresh to show new card
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  handlePlayerDrank(data) {
    // Show toast notification
    if (data.player_id !== this.playerIdValue) {
      this.showToast(`${data.player_name} bebio!`, "info")
    }

    // Update leaderboard
    this.updateLeaderboard(data.leaderboard)

    // Update drink button state if current player drank
    if (data.player_id === this.playerIdValue && this.hasDrinkButtonTarget) {
      this.drinkButtonTarget.disabled = true
      this.drinkButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.drinkButtonTarget.innerHTML = '<span class="text-lg mr-2">&#10003;</span> Ya bebiste'
    }
  }

  handlePlayerEliminated(data) {
    this.showToast(`${data.player_name} ha sido eliminado!`, "error")

    // Fire confetti for elimination (sad confetti?)
    if (typeof window.confetti === "function") {
      window.confetti({
        particleCount: 50,
        spread: 50,
        colors: ['#ef4444', '#dc2626'],
        origin: { y: 0.6 }
      })
    }
  }

  handleGameEnded(data) {
    if (this.hasVictoryModalTarget) {
      this.victoryTitleTarget.textContent = data.winner_name
        ? `${data.winner_name} gana con ${data.winner_points} puntos!`
        : "Juego terminado!"

      this.victoryModalTarget.style.display = "flex"

      // Fire victory confetti
      if (typeof window.confetti === "function") {
        window.confetti({
          particleCount: 150,
          spread: 100,
          origin: { y: 0.6 }
        })
      }
    }

    setTimeout(() => {
      window.Turbo.visit(window.location.href)
    }, 5000)
  }

  updateLeaderboard(leaderboard) {
    if (!this.hasPlayersListTarget) return

    leaderboard.forEach(player => {
      const playerEl = document.querySelector(`[data-player-id="${player.id}"]`)
      if (playerEl) {
        const pointsEl = playerEl.querySelector('[data-points]')
        if (pointsEl) {
          pointsEl.textContent = player.points
          // Flash animation
          pointsEl.classList.add("scale-125", "text-pink-400")
          setTimeout(() => {
            pointsEl.classList.remove("scale-125", "text-pink-400")
          }, 300)
        }

        // Update drank indicator
        if (player.drank_this_round) {
          playerEl.classList.add("border-pink-500/50")
        }
      }
    })
  }

  drink(event) {
    event.preventDefault()
    const button = event.currentTarget
    button.disabled = true

    fetch(button.dataset.url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        this.showToast(data.error, "error")
        button.disabled = false
      } else {
        this.showToast("Bebiste! -1 punto", "info")
        if (this.hasPointsDisplayTarget) {
          this.pointsDisplayTarget.textContent = data.points
          this.pointsDisplayTarget.classList.add("scale-125", "text-pink-400")
          setTimeout(() => {
            this.pointsDisplayTarget.classList.remove("scale-125", "text-pink-400")
          }, 300)
        }
      }
    })
    .catch(error => {
      console.error("Error:", error)
      button.disabled = false
    })
  }

  nextCard(event) {
    event.preventDefault()
    const button = event.currentTarget
    button.disabled = true

    fetch(button.dataset.url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    })
    .then(response => {
      if (response.redirected) {
        window.location.href = response.url
      }
      return response.json()
    })
    .then(data => {
      if (data.error) {
        this.showToast(data.error, "error")
        button.disabled = false
      }
    })
    .catch(error => {
      console.error("Error:", error)
      button.disabled = false
    })
  }

  toggleScoreboard() {
    if (this.hasMobileScoreboardOverlayTarget) {
      this.toggleMobileScoreboard()
    }
  }

  toggleMobileScoreboard() {
    const overlay = this.mobileScoreboardOverlayTarget
    const backdrop = this.mobileScoreboardBackdropTarget
    const panel = this.mobileScoreboardPanelTarget

    const isOpen = !panel.classList.contains("translate-x-full")

    if (isOpen) {
      panel.classList.add("translate-x-full")
      backdrop.classList.add("opacity-0", "pointer-events-none")
      overlay.classList.add("pointer-events-none")
      document.body.style.overflow = ""
    } else {
      overlay.classList.remove("pointer-events-none")
      backdrop.classList.remove("opacity-0", "pointer-events-none")
      panel.classList.remove("translate-x-full")
      document.body.style.overflow = "hidden"
    }
  }

  closeVictory() {
    if (this.hasVictoryModalTarget) {
      this.victoryModalTarget.style.display = "none"
    }
  }
}
