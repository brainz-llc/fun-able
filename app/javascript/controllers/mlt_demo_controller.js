import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "phaseIndicator",
    "statementCard",
    "phoneScreen",
    "player1",
    "player2",
    "player3",
    "player4",
    "select1",
    "select2",
    "select3",
    "select4",
    "voteStatus",
    "waitingDots",
    "resultsArea",
    "result1",
    "result2",
    "result3",
    "bar1",
    "bar2",
    "bar3",
    "winnerBadge",
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
      'Aparece una pregunta...',
      'Todos ven las opciones',
      'Eliges a quien votar...',
      'Esperando a los demas...',
      'Se revelan los resultados!',
      'El mas votado bebe!'
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
    // Statement card - uses translate and scale
    if (this.hasStatementCardTarget) {
      this.statementCardTarget.classList.add('opacity-0', 'scale-90', '-translate-y-4')
    }

    // Phone screen / voting grid
    if (this.hasPhoneScreenTarget) {
      this.phoneScreenTarget.classList.add('opacity-0')
    }

    // Player selections
    const selects = [this.select1Target, this.select2Target, this.select3Target, this.select4Target].filter(Boolean)
    selects.forEach(s => s.classList.add('opacity-0'))

    // Vote status and waiting
    if (this.hasVoteStatusTarget) this.voteStatusTarget.classList.add('opacity-0')
    if (this.hasWaitingDotsTarget) this.waitingDotsTarget.classList.add('opacity-0')

    // Results area
    if (this.hasResultsAreaTarget) {
      this.resultsAreaTarget.classList.add('opacity-0', 'scale-95')
    }

    // Vote bars
    if (this.hasBar1Target) this.bar1Target.style.width = '0%'
    if (this.hasBar2Target) this.bar2Target.style.width = '0%'
    if (this.hasBar3Target) this.bar3Target.style.width = '0%'

    // Winner badge
    if (this.hasWinnerBadgeTarget) {
      this.winnerBadgeTarget.classList.add('scale-0', 'opacity-0')
    }
  }

  // Phase 0: Statement card appears with dramatic entrance
  runPhase0() {
    this.updatePhaseIndicator()
    this.setStep(0)

    this.timeout = setTimeout(() => {
      if (this.hasStatementCardTarget) {
        this.statementCardTarget.classList.remove('opacity-0', 'scale-90', '-translate-y-4')
      }

      this.timeout = setTimeout(() => {
        this.phaseValue = 1
        this.runPhase1()
      }, 1800)
    }, 300)
  }

  // Phase 1: Phone screen appears with voting options
  runPhase1() {
    this.updatePhaseIndicator()
    this.setStep(1)

    this.timeout = setTimeout(() => {
      if (this.hasPhoneScreenTarget) {
        this.phoneScreenTarget.classList.remove('opacity-0')
      }

      this.timeout = setTimeout(() => {
        this.phaseValue = 2
        this.runPhase2()
      }, 1500)
    }, 300)
  }

  // Phase 2: Selection animation - user picks Luis
  runPhase2() {
    this.updatePhaseIndicator()
    this.setStep(1)

    // Simulate hovering/selecting different players
    const selectSequence = [
      { target: 'select1', delay: 400 },
      { target: 'select1', delay: 700, hide: true },
      { target: 'select3', delay: 1000 },
      { target: 'select3', delay: 1300, hide: true },
      { target: 'select2', delay: 1600 } // Final selection - Luis
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
    }, 2200)
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

    // Hide phone screen, show results
    if (this.hasPhoneScreenTarget) {
      this.phoneScreenTarget.classList.add('opacity-0')
    }

    // Also hide the statement card to make room
    if (this.hasStatementCardTarget) {
      this.statementCardTarget.classList.add('opacity-0', 'scale-90')
    }

    this.timeout = setTimeout(() => {
      if (this.hasResultsAreaTarget) {
        this.resultsAreaTarget.classList.remove('opacity-0', 'scale-95')
      }

      // Animate vote bars with stagger
      this.timeout = setTimeout(() => {
        if (this.hasBar1Target) this.bar1Target.style.width = '75%' // Luis - 3 votes
        if (this.hasBar2Target) this.bar2Target.style.width = '25%' // Ana - 1 vote
        if (this.hasBar3Target) this.bar3Target.style.width = '0%'  // Sara - 0 votes

        this.timeout = setTimeout(() => {
          this.phaseValue = 5
          this.runPhase5()
        }, 1500)
      }, 500)
    }, 400)
  }

  // Phase 5: Winner celebration
  runPhase5() {
    this.updatePhaseIndicator()
    this.setStep(3)

    // Highlight winner bar
    if (this.hasBar1Target) {
      this.bar1Target.style.boxShadow = '0 0 20px rgba(168, 85, 247, 0.8)'
    }

    this.timeout = setTimeout(() => {
      // Show winner badge
      if (this.hasWinnerBadgeTarget) {
        this.winnerBadgeTarget.classList.remove('scale-0', 'opacity-0')
      }

      // Restart loop after celebration
      this.timeout = setTimeout(() => {
        this.startDemo()
      }, 3500)
    }, 600)
  }
}
