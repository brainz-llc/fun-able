import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = [
    "optionA", "optionB", "timer", "voteCount", "resultOverlay",
    "resultOptionA", "resultOptionB", "percentageA", "percentageB",
    "minorityMessage", "leaderboard", "roundInfo", "nextRoundBtn",
    "drinkAnimation", "playerList"
  ]

  static values = {
    gameId: Number,
    playerId: Number,
    isHost: Boolean,
    hasVoted: Boolean,
    phase: String
  }

  connect() {
    this.subscribeToChannel()
    this.startTimerIfNeeded()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
  }

  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create(
      { channel: "WouldYouRatherChannel", game_id: this.gameIdValue },
      {
        connected: () => this.handleConnected(),
        disconnected: () => this.handleDisconnected(),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleConnected() {
    console.log("Connected to WouldYouRatherChannel")
  }

  handleDisconnected() {
    console.log("Disconnected from WouldYouRatherChannel")
  }

  handleReceived(data) {
    console.log("Received:", data.type, data)

    switch (data.type) {
      case "game_started":
      case "new_round":
        this.handleNewRound(data)
        break
      case "vote_submitted":
        this.handleVoteSubmitted(data)
        break
      case "votes_revealed":
        this.handleVotesRevealed(data)
        break
      case "game_ended":
        this.handleGameEnded(data)
        break
      case "player_joined":
      case "player_left":
      case "player_status_changed":
        this.updatePlayerList(data)
        break
    }
  }

  startTimerIfNeeded() {
    const timerEl = this.hasTimerTarget ? this.timerTarget : null
    if (!timerEl) return

    const endsAt = timerEl.dataset.votingEndsAt
    if (!endsAt) return

    this.updateTimer(new Date(endsAt))
    this.timerInterval = setInterval(() => {
      this.updateTimer(new Date(endsAt))
    }, 1000)
  }

  updateTimer(endsAt) {
    if (!this.hasTimerTarget) return

    const now = new Date()
    const diff = Math.max(0, Math.ceil((endsAt - now) / 1000))

    this.timerTarget.textContent = diff

    if (diff <= 5) {
      this.timerTarget.classList.add("text-red-500", "animate-pulse")
    } else if (diff <= 10) {
      this.timerTarget.classList.add("text-yellow-500")
      this.timerTarget.classList.remove("text-cyan-400")
    }

    if (diff === 0) {
      clearInterval(this.timerInterval)
    }
  }

  vote(event) {
    if (this.hasVotedValue) return

    const choice = event.currentTarget.dataset.choice
    this.hasVotedValue = true

    // Disable both buttons
    if (this.hasOptionATarget) {
      this.optionATarget.classList.add("pointer-events-none")
    }
    if (this.hasOptionBTarget) {
      this.optionBTarget.classList.add("pointer-events-none")
    }

    // Highlight selected option
    if (choice === "a" && this.hasOptionATarget) {
      this.optionATarget.classList.add("ring-4", "ring-pink-500", "scale-105")
    } else if (choice === "b" && this.hasOptionBTarget) {
      this.optionBTarget.classList.add("ring-4", "ring-cyan-500", "scale-105")
    }

    // Send vote
    fetch(`/would-you-rather/${this.gameIdValue}/vote`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ choice: choice })
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        this.showToast(data.error, "error")
      } else {
        this.showToast("Voto registrado!", "success")
      }
    })
    .catch(error => {
      console.error("Error voting:", error)
      this.showToast("Error al votar", "error")
    })
  }

  handleNewRound(data) {
    // Refresh page to show new round
    window.location.reload()
  }

  handleVoteSubmitted(data) {
    if (this.hasVoteCountTarget) {
      this.voteCountTarget.textContent = `${data.votes_count}/${data.total_players}`
    }

    // Add pulse animation to vote count
    if (this.hasVoteCountTarget) {
      this.voteCountTarget.classList.add("animate-pulse")
      setTimeout(() => {
        this.voteCountTarget.classList.remove("animate-pulse")
      }, 500)
    }
  }

  handleVotesRevealed(data) {
    // Stop timer
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }

    // Show results overlay
    if (this.hasResultOverlayTarget) {
      this.resultOverlayTarget.classList.remove("hidden")
      this.resultOverlayTarget.classList.add("flex")
    }

    // Animate percentages
    this.animatePercentages(data.option_a_percentage, data.option_b_percentage)

    // Show minority message
    if (this.hasMinorityMessageTarget) {
      if (data.is_tie) {
        this.minorityMessageTarget.textContent = "Empate! Nadie bebe esta ronda."
        this.minorityMessageTarget.classList.add("text-yellow-400")
      } else {
        const minorityOption = data.minority_choice === "a" ? "A" : "B"
        this.minorityMessageTarget.textContent = `La minoria eligio la Opcion ${minorityOption}. A beber!`
        this.minorityMessageTarget.classList.add(data.minority_choice === "a" ? "text-pink-400" : "text-cyan-400")
      }
    }

    // Highlight minority players with drink animation
    if (data.minority_player_ids && data.minority_player_ids.length > 0) {
      this.showDrinkAnimation(data.minority_player_ids)
    }

    // Update leaderboard
    if (this.hasLeaderboardTarget && data.leaderboard) {
      this.updateLeaderboard(data.leaderboard)
    }

    // Show next round button for host
    if (this.isHostValue && this.hasNextRoundBtnTarget) {
      setTimeout(() => {
        this.nextRoundBtnTarget.classList.remove("hidden")
      }, 3000)
    }
  }

  animatePercentages(percentA, percentB) {
    if (this.hasPercentageATarget && this.hasPercentageBTarget) {
      let currentA = 0
      let currentB = 0
      const duration = 1500
      const steps = 60
      const intervalTime = duration / steps
      const stepA = percentA / steps
      const stepB = percentB / steps

      const interval = setInterval(() => {
        currentA = Math.min(currentA + stepA, percentA)
        currentB = Math.min(currentB + stepB, percentB)

        this.percentageATarget.textContent = `${Math.round(currentA)}%`
        this.percentageBTarget.textContent = `${Math.round(currentB)}%`

        // Animate the progress bars
        if (this.hasResultOptionATarget) {
          this.resultOptionATarget.style.setProperty("--percentage", `${currentA}%`)
        }
        if (this.hasResultOptionBTarget) {
          this.resultOptionBTarget.style.setProperty("--percentage", `${currentB}%`)
        }

        if (currentA >= percentA && currentB >= percentB) {
          clearInterval(interval)
        }
      }, intervalTime)
    }
  }

  showDrinkAnimation(playerIds) {
    // Add drink animation to minority players
    playerIds.forEach(playerId => {
      const playerEl = document.querySelector(`[data-player-id="${playerId}"]`)
      if (playerEl) {
        playerEl.classList.add("animate-bounce", "ring-2", "ring-red-500")

        // Show drink emoji
        const drinkEmoji = document.createElement("span")
        drinkEmoji.className = "absolute -top-2 -right-2 text-2xl animate-bounce"
        drinkEmoji.textContent = "🍺"
        playerEl.style.position = "relative"
        playerEl.appendChild(drinkEmoji)

        setTimeout(() => {
          playerEl.classList.remove("animate-bounce", "ring-2", "ring-red-500")
          drinkEmoji.remove()
        }, 3000)
      }
    })

    // Show global drink animation
    if (this.hasDrinkAnimationTarget) {
      this.drinkAnimationTarget.classList.remove("hidden")
      setTimeout(() => {
        this.drinkAnimationTarget.classList.add("hidden")
      }, 3000)
    }
  }

  updateLeaderboard(leaderboard) {
    if (!this.hasLeaderboardTarget) return

    const html = leaderboard.map((player, idx) => `
      <div class="flex items-center justify-between py-2 px-3 rounded-lg ${idx === 0 ? 'bg-yellow-500/10 border border-yellow-500/30' : 'bg-white/5'}">
        <div class="flex items-center gap-2">
          <span class="text-sm font-bold text-white/50">#${idx + 1}</span>
          <span class="text-sm font-medium text-white">${player.display_name}</span>
        </div>
        <div class="flex items-center gap-3">
          <span class="text-xs text-cyan-400">${player.current_streak} racha</span>
          <span class="text-sm font-bold ${player.drinks_taken > 0 ? 'text-pink-400' : 'text-green-400'}">
            ${player.drinks_taken} 🍺
          </span>
        </div>
      </div>
    `).join("")

    this.leaderboardTarget.innerHTML = html
  }

  updatePlayerList(data) {
    // Refresh page to update player list
    if (data.type === "player_joined" || data.type === "player_left") {
      window.location.reload()
    }
  }

  handleGameEnded(data) {
    // Redirect to finished page
    window.location.reload()
  }

  nextRound() {
    fetch(`/would-you-rather/${this.gameIdValue}/next_round`, {
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
      }
    })
    .catch(error => {
      console.error("Error:", error)
    })
  }

  showToast(message, type = "info") {
    const existing = document.getElementById("wyr-toast")
    if (existing) existing.remove()

    const toast = document.createElement("div")
    toast.id = "wyr-toast"
    toast.className = `fixed bottom-20 left-1/2 transform -translate-x-1/2 px-6 py-3 rounded-lg shadow-lg z-50 text-white font-medium transition-all ${
      type === "success" ? "bg-green-500" : type === "error" ? "bg-red-500" : "bg-purple-500"
    }`
    toast.textContent = message
    document.body.appendChild(toast)

    setTimeout(() => {
      toast.style.opacity = "0"
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}
