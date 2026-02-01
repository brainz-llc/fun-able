import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = [
    "card", "players", "playerCard", "voteButton", "voteCount",
    "statusMessage", "roundInfo", "resultsOverlay", "winnerDisplay",
    "leaderboard", "countdown", "phaseIndicator"
  ]

  static values = {
    gameId: Number,
    playerId: Number,
    hasVoted: Boolean,
    phase: String
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
      { channel: "MostLikelyToChannel", game_id: this.gameIdValue },
      {
        connected: () => this.handleConnected(),
        disconnected: () => this.handleDisconnected(),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleConnected() {
    console.log("Connected to MostLikelyToChannel")
    this.reconnectAttempts = 0
    this.subscription.perform("request_state")
  }

  handleDisconnected() {
    console.log("Disconnected from MostLikelyToChannel")
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
        this.handleGameStarted(data)
        break
      case "vote_received":
        this.handleVoteReceived(data)
        break
      case "reveal_results":
        this.handleRevealResults(data)
        break
      case "new_round":
        this.handleNewRound(data)
        break
      case "game_ended":
        this.handleGameEnded(data)
        break
    }
  }

  updateGameState(data) {
    if (data.player) {
      this.hasVotedValue = data.player.has_voted
    }
    this.phaseValue = data.game.phase
  }

  updatePlayers(data) {
    // Refresh page to update player list
    if (!this.phaseValue || this.phaseValue === 'waiting') {
      window.Turbo.visit(window.location.href, { action: "replace" })
    }
  }

  handleGameStarted(data) {
    window.Turbo.visit(window.location.href, { action: "replace" })
  }

  handleVoteReceived(data) {
    // Update vote count display
    if (this.hasVoteCountTarget) {
      this.voteCountTarget.textContent = `${data.votes_count}/${data.expected_count}`
    }

    // Mark voter as having voted
    const voterCard = this.element.querySelector(`[data-player-id="${data.voter_id}"]`)
    if (voterCard) {
      voterCard.classList.add("has-voted")
      const voteIndicator = voterCard.querySelector("[data-vote-indicator]")
      if (voteIndicator) {
        voteIndicator.classList.remove("hidden")
      }
    }

    // Update status message
    if (this.hasStatusMessageTarget) {
      if (data.all_voted) {
        this.statusMessageTarget.textContent = "Revelando resultados..."
      } else {
        this.statusMessageTarget.textContent = `Esperando votos... ${data.votes_count}/${data.expected_count}`
      }
    }
  }

  handleRevealResults(data) {
    this.phaseValue = 'revealing'

    // Hide voting UI
    this.voteButtonTargets.forEach(btn => {
      btn.disabled = true
      btn.classList.add("opacity-50", "cursor-not-allowed")
    })

    // Animate vote reveals
    this.animateVoteReveal(data.all_players, data.winners)
  }

  animateVoteReveal(players, winners) {
    const winnerIds = winners.map(w => w.id)

    // Sort players by votes received (highest first)
    const sortedPlayers = [...players].sort((a, b) => b.votes_received - a.votes_received)

    // Reveal votes one by one
    sortedPlayers.forEach((player, index) => {
      setTimeout(() => {
        const playerCard = this.element.querySelector(`[data-player-id="${player.id}"]`)
        if (playerCard) {
          // Update vote count
          const voteDisplay = playerCard.querySelector("[data-votes-received]")
          if (voteDisplay) {
            voteDisplay.textContent = player.votes_received
            voteDisplay.classList.remove("hidden")
          }

          // Highlight if winner
          if (winnerIds.includes(player.id)) {
            playerCard.classList.add("ring-4", "ring-yellow-400", "scale-105")
            playerCard.style.boxShadow = "0 0 30px rgba(251, 191, 36, 0.5)"

            // Add drink indicator
            const drinkBadge = playerCard.querySelector("[data-drink-badge]")
            if (drinkBadge) {
              drinkBadge.classList.remove("hidden")
              drinkBadge.classList.add("animate-bounce")
            }
          }
        }
      }, index * 300)
    })

    // Show celebration for winners after reveals
    setTimeout(() => {
      if (winners.length > 0 && typeof window.confetti === "function") {
        window.confetti({
          particleCount: 100,
          spread: 70,
          origin: { y: 0.6 }
        })
      }
    }, sortedPlayers.length * 300 + 500)
  }

  handleNewRound(data) {
    this.hasVotedValue = false
    this.phaseValue = 'voting'

    // Refresh page to get new round
    setTimeout(() => {
      window.Turbo.visit(window.location.href, { action: "replace" })
    }, 3000)
  }

  handleGameEnded(data) {
    // Show final results modal
    if (this.hasResultsOverlayTarget) {
      this.resultsOverlayTarget.classList.remove("hidden")
      this.resultsOverlayTarget.classList.add("flex")

      if (data.final_leaderboard && this.hasLeaderboardTarget) {
        this.renderLeaderboard(data.final_leaderboard)
      }
    }

    // Confetti for winner
    if (typeof window.confetti === "function") {
      window.confetti({
        particleCount: 150,
        spread: 100,
        origin: { y: 0.6 }
      })
    }

    // Redirect after showing results
    setTimeout(() => {
      window.Turbo.visit(window.location.href, { action: "replace" })
    }, 5000)
  }

  renderLeaderboard(leaderboard) {
    this.leaderboardTarget.innerHTML = leaderboard.map((player, index) => `
      <div class="flex items-center justify-between p-3 rounded-lg ${index === 0 ? 'bg-yellow-500/20 border border-yellow-400/50' : 'bg-white/5'}">
        <div class="flex items-center gap-3">
          <span class="text-lg font-bold ${index === 0 ? 'text-yellow-400' : 'text-white/60'}">#${index + 1}</span>
          <span class="text-white font-medium">${player.display_name}</span>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">🍺</span>
          <span class="text-xl font-bold text-cyan-400">${player.drinks}</span>
        </div>
      </div>
    `).join('')
  }

  vote(event) {
    if (this.hasVotedValue) {
      this.showToast("Ya votaste esta ronda", "error")
      return
    }

    const playerId = event.currentTarget.dataset.playerId
    const playerCard = event.currentTarget

    // Disable all vote buttons
    this.voteButtonTargets.forEach(btn => {
      btn.disabled = true
    })

    // Highlight selected player
    playerCard.classList.add("ring-2", "ring-pink-500", "scale-105")

    fetch(`/most-likely-to/${this.gameIdValue}/vote`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ player_id: playerId })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.hasVotedValue = true
        this.showToast("Voto registrado!", "success")
      } else if (data.error) {
        this.showToast(data.error, "error")
        // Re-enable buttons
        this.voteButtonTargets.forEach(btn => {
          btn.disabled = false
        })
        playerCard.classList.remove("ring-2", "ring-pink-500", "scale-105")
      }
    })
    .catch(error => {
      console.error("Error voting:", error)
      this.showToast("Error al votar", "error")
    })
  }

  showToast(message, type = "info") {
    const existing = document.getElementById("mlt-toast")
    if (existing) existing.remove()

    const toast = document.createElement("div")
    toast.id = "mlt-toast"
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

  closeResults() {
    if (this.hasResultsOverlayTarget) {
      this.resultsOverlayTarget.classList.add("hidden")
      this.resultsOverlayTarget.classList.remove("flex")
    }
  }

  nextRound() {
    fetch(`/most-likely-to/${this.gameIdValue}/next_round`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        if (data.finished) {
          // Game ended
          window.Turbo.visit(window.location.href, { action: "replace" })
        }
        // New round will be handled by the broadcast
      } else if (data.error) {
        this.showToast(data.error, "error")
      }
    })
    .catch(error => {
      console.error("Error advancing round:", error)
      this.showToast("Error al avanzar ronda", "error")
    })
  }

  endGame() {
    // Just trigger next round which will detect it's the last round
    this.nextRound()
  }
}
