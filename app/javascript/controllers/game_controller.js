import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["timer", "blackCard", "submissions", "scoreboard", "judgeMessage", "submissionCount", "victoryModal", "victoryTitle", "victoryGif", "connectionStatus", "mobileScoreboardOverlay", "mobileScoreboardBackdrop", "mobileScoreboardPanel"]
  static values = {
    id: Number,
    playerId: Number,
    isJudge: Boolean
  }

  connect() {
    this.reconnectAttempts = 0
    this.maxReconnectAttempts = 10
    this.wasConnected = false
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
      { channel: "GameChannel", game_id: this.idValue },
      {
        connected: () => this.handleConnected(),
        disconnected: () => this.handleDisconnected(),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleConnected() {
    console.log("Connected to GameChannel")
    this.reconnectAttempts = 0
    this.hideConnectionStatus()

    // Request fresh state on reconnection
    this.subscription.perform("request_state")

    // If this is a reconnection, refresh the page to get latest UI
    if (this.wasConnected) {
      console.log("Reconnected - refreshing page")
      this.showConnectionStatus("Reconectado", "success")
      setTimeout(() => {
        this.hideConnectionStatus()
        window.Turbo.visit(window.location.href, { action: "replace" })
      }, 500)
    }
    this.wasConnected = true
  }

  handleDisconnected() {
    console.log("Disconnected from GameChannel")
    this.showConnectionStatus("Conexión perdida. Reconectando...", "error")
    this.attemptReconnect()
  }

  attemptReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      this.showConnectionStatus("No se pudo reconectar. Recarga la página.", "error")
      return
    }

    this.reconnectAttempts++
    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts - 1), 30000)

    console.log(`Reconnect attempt ${this.reconnectAttempts} in ${delay}ms`)

    this.reconnectTimer = setTimeout(() => {
      if (consumer.connection.isOpen()) {
        this.subscription.perform("request_state")
      }
    }, delay)
  }

  showConnectionStatus(message, type) {
    // Create status element if it doesn't exist
    let statusEl = document.getElementById("connection-status")
    if (!statusEl) {
      statusEl = document.createElement("div")
      statusEl.id = "connection-status"
      statusEl.className = "fixed top-4 left-1/2 transform -translate-x-1/2 px-4 py-2 rounded-lg shadow-lg z-50 transition-all"
      document.body.appendChild(statusEl)
    }

    statusEl.textContent = message
    statusEl.classList.remove("bg-red-500", "bg-green-500", "hidden")
    statusEl.classList.add(type === "error" ? "bg-red-500" : "bg-green-500", "text-white")
  }

  hideConnectionStatus() {
    const statusEl = document.getElementById("connection-status")
    if (statusEl) {
      statusEl.classList.add("hidden")
    }
  }

  showToast(message, type = "info") {
    // Remove existing toast
    const existing = document.getElementById("game-toast")
    if (existing) existing.remove()

    const toast = document.createElement("div")
    toast.id = "game-toast"
    toast.className = `fixed bottom-20 left-1/2 transform -translate-x-1/2 px-6 py-3 rounded-lg shadow-lg z-50 text-white font-medium transition-all ${
      type === "success" ? "bg-green-500" : type === "error" ? "bg-red-500" : "bg-terracotta"
    }`
    toast.textContent = message
    document.body.appendChild(toast)

    // Auto-remove after 3 seconds
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
        this.updatePlayers(data)
        break
      case "game_started":
      case "new_round":
        this.handleNewRound(data)
        break
      case "card_submitted":
        this.handleCardSubmitted(data)
        break
      case "judging_started":
        this.handleJudgingStarted(data)
        break
      case "winner_selected":
        this.handleWinnerSelected(data)
        break
      case "game_ended":
        this.handleGameEnded(data)
        break
      case "timer_update":
        this.updateTimer(data)
        break
    }
  }

  updateGameState(data) {
    // Refresh page to get latest state
    if (data.game && data.game.status !== "lobby") {
      // Update UI based on game state
    }
  }

  updatePlayers(data) {
    // Turbo will handle this via broadcasts
  }

  handleNewRound(data) {
    // Refresh the page to get new round state
    window.Turbo.visit(window.location.href)
  }

  handleCardSubmitted(data) {
    // Show submission count update
    const submittedCount = data.submissions_count
    const expectedCount = data.expected_count

    console.log(`Card submitted: ${submittedCount}/${expectedCount}`)

    if (this.hasSubmissionCountTarget) {
      this.submissionCountTarget.textContent = `${submittedCount}/${expectedCount} jugadores han respondido`
    }

    // If all submitted, page will be refreshed by judging_started event
    if (data.all_submitted) {
      console.log("All players submitted - waiting for judging_started")
    }
  }

  handleJudgingStarted(data) {
    // Small delay to ensure server has committed changes, then refresh
    console.log("Judging started - refreshing page")
    setTimeout(() => {
      window.Turbo.visit(window.location.href, { action: "replace" })
    }, 300)
  }

  handleWinnerSelected(data) {
    // Highlight the winning submission briefly
    const winningEl = document.querySelector(`[data-submission-id="${data.winning_submission_id}"]`)
    if (winningEl) {
      winningEl.classList.add("ring-4", "ring-yellow-400", "scale-105")
    }

    // Quick refresh to next round
    setTimeout(() => {
      window.Turbo.visit(window.location.href)
    }, 2000)
  }

  handleGameEnded(data) {
    // Show victory modal after a short delay
    setTimeout(() => {
      this.showVictory(data.winner_name, "game_win")
    }, 1000)

    // Wait even longer for game winner celebration
    setTimeout(() => {
      window.Turbo.visit(window.location.href)
    }, 6000)
  }

  updateTimer(data) {
    const timerController = this.application.getControllerForElementAndIdentifier(
      this.timerTarget,
      "timer"
    )
    if (timerController) {
      timerController.updateFromServer(data.remaining)
    }
  }

  selectWinner(event) {
    const submissionId = event.currentTarget.dataset.submissionId
    console.log("Selecting winner:", submissionId)

    // Disable further clicks
    event.currentTarget.style.pointerEvents = "none"

    fetch(`/games/${this.idValue}/actions/select_winner`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ submission_id: submissionId })
    })
    .then(response => response.json())
    .then(data => {
      console.log("Winner selected:", data)
      if (data.error) {
        alert(data.error)
      }
    })
    .catch(error => {
      console.error("Error selecting winner:", error)
    })
  }

  toggleScoreboard() {
    // Check if we're on mobile (has mobile scoreboard overlay)
    if (this.hasMobileScoreboardOverlayTarget) {
      this.toggleMobileScoreboard()
    } else if (this.hasScoreboardTarget) {
      this.scoreboardTarget.classList.toggle("hidden")
    }
  }

  toggleMobileScoreboard() {
    const overlay = this.mobileScoreboardOverlayTarget
    const backdrop = this.mobileScoreboardBackdropTarget
    const panel = this.mobileScoreboardPanelTarget

    const isOpen = !panel.classList.contains("translate-x-full")

    if (isOpen) {
      // Close
      panel.classList.add("translate-x-full")
      backdrop.classList.add("opacity-0", "pointer-events-none")
      overlay.classList.add("pointer-events-none")
      document.body.style.overflow = ""
    } else {
      // Open
      overlay.classList.remove("pointer-events-none")
      backdrop.classList.remove("opacity-0", "pointer-events-none")
      panel.classList.remove("translate-x-full")
      document.body.style.overflow = "hidden"
    }
  }

  showVictory(winnerName, category) {
    if (!this.hasVictoryModalTarget) return

    this.victoryTitleTarget.textContent =
      category === "game_win"
        ? `🏆 ${winnerName} gana la partida! 🏆`
        : `🎉 ${winnerName} gana la ronda!`

    // Show loading placeholder
    this.victoryGifTarget.innerHTML = `
      <div class="w-full h-48 bg-bg-surface rounded flex items-center justify-center">
        <div class="animate-pulse text-text-secondary">Cargando...</div>
      </div>
    `

    // Fetch victory GIF
    fetch(`/api/v1/memes/victory?category=${category}`)
      .then(res => res.json())
      .then(data => {
        if (data.success && data.data.url) {
          const img = new Image()
          img.onload = () => {
            this.victoryGifTarget.innerHTML = `<img src="${data.data.url}" class="w-full rounded max-h-64 object-contain">`
          }
          img.src = data.data.url
        }
      })
      .catch(() => {
        this.victoryGifTarget.innerHTML = ""
      })

    this.victoryModalTarget.style.display = "flex"

    // Trigger confetti if available
    if (typeof window.confetti === "function") {
      window.confetti({
        particleCount: 150,
        spread: 100,
        origin: { y: 0.6 }
      })

      // Fire more confetti for game win
      if (category === "game_win") {
        setTimeout(() => {
          window.confetti({ particleCount: 100, angle: 60, spread: 55, origin: { x: 0 } })
          window.confetti({ particleCount: 100, angle: 120, spread: 55, origin: { x: 1 } })
        }, 500)
      }
    }
  }

  closeVictory() {
    if (this.hasVictoryModalTarget) {
      this.victoryModalTarget.style.display = "none"
    }
  }
}
