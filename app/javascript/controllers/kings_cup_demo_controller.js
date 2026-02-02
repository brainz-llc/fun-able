import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "phaseIndicator",
    "deck",
    "topCard",
    "drawnCard",
    "cardValue",
    "cardSuit",
    "cardRule",
    "ruleDisplay",
    "ruleName",
    "ruleDescription",
    "cup",
    "liquid",
    "kingCount",
    "nextPlayer",
    "step1",
    "step2",
    "step3",
    "step4"
  ]

  static values = {
    phase: { type: Number, default: 0 },
    kingsPoured: { type: Number, default: 0 }
  }

  connect() {
    this.phases = [
      'Roba una carta del mazo...',
      'La carta se voltea!',
      'Cumple la regla!',
      'Siguiente jugador...'
    ]

    // Card rules data
    this.cards = [
      { value: 'A', suit: '&#9824;', rule: 'Cascada', description: 'Todos beben en cascada empezando por ti', color: '#fbbf24' },
      { value: '2', suit: '&#9829;', rule: 'Tu', description: 'Elige a alguien para que beba', color: '#06b6d4' },
      { value: '3', suit: '&#9830;', rule: 'Yo', description: 'Tu bebes!', color: '#ec4899' },
      { value: '7', suit: '&#9827;', rule: 'Cielo', description: 'Ultimo en levantar la mano bebe', color: '#22c55e' },
      { value: 'Q', suit: '&#9829;', rule: 'Preguntas', description: 'Solo puedes hacer preguntas', color: '#ec4899' },
      { value: 'K', suit: '&#9824;', rule: 'Copa del Rey', description: 'Vierte tu bebida en la copa central', color: '#fbbf24', isKing: true },
      { value: 'J', suit: '&#9827;', rule: 'Nueva Regla', description: 'Inventa una regla que todos deben seguir', color: '#a855f7' },
      { value: '10', suit: '&#9830;', rule: 'Categorias', description: 'Di una categoria, todos nombran', color: '#06b6d4' },
    ]

    this.currentCardIndex = 0
    this.kingsPoured = 0
    this.startDemo()
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  startDemo() {
    this.resetAll()
    this.phaseValue = 0
    this.timeout = setTimeout(() => this.runPhase0(), 800)
  }

  setStep(step) {
    const steps = [this.step1Target, this.step2Target, this.step3Target, this.step4Target].filter(Boolean)
    steps.forEach((s, i) => {
      s.classList.toggle('active', i === step)
    })
  }

  updatePhaseIndicator() {
    if (this.hasPhaseIndicatorTarget) {
      this.phaseIndicatorTarget.textContent = this.phases[this.phaseValue]
      this.phaseIndicatorTarget.classList.add('animate-pulse')
      setTimeout(() => this.phaseIndicatorTarget.classList.remove('animate-pulse'), 500)
    }
  }

  resetAll() {
    // Reset deck visibility
    if (this.hasDeckTarget) {
      this.deckTarget.classList.remove('opacity-0', 'scale-90')
    }

    // Hide drawn card
    if (this.hasDrawnCardTarget) {
      this.drawnCardTarget.classList.add('opacity-0', 'scale-0')
      this.drawnCardTarget.classList.remove('card-flip')
    }

    // Hide rule display
    if (this.hasRuleDisplayTarget) {
      this.ruleDisplayTarget.classList.add('opacity-0', 'translate-y-4')
    }

    // Reset next player
    if (this.hasNextPlayerTarget) {
      this.nextPlayerTarget.classList.add('opacity-0')
    }
  }

  getNextCard() {
    const card = this.cards[this.currentCardIndex]
    this.currentCardIndex = (this.currentCardIndex + 1) % this.cards.length
    return card
  }

  // Phase 0: Show deck, ready to draw
  runPhase0() {
    this.updatePhaseIndicator()
    this.setStep(0)

    // Animate deck glow
    if (this.hasDeckTarget) {
      this.deckTarget.classList.add('deck-pulse')
    }

    this.timeout = setTimeout(() => {
      if (this.hasDeckTarget) {
        this.deckTarget.classList.remove('deck-pulse')
      }
      this.phaseValue = 1
      this.runPhase1()
    }, 1500)
  }

  // Phase 1: Draw card animation
  runPhase1() {
    this.updatePhaseIndicator()
    this.setStep(1)

    const card = this.getNextCard()

    // Update card content
    if (this.hasCardValueTarget) this.cardValueTarget.innerHTML = card.value
    if (this.hasCardSuitTarget) this.cardSuitTarget.innerHTML = card.suit
    if (this.hasCardRuleTarget) this.cardRuleTarget.textContent = card.rule

    // Update colors
    if (this.hasCardValueTarget) this.cardValueTarget.style.color = card.color
    if (this.hasCardRuleTarget) this.cardRuleTarget.style.color = card.color

    // Update rule display
    if (this.hasRuleNameTarget) this.ruleNameTarget.textContent = card.rule
    if (this.hasRuleDescriptionTarget) this.ruleDescriptionTarget.textContent = card.description

    // Fade out deck slightly
    if (this.hasDeckTarget) {
      this.deckTarget.classList.add('opacity-60', 'scale-95')
    }

    // Show drawn card with flip animation
    this.timeout = setTimeout(() => {
      if (this.hasDrawnCardTarget) {
        this.drawnCardTarget.classList.remove('opacity-0', 'scale-0')
        this.drawnCardTarget.classList.add('card-flip')

        // Set the border color to match the card
        this.drawnCardTarget.querySelector('.card-inner').style.borderColor = `${card.color}80`
        this.drawnCardTarget.querySelector('.card-inner').style.boxShadow = `0 0 40px ${card.color}50`
      }

      this.timeout = setTimeout(() => {
        this.phaseValue = 2
        this.currentCard = card
        this.runPhase2()
      }, 1200)
    }, 400)
  }

  // Phase 2: Show rule
  runPhase2() {
    this.updatePhaseIndicator()
    this.setStep(2)

    // Show rule display
    if (this.hasRuleDisplayTarget) {
      this.ruleDisplayTarget.classList.remove('opacity-0', 'translate-y-4')
    }

    // If it's a King, animate the cup
    if (this.currentCard && this.currentCard.isKing) {
      this.animateKingPour()
    }

    this.timeout = setTimeout(() => {
      this.phaseValue = 3
      this.runPhase3()
    }, 2500)
  }

  animateKingPour() {
    this.kingsPoured = Math.min(this.kingsPoured + 1, 4)

    // Animate liquid level
    if (this.hasLiquidTarget) {
      const fillPercent = (this.kingsPoured / 4) * 100
      const translateY = 70 - (fillPercent * 0.7)
      this.liquidTarget.style.transform = `translateY(${translateY}px)`
    }

    // Light up king indicator
    if (this.hasKingCountTarget) {
      const dots = this.kingCountTarget.querySelectorAll('[data-king]')
      dots.forEach((dot, i) => {
        if (i < this.kingsPoured) {
          dot.classList.add('king-filled')
          dot.style.backgroundColor = '#fbbf24'
          dot.style.borderColor = '#fbbf24'
          dot.style.boxShadow = '0 0 10px rgba(251, 191, 36, 0.6)'
        }
      })
    }
  }

  // Phase 3: Next player
  runPhase3() {
    this.updatePhaseIndicator()
    this.setStep(3)

    // Show next player indicator
    if (this.hasNextPlayerTarget) {
      this.nextPlayerTarget.classList.remove('opacity-0')
    }

    // Hide card and rule after a moment
    this.timeout = setTimeout(() => {
      if (this.hasDrawnCardTarget) {
        this.drawnCardTarget.classList.add('opacity-0', 'scale-0')
        this.drawnCardTarget.classList.remove('card-flip')
      }
      if (this.hasRuleDisplayTarget) {
        this.ruleDisplayTarget.classList.add('opacity-0', 'translate-y-4')
      }
      if (this.hasDeckTarget) {
        this.deckTarget.classList.remove('opacity-60', 'scale-95')
      }
      if (this.hasNextPlayerTarget) {
        this.nextPlayerTarget.classList.add('opacity-0')
      }

      // Loop back
      this.timeout = setTimeout(() => {
        this.startDemo()
      }, 800)
    }, 2000)
  }
}
