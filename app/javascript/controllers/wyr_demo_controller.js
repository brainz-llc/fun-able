import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "phaseIndicator",
    "step1",
    "optionA",
    "optionB",
    "vsBadge",
    "step2",
    "voter1",
    "voter2",
    "voter3",
    "voter4",
    "voteLabel",
    "step3",
    "resultBarA",
    "resultBarB",
    "percentA",
    "percentB",
    "drinkBadge",
    "streakCounter"
  ]

  static values = {
    phase: { type: Number, default: 0 }
  }

  connect() {
    this.phases = [
      'Aparece el dilema',
      'Todos votan en secreto',
      'Se revelan los resultados',
      'La minoria bebe!'
    ]
    this.startDemo()
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.interval) clearInterval(this.interval)
  }

  startDemo() {
    this.resetAll()
    this.phaseValue = 0
    this.timeout = setTimeout(() => this.nextPhase(), 1000)
  }

  resetAll() {
    if (this.hasStep1Target) this.step1Target.classList.add('opacity-0')
    if (this.hasOptionATarget) this.optionATarget.classList.add('-translate-x-full', 'opacity-0')
    if (this.hasOptionBTarget) this.optionBTarget.classList.add('translate-x-full', 'opacity-0')
    if (this.hasVsBadgeTarget) this.vsBadgeTarget.classList.add('scale-0', 'opacity-0')
    if (this.hasStep2Target) this.step2Target.classList.add('opacity-0')

    const voters = [this.voter1Target, this.voter2Target, this.voter3Target, this.voter4Target].filter(Boolean)
    voters.forEach(v => v.classList.add('opacity-0', '-translate-y-4'))

    if (this.hasVoteLabelTarget) this.voteLabelTarget.classList.add('opacity-0')
    if (this.hasStep3Target) this.step3Target.classList.add('opacity-0', 'scale-95')
    if (this.hasResultBarATarget) this.resultBarATarget.style.width = '0%'
    if (this.hasResultBarBTarget) this.resultBarBTarget.style.width = '0%'
    if (this.hasPercentATarget) this.percentATarget.classList.add('opacity-0')
    if (this.hasPercentBTarget) this.percentBTarget.classList.add('opacity-0')
    if (this.hasDrinkBadgeTarget) this.drinkBadgeTarget.classList.add('scale-0', 'opacity-0')
    if (this.hasStreakCounterTarget) this.streakCounterTarget.classList.add('opacity-0', 'scale-0')
  }

  runPhase(phase) {
    if (this.hasPhaseIndicatorTarget) {
      this.phaseIndicatorTarget.textContent = this.phases[phase]
    }

    switch(phase) {
      case 0: // Dilemma appears
        if (this.hasStep1Target) this.step1Target.classList.remove('opacity-0')
        setTimeout(() => {
          if (this.hasOptionATarget) this.optionATarget.classList.remove('-translate-x-full', 'opacity-0')
        }, 200)
        setTimeout(() => {
          if (this.hasVsBadgeTarget) this.vsBadgeTarget.classList.remove('scale-0', 'opacity-0')
        }, 400)
        setTimeout(() => {
          if (this.hasOptionBTarget) this.optionBTarget.classList.remove('translate-x-full', 'opacity-0')
        }, 600)
        break

      case 1: // Voting
        if (this.hasStep2Target) this.step2Target.classList.remove('opacity-0')
        const voters = [this.voter1Target, this.voter2Target, this.voter3Target, this.voter4Target].filter(Boolean)
        voters.forEach((v, i) => {
          setTimeout(() => v.classList.remove('opacity-0', '-translate-y-4'), i * 200)
        })
        setTimeout(() => {
          if (this.hasVoteLabelTarget) this.voteLabelTarget.classList.remove('opacity-0')
        }, 1000)
        break

      case 2: // Results
        if (this.hasStep3Target) this.step3Target.classList.remove('opacity-0', 'scale-95')
        setTimeout(() => {
          if (this.hasResultBarATarget) this.resultBarATarget.style.width = '75%'
          if (this.hasResultBarBTarget) this.resultBarBTarget.style.width = '25%'
        }, 300)
        setTimeout(() => {
          if (this.hasPercentATarget) this.percentATarget.classList.remove('opacity-0')
          if (this.hasPercentBTarget) this.percentBTarget.classList.remove('opacity-0')
        }, 800)
        break

      case 3: // Minority drinks
        if (this.hasDrinkBadgeTarget) this.drinkBadgeTarget.classList.remove('scale-0', 'opacity-0')
        setTimeout(() => {
          if (this.hasStreakCounterTarget) this.streakCounterTarget.classList.remove('opacity-0', 'scale-0')
        }, 500)
        break
    }
  }

  nextPhase() {
    if (this.phaseValue >= this.phases.length) {
      this.phaseValue = 0
      this.resetAll()
      this.timeout = setTimeout(() => this.runPhase(this.phaseValue), 500)
    } else {
      this.runPhase(this.phaseValue)
    }
    this.phaseValue++

    // Schedule next phase
    this.timeout = setTimeout(() => this.nextPhase(), 2500)
  }
}
