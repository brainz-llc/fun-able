import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = [
    "deck", "drawnCard", "cardFront", "cardBack", "cup", "cupFill",
    "currentPlayer", "cardsRemaining", "kingsCount", "rulesList",
    "playersList", "drawnCardRule", "drawnCardValue", "drawnCardSuit",
    "mobileOverlay", "mobilePanel", "mobileBackdrop", "ruleInput",
    "mateModal", "matePlayersList", "recentCards", "gameStatus"
  ]

  static values = {
    gameId: Number,
    playerId: Number,
    isHost: Boolean
  }

  connect() {
    this.isFlipping = false
    this.reconnectAttempts = 0
    this.maxReconnectAttempts = 10
    this.subscribeToChannel()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create(
      { channel: "KingsCupChannel", game_id: this.gameIdValue },
      {
        connected: () => this.handleConnected(),
        disconnected: () => this.handleDisconnected(),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleConnected() {
    console.log("Connected to KingsCupChannel")
    this.reconnectAttempts = 0
    this.subscription.perform("request_state")
  }

  handleDisconnected() {
    console.log("Disconnected from KingsCupChannel")
    this.attemptReconnect()
  }

  attemptReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      this.showToast("Conexion perdida. Recarga la pagina.", "error")
      return
    }

    this.reconnectAttempts++
    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts - 1), 30000)

    setTimeout(() => {
      if (consumer.connection.isOpen()) {
        this.subscription.perform("request_state")
      }
    }, delay)
  }

  handleReceived(data) {
    console.log("Kings Cup received:", data.type, data)

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
      case "card_drawn":
        this.handleCardDrawn(data)
        break
      case "rule_added":
        this.handleRuleAdded(data)
        break
      case "mate_set":
        this.handleMateSet(data)
        break
      case "game_ended":
        this.handleGameEnded(data)
        break
      case "player_kicked":
        if (data.player_id === this.playerIdValue) {
          window.location.href = "/kings-cup"
        }
        break
    }
  }

  updateGameState(data) {
    if (data.game) {
      this.updateCardsRemaining(data.game.cards_remaining)
      this.updateKingsCount(data.game.kings_drawn)
      this.updateCupFill(data.game.cup_fill_percentage)
      this.updateCurrentPlayer(data.game.current_player_id)
    }
  }

  updatePlayers(data) {
    // Refresh players list via Turbo or update inline
    if (this.hasPlayersListTarget) {
      window.Turbo.visit(window.location.href, { action: "replace" })
    }
  }

  handleGameStarted(data) {
    this.showToast("La partida ha comenzado!", "success")
    setTimeout(() => {
      window.Turbo.visit(window.location.href, { action: "replace" })
    }, 500)
  }

  handleCardDrawn(data) {
    const { card, drawn_by, game } = data

    // Show the card with flip animation
    this.showDrawnCard(card, drawn_by)

    // Update game state
    this.updateCardsRemaining(game.cards_remaining)
    this.updateKingsCount(game.kings_drawn)
    this.updateCupFill(game.cup_fill_percentage)
    this.updateCurrentPlayer(game.current_player_id)

    // Add to recent cards
    this.addToRecentCards(card, drawn_by)

    // Handle special cards
    if (card.value === 'K') {
      this.animateCupFill(game.kings_drawn)
      if (game.finished) {
        setTimeout(() => this.handleGameEnded({ kings_drawn: game.kings_drawn }), 3000)
      }
    }

    if (card.value === 'J') {
      // Show rule input modal for the player who drew
      if (drawn_by.id === this.playerIdValue) {
        setTimeout(() => this.showRuleModal(), 2000)
      }
    }

    if (card.value === '8') {
      // Show mate selection for the player who drew
      if (drawn_by.id === this.playerIdValue) {
        setTimeout(() => this.showMateModal(), 2000)
      }
    }
  }

  showDrawnCard(card, drawnBy) {
    if (!this.hasDrawnCardTarget) return

    this.isFlipping = true

    // Set card content
    if (this.hasCardFrontTarget) {
      const colorClass = card.suit_color === 'red' ? 'text-red-500' : 'text-white'
      this.cardFrontTarget.innerHTML = `
        <div class="absolute top-2 left-3 ${colorClass} text-xl font-bold">${card.value}</div>
        <div class="absolute top-8 left-3 text-2xl">${card.suit_symbol}</div>
        <div class="absolute bottom-2 right-3 ${colorClass} text-xl font-bold rotate-180">${card.value}</div>
        <div class="absolute bottom-8 right-3 text-2xl rotate-180">${card.suit_symbol}</div>
        <div class="absolute inset-0 flex flex-col items-center justify-center p-4">
          <span class="text-4xl mb-2">${card.rule_icon}</span>
          <span class="text-lg font-bold text-white text-center">${card.rule_name}</span>
        </div>
      `
    }

    // Update rule display
    if (this.hasDrawnCardRuleTarget) {
      this.drawnCardRuleTarget.innerHTML = `
        <div class="text-center">
          <span class="text-2xl">${card.rule_icon}</span>
          <h3 class="text-xl font-bold text-pink-400 mt-2">${card.rule_name}</h3>
          <p class="text-white/80 mt-2">${card.rule_description}</p>
          <p class="text-cyan-400 text-sm mt-3">Sacada por: ${drawnBy.name}</p>
        </div>
      `
    }

    // Show the card container and trigger flip
    this.drawnCardTarget.classList.remove("hidden")
    this.drawnCardTarget.classList.add("flex")

    // Trigger flip animation
    setTimeout(() => {
      this.drawnCardTarget.querySelector('[data-flip-container]')?.classList.add("flipped")
    }, 100)

    // Reset after animation
    setTimeout(() => {
      this.isFlipping = false
    }, 1000)
  }

  hideDrawnCard() {
    if (!this.hasDrawnCardTarget) return

    this.drawnCardTarget.classList.add("hidden")
    this.drawnCardTarget.classList.remove("flex")
    this.drawnCardTarget.querySelector('[data-flip-container]')?.classList.remove("flipped")
  }

  dismissCard() {
    this.hideDrawnCard()
  }

  updateCardsRemaining(count) {
    if (this.hasCardsRemainingTarget) {
      this.cardsRemainingTarget.textContent = count
    }
  }

  updateKingsCount(count) {
    if (this.hasKingsCountTarget) {
      this.kingsCountTarget.textContent = `${count}/4`
    }
  }

  updateCupFill(percentage) {
    if (this.hasCupFillTarget) {
      this.cupFillTarget.style.height = `${percentage}%`

      // Change color based on fill level
      if (percentage >= 75) {
        this.cupFillTarget.classList.remove("from-amber-600", "to-amber-500", "from-amber-700", "to-amber-600")
        this.cupFillTarget.classList.add("from-red-600", "to-red-500")
      } else if (percentage >= 50) {
        this.cupFillTarget.classList.remove("from-amber-600", "to-amber-500", "from-red-600", "to-red-500")
        this.cupFillTarget.classList.add("from-amber-700", "to-amber-600")
      }
    }
  }

  updateCurrentPlayer(playerId) {
    if (this.hasCurrentPlayerTarget) {
      const playerElements = document.querySelectorAll('[data-player-id]')
      playerElements.forEach(el => {
        if (parseInt(el.dataset.playerId) === playerId) {
          el.classList.add("ring-2", "ring-cyan-400", "animate-pulse")
          this.currentPlayerTarget.textContent = el.dataset.playerName || "Turno actual"
        } else {
          el.classList.remove("ring-2", "ring-cyan-400", "animate-pulse")
        }
      })
    }

    // Enable/disable draw button
    const drawButton = document.querySelector('[data-action*="drawCard"]')
    if (drawButton) {
      if (playerId === this.playerIdValue) {
        drawButton.disabled = false
        drawButton.classList.remove("opacity-50", "cursor-not-allowed")
      } else {
        drawButton.disabled = true
        drawButton.classList.add("opacity-50", "cursor-not-allowed")
      }
    }
  }

  addToRecentCards(card, drawnBy) {
    if (!this.hasRecentCardsTarget) return

    const cardEl = document.createElement('div')
    cardEl.className = 'flex items-center gap-2 px-3 py-2 rounded-lg bg-white/5 text-sm animate-slide-in'
    cardEl.innerHTML = `
      <span class="${card.suit_color === 'red' ? 'text-red-500' : 'text-white'} font-bold">${card.value}${card.suit_symbol}</span>
      <span class="text-white/60">-</span>
      <span class="text-white/80">${drawnBy.name}</span>
    `

    this.recentCardsTarget.prepend(cardEl)

    // Keep only last 5
    while (this.recentCardsTarget.children.length > 5) {
      this.recentCardsTarget.lastElementChild.remove()
    }
  }

  animateCupFill(kingsCount) {
    if (!this.hasCupTarget) return

    // Add glow animation
    this.cupTarget.classList.add("animate-pulse")
    setTimeout(() => {
      this.cupTarget.classList.remove("animate-pulse")
    }, 2000)

    // Trigger confetti for each king
    if (typeof window.confetti === "function") {
      window.confetti({
        particleCount: 50 * kingsCount,
        spread: 70,
        origin: { y: 0.6 },
        colors: ['#fbbf24', '#f59e0b', '#d97706']
      })
    }
  }

  handleRuleAdded(data) {
    if (this.hasRulesListTarget) {
      const ruleEl = document.createElement('div')
      ruleEl.className = 'flex items-start gap-2 px-3 py-2 rounded-lg bg-purple-500/10 border border-purple-500/30 animate-slide-in'
      ruleEl.innerHTML = `
        <span class="text-purple-400">📜</span>
        <div>
          <p class="text-white text-sm">${data.rule.rule_text}</p>
          <p class="text-white/50 text-xs mt-1">Por: ${data.rule.creator_name}</p>
        </div>
      `
      this.rulesListTarget.prepend(ruleEl)
    }

    this.showToast("Nueva regla agregada!", "info")
  }

  handleMateSet(data) {
    this.showToast(`${data.player_name} eligio a ${data.mate_name} como compinche!`, "info")

    // Update player cards to show mate relationship
    if (this.hasPlayersListTarget) {
      window.Turbo.visit(window.location.href, { action: "replace" })
    }
  }

  handleGameEnded(data) {
    if (this.hasGameStatusTarget) {
      this.gameStatusTarget.innerHTML = `
        <div class="text-center p-6 rounded-2xl bg-gradient-to-b from-amber-500/20 to-amber-500/5 border border-amber-500/40">
          <span class="text-6xl mb-4 block">👑</span>
          <h2 class="text-2xl font-bold text-amber-400 mb-2">Partida Terminada!</h2>
          <p class="text-white/80">El 4to Rey ha sido sacado.</p>
          <p class="text-amber-300 mt-2">Alguien debe beber la Copa del Rey!</p>
        </div>
      `
    }

    // Big confetti
    if (typeof window.confetti === "function") {
      window.confetti({
        particleCount: 200,
        spread: 100,
        origin: { y: 0.5 }
      })
    }

    // Redirect after celebration
    setTimeout(() => {
      window.Turbo.visit(window.location.href, { action: "replace" })
    }, 5000)
  }

  // Draw card action
  async drawCard() {
    if (this.isFlipping) return

    const response = await fetch(`/kings-cup/${this.gameIdValue}/draw`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    })

    const data = await response.json()

    if (!response.ok) {
      this.showToast(data.error || "No se pudo sacar carta", "error")
    }
    // Card will be shown via WebSocket broadcast
  }

  // Rule modal
  showRuleModal() {
    const modal = document.getElementById('rule-modal')
    if (modal) {
      modal.classList.remove('hidden')
      modal.classList.add('flex')
      if (this.hasRuleInputTarget) {
        this.ruleInputTarget.focus()
      }
    }
  }

  hideRuleModal() {
    const modal = document.getElementById('rule-modal')
    if (modal) {
      modal.classList.add('hidden')
      modal.classList.remove('flex')
    }
  }

  async submitRule() {
    if (!this.hasRuleInputTarget) return

    const ruleText = this.ruleInputTarget.value.trim()
    if (!ruleText) return

    const response = await fetch(`/kings-cup/${this.gameIdValue}/add_rule`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ rule_text: ruleText })
    })

    if (response.ok) {
      this.ruleInputTarget.value = ''
      this.hideRuleModal()
    } else {
      const data = await response.json()
      this.showToast(data.error || "No se pudo agregar la regla", "error")
    }
  }

  // Mate modal
  showMateModal() {
    if (this.hasMateModalTarget) {
      this.mateModalTarget.classList.remove('hidden')
      this.mateModalTarget.classList.add('flex')
    }
  }

  hideMateModal() {
    if (this.hasMateModalTarget) {
      this.mateModalTarget.classList.add('hidden')
      this.mateModalTarget.classList.remove('flex')
    }
  }

  async selectMate(event) {
    const playerId = event.currentTarget.dataset.playerId

    const response = await fetch(`/kings-cup/${this.gameIdValue}/set_mate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ player_id: playerId })
    })

    if (response.ok) {
      this.hideMateModal()
    } else {
      const data = await response.json()
      this.showToast(data.error || "No se pudo elegir compinche", "error")
    }
  }

  // Mobile menu
  toggleMobileMenu() {
    if (!this.hasMobileOverlayTarget) return

    const isOpen = !this.mobilePanelTarget.classList.contains("translate-x-full")

    if (isOpen) {
      this.mobilePanelTarget.classList.add("translate-x-full")
      this.mobileBackdropTarget.classList.add("opacity-0", "pointer-events-none")
      this.mobileOverlayTarget.classList.add("pointer-events-none")
      document.body.style.overflow = ""
    } else {
      this.mobileOverlayTarget.classList.remove("pointer-events-none")
      this.mobileBackdropTarget.classList.remove("opacity-0", "pointer-events-none")
      this.mobilePanelTarget.classList.remove("translate-x-full")
      document.body.style.overflow = "hidden"
    }
  }

  showToast(message, type = "info") {
    const existing = document.getElementById("kings-cup-toast")
    if (existing) existing.remove()

    const toast = document.createElement("div")
    toast.id = "kings-cup-toast"
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
}
