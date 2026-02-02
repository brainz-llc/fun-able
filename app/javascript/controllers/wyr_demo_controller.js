import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "phaseIndicator",
    "dilemmaCard",
    "choicesArea",
    "optionA",
    "optionB",
    "selectA",
    "selectB",
    "voteStatus",
    "waitingDots",
    "resultsArea",
    "resultA",
    "resultB",
    "barA",
    "barB",
    "countA",
    "countB",
    "voterAvatars",
    "drinkBadge",
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
      'Aparece el dilema...',
      'Ves las opciones',
      'Eliges tu respuesta...',
      'Esperando a los demas...',
      'Se revelan los resultados!',
      'La minoria bebe!'
    ]
    this.startDemo()
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  startDemo() {
    this.resetAll()
    this.phaseValue = 0
    this.timeout = setTimeout(() => this.runPhase0(), 500)
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
    // Dilemma card
    if (this.hasDilemmaCardTarget) {
      this.dilemmaCardTarget.classList.add('opacity-0', 'scale-90', '-translate-y-4')
    }

    // Choices area
    if (this.hasChoicesAreaTarget) {
      this.choicesAreaTarget.classList.add('opacity-0')
    }

    // Option selections
    if (this.hasSelectATarget) this.selectATarget.classList.add('opacity-0')
    if (this.hasSelectBTarget) this.selectBTarget.classList.add('opacity-0')

    // Vote status and waiting
    if (this.hasVoteStatusTarget) this.voteStatusTarget.classList.add('opacity-0')
    if (this.hasWaitingDotsTarget) this.waitingDotsTarget.classList.add('opacity-0')

    // Results area
    if (this.hasResultsAreaTarget) {
      this.resultsAreaTarget.classList.add('opacity-0', 'scale-95')
    }

    // Vote bars
    if (this.hasBarATarget) this.barATarget.style.width = '0%'
    if (this.hasBarBTarget) this.barBTarget.style.width = '0%'

    // Drink badge
    if (this.hasDrinkBadgeTarget) {
      this.drinkBadgeTarget.classList.add('scale-0', 'opacity-0')
    }
  }

  // Phase 0: Dilemma card appears with dramatic entrance
  runPhase0() {
    this.updatePhaseIndicator()
    this.setStep(0)

    this.timeout = setTimeout(() => {
      if (this.hasDilemmaCardTarget) {
        this.dilemmaCardTarget.classList.remove('opacity-0', 'scale-90', '-translate-y-4')
      }

      this.timeout = setTimeout(() => {
        this.phaseValue = 1
        this.runPhase1()
      }, 1800)
    }, 300)
  }

  // Phase 1: Choice buttons appear
  runPhase1() {
    this.updatePhaseIndicator()
    this.setStep(1)

    this.timeout = setTimeout(() => {
      if (this.hasChoicesAreaTarget) {
        this.choicesAreaTarget.classList.remove('opacity-0')
      }

      this.timeout = setTimeout(() => {
        this.phaseValue = 2
        this.runPhase2()
      }, 1500)
    }, 300)
  }

  // Phase 2: Selection animation - user picks Option B
  runPhase2() {
    this.updatePhaseIndicator()
    this.setStep(1)

    // Simulate hovering/selecting different options
    const selectSequence = [
      { target: 'selectA', delay: 400 },
      { target: 'selectA', delay: 800, hide: true },
      { target: 'selectB', delay: 1200 } // Final selection - Option B
    ]

    selectSequence.forEach(({ target, delay, hide }) => {
      this.timeout = setTimeout(() => {
        const el = this[`${target}Target`]
        if (el) {
          if (hide) {
            el.classList.add('opacity-0')
          } else {
            el.classList.remove('opacity-0')
          }
        }
      }, delay)
    })

    this.timeout = setTimeout(() => {
      this.phaseValue = 3
      this.runPhase3()
    }, 1800)
  }

  // Phase 3: Vote submitted, waiting for others
  runPhase3() {
    this.updatePhaseIndicator()
    this.setStep(2)

    // Show vote confirmation
    if (this.hasVoteStatusTarget) {
      this.voteStatusTarget.classList.remove('opacity-0')
    }

    this.timeout = setTimeout(() => {
      // Show waiting dots
      if (this.hasWaitingDotsTarget) {
        this.waitingDotsTarget.classList.remove('opacity-0')
      }

      this.timeout = setTimeout(() => {
        this.phaseValue = 4
        this.runPhase4()
      }, 2000)
    }, 500)
  }

  // Phase 4: Results reveal with animated bars
  runPhase4() {
    this.updatePhaseIndicator()
    this.setStep(2)

    // Hide choices area, show results
    if (this.hasChoicesAreaTarget) {
      this.choicesAreaTarget.classList.add('opacity-0')
    }

    // Also hide the dilemma card to make room
    if (this.hasDilemmaCardTarget) {
      this.dilemmaCardTarget.classList.add('opacity-0', 'scale-90')
    }

    this.timeout = setTimeout(() => {
      if (this.hasResultsAreaTarget) {
        this.resultsAreaTarget.classList.remove('opacity-0', 'scale-95')
      }

      // Animate vote bars with stagger
      this.timeout = setTimeout(() => {
        if (this.hasBarATarget) this.barATarget.style.width = '75%' // Option A - 3 votes (majority)
        if (this.hasBarBTarget) this.barBTarget.style.width = '25%' // Option B - 1 vote (minority)

        this.timeout = setTimeout(() => {
          this.phaseValue = 5
          this.runPhase5()
        }, 1500)
      }, 500)
    }, 400)
  }

  // Phase 5: Minority drinks celebration
  runPhase5() {
    this.updatePhaseIndicator()
    this.setStep(3)

    // Highlight minority bar
    if (this.hasBarBTarget) {
      this.barBTarget.style.boxShadow = '0 0 20px rgba(6, 182, 212, 0.8)'
    }

    this.timeout = setTimeout(() => {
      // Show drink badge
      if (this.hasDrinkBadgeTarget) {
        this.drinkBadgeTarget.classList.remove('scale-0', 'opacity-0')
        this.drinkBadgeTarget.classList.add('minority-glow')
      }

      // Restart loop after celebration
      this.timeout = setTimeout(() => {
        if (this.hasDrinkBadgeTarget) {
          this.drinkBadgeTarget.classList.remove('minority-glow')
        }
        this.startDemo()
      }, 3500)
    }, 600)
  }
}
