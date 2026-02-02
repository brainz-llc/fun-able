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
    "player1Avatar",
    "player2Avatar",
    "player3Avatar",
    "drinkCounter",
    "actionButtons",
    "drinkBtn",
    "safeBtn",
    "nextCard",
    "waitingDots",
    "step1",
    "step2",
    "step3",
    "step4"
  ]

  static values = {
    phase: { type: Number, default: 0 }
  }

  connect() {
    this.phases = [
      'Aparece una carta con una afirmacion',
      'Los jugadores eligen su respuesta',
      'Se revelan las respuestas!',
      'Siguiente carta...'
    ]
    this.startDemo()
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.interval) clearInterval(this.interval)
    this.clearAllTimeouts()
  }

  clearAllTimeouts() {
    if (this.timeouts) {
      this.timeouts.forEach(t => clearTimeout(t))
    }
    this.timeouts = []
  }

  addTimeout(callback, delay) {
    const t = setTimeout(callback, delay)
    if (!this.timeouts) this.timeouts = []
    this.timeouts.push(t)
    return t
  }

  startDemo() {
    this.resetDemo()
    this.phaseValue = 0
    this.updateStepIndicators(0)
    this.timeout = setTimeout(() => this.runPhase(0), 800)
    this.interval = setInterval(() => this.nextPhase(), 4000)
  }

  resetDemo() {
    this.clearAllTimeouts()

    // Reset statement card
    if (this.hasStatementCardTarget) {
      this.statementCardTarget.classList.add('opacity-0', 'scale-90', '-translate-y-4')
    }

    // Reset action buttons
    if (this.hasActionButtonsTarget) {
      this.actionButtonsTarget.classList.add('opacity-0', 'translate-y-4')
    }

    // Reset players area
    if (this.hasPlayersAreaTarget) {
      this.playersAreaTarget.classList.add('opacity-0')
    }

    // Reset individual players
    if (this.hasPlayer1Target) {
      this.player1Target.classList.add('opacity-0', '-translate-x-4')
      this.player1Target.classList.remove('translate-x-0')
    }
    if (this.hasPlayer2Target) {
      this.player2Target.classList.add('opacity-0', 'translate-y-4')
      this.player2Target.classList.remove('translate-y-0')
    }
    if (this.hasPlayer3Target) {
      this.player3Target.classList.add('opacity-0', 'translate-x-4')
      this.player3Target.classList.remove('-translate-x-0')
    }

    // Reset status badges
    if (this.hasPlayer1StatusTarget) {
      this.player1StatusTarget.classList.add('opacity-0', 'scale-75')
      this.player1StatusTarget.classList.remove('badge-pop')
    }
    if (this.hasPlayer2StatusTarget) {
      this.player2StatusTarget.classList.add('opacity-0', 'scale-75')
      this.player2StatusTarget.classList.remove('badge-pop')
    }
    if (this.hasPlayer3StatusTarget) {
      this.player3StatusTarget.classList.add('opacity-0', 'scale-75')
      this.player3StatusTarget.classList.remove('badge-pop')
    }

    // Reset drink counter
    if (this.hasDrinkCounterTarget) {
      this.drinkCounterTarget.classList.add('opacity-0', 'scale-95')
      this.drinkCounterTarget.classList.remove('counter-pulse')
    }

    // Reset waiting dots
    if (this.hasWaitingDotsTarget) {
      this.waitingDotsTarget.classList.add('opacity-0')
    }

    // Reset next card
    if (this.hasNextCardTarget) {
      this.nextCardTarget.classList.add('opacity-0', 'scale-90', 'translate-y-8')
    }

    // Reset icons
    if (this.hasPlayer1IconTarget) this.player1IconTarget.textContent = '😊'
    if (this.hasPlayer2IconTarget) this.player2IconTarget.textContent = '🤗'
    if (this.hasPlayer3IconTarget) this.player3IconTarget.textContent = '😎'

    // Reset avatar glows
    if (this.hasPlayer1AvatarTarget) this.player1AvatarTarget.classList.remove('reveal-glow')
    if (this.hasPlayer2AvatarTarget) this.player2AvatarTarget.classList.remove('reveal-glow')
    if (this.hasPlayer3AvatarTarget) this.player3AvatarTarget.classList.remove('reveal-glow')

    // Reset button styles
    if (this.hasDrinkBtnTarget) this.drinkBtnTarget.classList.remove('button-pressed')
    if (this.hasSafeBtnTarget) this.safeBtnTarget.classList.remove('button-pressed')
  }

  updateStepIndicators(phase) {
    const steps = [this.step1Target, this.step2Target, this.step3Target, this.step4Target]
    steps.forEach((step, index) => {
      if (step) {
        if (index === phase) {
          step.classList.add('active')
        } else {
          step.classList.remove('active')
        }
      }
    })
  }

  runPhase(phase) {
    if (this.hasPhaseIndicatorTarget) {
      this.phaseIndicatorTarget.textContent = this.phases[phase]
    }

    this.updateStepIndicators(phase)

    switch(phase) {
      case 0:
        // Phase 0: Show statement card
        this.addTimeout(() => {
          if (this.hasStatementCardTarget) {
            this.statementCardTarget.classList.remove('opacity-0', 'scale-90', '-translate-y-4')
          }
        }, 200)
        break

      case 1:
        // Phase 1: Show action buttons and players
        this.addTimeout(() => {
          if (this.hasActionButtonsTarget) {
            this.actionButtonsTarget.classList.remove('opacity-0', 'translate-y-4')
          }
        }, 200)

        this.addTimeout(() => {
          if (this.hasPlayersAreaTarget) {
            this.playersAreaTarget.classList.remove('opacity-0')
          }
        }, 400)

        // Animate players appearing
        this.addTimeout(() => {
          if (this.hasPlayer1Target) {
            this.player1Target.classList.remove('opacity-0', '-translate-x-4')
            this.player1Target.classList.add('translate-x-0')
          }
        }, 500)

        this.addTimeout(() => {
          if (this.hasPlayer2Target) {
            this.player2Target.classList.remove('opacity-0', 'translate-y-4')
            this.player2Target.classList.add('translate-y-0')
          }
        }, 650)

        this.addTimeout(() => {
          if (this.hasPlayer3Target) {
            this.player3Target.classList.remove('opacity-0', 'translate-x-4')
            this.player3Target.classList.add('-translate-x-0')
          }
        }, 800)

        // Show waiting dots
        this.addTimeout(() => {
          if (this.hasWaitingDotsTarget) {
            this.waitingDotsTarget.classList.remove('opacity-0')
          }
        }, 1000)

        // Simulate user clicking "Nunca" button
        this.addTimeout(() => {
          if (this.hasSafeBtnTarget) {
            this.safeBtnTarget.classList.add('button-pressed')
          }
        }, 1800)
        break

      case 2:
        // Phase 2: Reveal responses
        // Hide waiting dots
        if (this.hasWaitingDotsTarget) {
          this.waitingDotsTarget.classList.add('opacity-0')
        }

        // Player 1 (Ana) - drinks
        this.addTimeout(() => {
          if (this.hasPlayer1IconTarget) this.player1IconTarget.textContent = '🍷'
          if (this.hasPlayer1AvatarTarget) this.player1AvatarTarget.classList.add('reveal-glow')
          if (this.hasPlayer1StatusTarget) {
            this.player1StatusTarget.classList.remove('opacity-0', 'scale-75')
            this.player1StatusTarget.classList.add('badge-pop')
          }
        }, 300)

        // Player 2 (You) - safe
        this.addTimeout(() => {
          if (this.hasPlayer2IconTarget) this.player2IconTarget.textContent = '😇'
          if (this.hasPlayer2StatusTarget) {
            this.player2StatusTarget.classList.remove('opacity-0', 'scale-75')
            this.player2StatusTarget.classList.add('badge-pop')
          }
        }, 600)

        // Player 3 (Carlos) - drinks
        this.addTimeout(() => {
          if (this.hasPlayer3IconTarget) this.player3IconTarget.textContent = '🍺'
          if (this.hasPlayer3AvatarTarget) this.player3AvatarTarget.classList.add('reveal-glow')
          if (this.hasPlayer3StatusTarget) {
            this.player3StatusTarget.classList.remove('opacity-0', 'scale-75')
            this.player3StatusTarget.classList.add('badge-pop')
          }
        }, 900)

        // Show drink counter
        this.addTimeout(() => {
          if (this.hasDrinkCounterTarget) {
            this.drinkCounterTarget.classList.remove('opacity-0', 'scale-95')
            this.drinkCounterTarget.classList.add('counter-pulse')
          }
        }, 1300)
        break

      case 3:
        // Phase 3: Transition to next card
        // Fade out current card and content
        if (this.hasStatementCardTarget) {
          this.statementCardTarget.classList.add('opacity-0', 'scale-90')
        }
        if (this.hasActionButtonsTarget) {
          this.actionButtonsTarget.classList.add('opacity-0', 'translate-y-4')
        }
        if (this.hasPlayersAreaTarget) {
          this.playersAreaTarget.classList.add('opacity-0')
        }
        if (this.hasDrinkCounterTarget) {
          this.drinkCounterTarget.classList.add('opacity-0', 'scale-95')
        }

        // Show next card
        this.addTimeout(() => {
          if (this.hasNextCardTarget) {
            this.nextCardTarget.classList.remove('opacity-0', 'scale-90', 'translate-y-8')
          }
        }, 400)
        break
    }
  }

  nextPhase() {
    this.phaseValue++
    if (this.phaseValue >= this.phases.length) {
      this.phaseValue = 0
      this.resetDemo()
      this.timeout = setTimeout(() => this.runPhase(this.phaseValue), 600)
    } else {
      this.runPhase(this.phaseValue)
    }
  }
}
