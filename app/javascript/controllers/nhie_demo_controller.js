import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "phaseIndicator",
    "statementCard",
    "playersArea",
    "player1",
    "player2",
    "player3",
    "player1Status",
    "player2Status",
    "player3Status",
    "player1Icon",
    "player2Icon",
    "player3Icon",
    "drinkCounter",
    "actionButtons",
    "drinkBtn",
    "safeBtn",
    "nextCard"
  ]

  static values = {
    phase: { type: Number, default: 0 }
  }

  connect() {
    this.phases = [
      'Aparece una carta con una afirmacion',
      'Los jugadores deciden si lo han hecho',
      'Quienes lo hicieron, beben!',
      'Siguiente carta...'
    ]
    this.startDemo()
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.interval) clearInterval(this.interval)
  }

  startDemo() {
    this.resetDemo()
    this.phaseValue = 0
    this.timeout = setTimeout(() => this.runPhase(0), 1000)
    this.interval = setInterval(() => this.nextPhase(), 3500)
  }

  resetDemo() {
    // Hide everything
    if (this.hasStatementCardTarget) {
      this.statementCardTarget.classList.add('opacity-0', 'scale-75')
    }
    if (this.hasPlayersAreaTarget) {
      this.playersAreaTarget.classList.add('opacity-0')
    }
    if (this.hasPlayer1Target) {
      this.player1Target.classList.add('opacity-0', '-translate-x-8')
    }
    if (this.hasPlayer2Target) {
      this.player2Target.classList.add('opacity-0', 'translate-y-8')
    }
    if (this.hasPlayer3Target) {
      this.player3Target.classList.add('opacity-0', 'translate-x-8')
    }
    if (this.hasPlayer1StatusTarget) {
      this.player1StatusTarget.classList.add('opacity-0')
    }
    if (this.hasPlayer2StatusTarget) {
      this.player2StatusTarget.classList.add('opacity-0')
    }
    if (this.hasPlayer3StatusTarget) {
      this.player3StatusTarget.classList.add('opacity-0')
    }
    if (this.hasDrinkCounterTarget) {
      this.drinkCounterTarget.classList.add('opacity-0')
    }
    if (this.hasActionButtonsTarget) {
      this.actionButtonsTarget.classList.add('translate-y-full', 'opacity-0')
    }
    if (this.hasNextCardTarget) {
      this.nextCardTarget.classList.add('opacity-0', 'scale-50', 'translate-y-20')
    }

    // Reset icons
    if (this.hasPlayer1IconTarget) this.player1IconTarget.innerHTML = '👤'
    if (this.hasPlayer2IconTarget) this.player2IconTarget.innerHTML = '👤'
    if (this.hasPlayer3IconTarget) this.player3IconTarget.innerHTML = '👤'
  }

  runPhase(phase) {
    if (this.hasPhaseIndicatorTarget) {
      this.phaseIndicatorTarget.textContent = this.phases[phase]
    }

    switch(phase) {
      case 0:
        // Show statement card
        this.timeout = setTimeout(() => {
          if (this.hasStatementCardTarget) {
            this.statementCardTarget.classList.remove('opacity-0', 'scale-75')
          }
        }, 300)
        break

      case 1:
        // Show players and action buttons
        if (this.hasPlayersAreaTarget) {
          this.playersAreaTarget.classList.remove('opacity-0')
        }
        this.timeout = setTimeout(() => {
          if (this.hasPlayer1Target) this.player1Target.classList.remove('opacity-0', '-translate-x-8')
        }, 200)
        this.timeout = setTimeout(() => {
          if (this.hasPlayer2Target) this.player2Target.classList.remove('opacity-0', 'translate-y-8')
        }, 400)
        this.timeout = setTimeout(() => {
          if (this.hasPlayer3Target) this.player3Target.classList.remove('opacity-0', 'translate-x-8')
        }, 600)
        this.timeout = setTimeout(() => {
          if (this.hasActionButtonsTarget) this.actionButtonsTarget.classList.remove('translate-y-full', 'opacity-0')
        }, 800)
        break

      case 2:
        // Show who drinks
        // Player 1 drinks
        if (this.hasPlayer1IconTarget) this.player1IconTarget.innerHTML = '🍺'
        if (this.hasPlayer1StatusTarget) this.player1StatusTarget.classList.remove('opacity-0')

        // Player 2 is safe
        this.timeout = setTimeout(() => {
          if (this.hasPlayer2IconTarget) this.player2IconTarget.innerHTML = '😇'
          if (this.hasPlayer2StatusTarget) this.player2StatusTarget.classList.remove('opacity-0')
        }, 400)

        // Player 3 drinks
        this.timeout = setTimeout(() => {
          if (this.hasPlayer3IconTarget) this.player3IconTarget.innerHTML = '🍺'
          if (this.hasPlayer3StatusTarget) this.player3StatusTarget.classList.remove('opacity-0')
        }, 800)

        // Show drink counter
        this.timeout = setTimeout(() => {
          if (this.hasDrinkCounterTarget) this.drinkCounterTarget.classList.remove('opacity-0')
        }, 1200)
        break

      case 3:
        // Transition to next card
        if (this.hasStatementCardTarget) this.statementCardTarget.classList.add('opacity-0', 'scale-75')
        if (this.hasActionButtonsTarget) this.actionButtonsTarget.classList.add('translate-y-full', 'opacity-0')

        this.timeout = setTimeout(() => {
          if (this.hasNextCardTarget) this.nextCardTarget.classList.remove('opacity-0', 'scale-50', 'translate-y-20')
        }, 500)
        break
    }
  }

  nextPhase() {
    this.phaseValue++
    if (this.phaseValue >= this.phases.length) {
      this.phaseValue = 0
      this.resetDemo()
      this.timeout = setTimeout(() => this.runPhase(this.phaseValue), 500)
    } else {
      this.runPhase(this.phaseValue)
    }
  }
}
