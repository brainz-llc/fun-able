import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = [
    "truthButton", "dareButton", "cardDisplay", "cardContent", "cardType",
    "completeButton", "drinkButton", "currentPlayer", "playersList",
    "turnIndicator", "actionButtons", "responseButtons", "leaderboard"
  ]

  static values = {
    gameId: Number,
    playerId: Number,
    isMyTurn: Boolean
  }

  connect() {
    this.subscribeToChannel()
    this.currentCard = null
    this.currentCardType = null
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
        connected: () => this.handleConnected(),
        disconnected: () => this.handleDisconnected(),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleConnected() {
    console.log("Connected to TruthOrDareChannel")
    this.subscription.perform("request_state")
  }

  handleDisconnected() {
    console.log("Disconnected from TruthOrDareChannel")
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
        this.refreshPage()
        break
      case "game_started":
        this.handleGameStarted(data)
        break
      case "card_drawn":
        this.handleCardDrawn(data)
        break
      case "turn_completed":
        this.handleTurnCompleted(data)
        break
      case "game_ended":
        this.handleGameEnded(data)
        break
    }
  }

  updateGameState(data) {
    // Update UI based on current state
  }

  handleGameStarted(data) {
    window.location.reload()
  }

  handleCardDrawn(data) {
    // Show the card to all players
    this.showCard(data.card_type, data.card, data.player_name)
  }

  handleTurnCompleted(data) {
    // Update leaderboard
    if (this.hasLeaderboardTarget) {
      this.updateLeaderboard(data.leaderboard)
    }

    // Show notification
    const message = data.drank
      ? `${data.player_name} tomo un trago!`
      : `${data.player_name} completo el reto!`
    this.showToast(message, data.drank ? "warning" : "success")

    // Refresh page for next turn
    setTimeout(() => {
      window.location.reload()
    }, 1500)
  }

  handleGameEnded(data) {
    this.showToast("Juego terminado!", "info")
    setTimeout(() => {
      window.location.reload()
    }, 2000)
  }

  // User actions
  chooseTruth(event) {
    event.preventDefault()
    if (!this.isMyTurnValue) return

    this.setButtonsLoading(true)
    this.animateChoice("truth")

    fetch(`/truth-or-dare/${this.gameIdValue}/choose-truth`, {
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
        this.currentCard = data.card
        this.currentCardType = "truth"
      } else {
        this.showToast(data.error || "Error", "error")
        this.setButtonsLoading(false)
      }
    })
    .catch(error => {
      console.error("Error:", error)
      this.showToast("Error de conexion", "error")
      this.setButtonsLoading(false)
    })
  }

  chooseDare(event) {
    event.preventDefault()
    if (!this.isMyTurnValue) return

    this.setButtonsLoading(true)
    this.animateChoice("dare")

    fetch(`/truth-or-dare/${this.gameIdValue}/choose-dare`, {
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
        this.currentCard = data.card
        this.currentCardType = "dare"
      } else {
        this.showToast(data.error || "Error", "error")
        this.setButtonsLoading(false)
      }
    })
    .catch(error => {
      console.error("Error:", error)
      this.showToast("Error de conexion", "error")
      this.setButtonsLoading(false)
    })
  }

  completeChallenge(event) {
    event.preventDefault()
    if (!this.currentCardType) return

    fetch(`/truth-or-dare/${this.gameIdValue}/complete`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ challenge_type: this.currentCardType })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showToast("Completado!", "success")
      } else {
        this.showToast(data.error || "Error", "error")
      }
    })
    .catch(error => {
      console.error("Error:", error)
      this.showToast("Error de conexion", "error")
    })
  }

  drink(event) {
    event.preventDefault()
    if (!this.currentCardType) return

    fetch(`/truth-or-dare/${this.gameIdValue}/drink`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ challenge_type: this.currentCardType })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showToast("Salud!", "warning")
      } else {
        this.showToast(data.error || "Error", "error")
      }
    })
    .catch(error => {
      console.error("Error:", error)
      this.showToast("Error de conexion", "error")
    })
  }

  // UI helpers
  animateChoice(type) {
    const truthBtn = this.hasTruthButtonTarget ? this.truthButtonTarget : null
    const dareBtn = this.hasDareButtonTarget ? this.dareButtonTarget : null

    if (type === "truth" && truthBtn) {
      truthBtn.classList.add("scale-110", "ring-4", "ring-cyan-400")
      if (dareBtn) dareBtn.classList.add("opacity-30", "scale-90")
    } else if (type === "dare" && dareBtn) {
      dareBtn.classList.add("scale-110", "ring-4", "ring-pink-400")
      if (truthBtn) truthBtn.classList.add("opacity-30", "scale-90")
    }
  }

  showCard(cardType, card, playerName) {
    if (!this.hasCardDisplayTarget) return

    const isMyCard = this.isMyTurnValue
    const isTruth = cardType === "truth"

    // Update card display
    if (this.hasCardTypeTarget) {
      this.cardTypeTarget.textContent = isTruth ? "VERDAD" : "RETO"
      this.cardTypeTarget.className = `text-2xl font-black uppercase tracking-wider mb-4 ${
        isTruth ? "text-cyan-400" : "text-pink-400"
      }`
    }

    if (this.hasCardContentTarget) {
      this.cardContentTarget.textContent = card.content
    }

    // Style the card
    this.cardDisplayTarget.className = `card-reveal p-6 rounded-2xl text-center transition-all duration-500 ${
      isTruth
        ? "bg-gradient-to-b from-cyan-500/20 to-cyan-500/5 border-2 border-cyan-500/50"
        : "bg-gradient-to-b from-pink-500/20 to-pink-500/5 border-2 border-pink-500/50"
    }`
    this.cardDisplayTarget.style.boxShadow = isTruth
      ? "0 0 40px rgba(6, 182, 212, 0.3)"
      : "0 0 40px rgba(236, 72, 153, 0.3)"

    // Show card with animation
    this.cardDisplayTarget.classList.remove("hidden")
    this.cardDisplayTarget.classList.add("animate-bounce-in")

    // Hide choice buttons, show response buttons if it's my turn
    if (this.hasActionButtonsTarget) {
      this.actionButtonsTarget.classList.add("hidden")
    }

    if (this.hasResponseButtonsTarget && isMyCard) {
      this.responseButtonsTarget.classList.remove("hidden")
    }
  }

  setButtonsLoading(loading) {
    if (this.hasTruthButtonTarget) {
      this.truthButtonTarget.disabled = loading
    }
    if (this.hasDareButtonTarget) {
      this.dareButtonTarget.disabled = loading
    }
  }

  updateLeaderboard(leaderboard) {
    // Update leaderboard display
  }

  showToast(message, type = "info") {
    const existing = document.getElementById("tod-toast")
    if (existing) existing.remove()

    const toast = document.createElement("div")
    toast.id = "tod-toast"

    const bgColor = {
      success: "bg-green-500",
      error: "bg-red-500",
      warning: "bg-yellow-500",
      info: "bg-purple-500"
    }[type] || "bg-purple-500"

    toast.className = `fixed bottom-20 left-1/2 transform -translate-x-1/2 px-6 py-3 rounded-lg shadow-lg z-50 text-white font-medium transition-all ${bgColor}`
    toast.textContent = message
    document.body.appendChild(toast)

    setTimeout(() => {
      toast.style.opacity = "0"
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }

  refreshPage() {
    window.location.reload()
  }
}
