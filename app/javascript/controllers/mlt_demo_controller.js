import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "phaseIndicator",
    "statementCard",
    "votingArea",
    "player1",
    "player2",
    "player3",
    "player4",
    "vote1",
    "vote2",
    "vote3",
    "vote4",
    "winnerReveal",
    "tieBadge",
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
      'Todos votan por un jugador!',
      'Revelacion dramatica...',
      'El mas votado bebe!'
    ]
    this.startDemo()
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
    if (this.interval) clearInterval(this.interval)
  }

  startDemo() {
    this.phaseValue = 0
    this.timeout = setTimeout(() => this.runPhase(0), 500)
    this.interval = setInterval(() => this.nextPhase(), 3500)
  }

  setStep(step) {
    const steps = [this.step1Target, this.step2Target, this.step3Target, this.step4Target].filter(Boolean)
    steps.forEach((s, i) => {
      if (s) s.classList.toggle('active', i === step)
    })
  }

  resetDemo() {
    // Reset all elements
    if (this.hasStatementCardTarget) {
      this.statementCardTarget.classList.add('opacity-0', 'scale-75')
    }
    if (this.hasVotingAreaTarget) {
      this.votingAreaTarget.classList.add('opacity-0')
    }

    const players = [this.player1Target, this.player2Target, this.player3Target, this.player4Target].filter(Boolean)
    players.forEach(p => p.classList.add('opacity-0', '-translate-y-4'))

    const votes = [this.vote1Target, this.vote2Target, this.vote3Target, this.vote4Target].filter(Boolean)
    votes.forEach(v => v.classList.add('opacity-0', 'scale-0'))

    if (this.hasWinnerRevealTarget) {
      this.winnerRevealTarget.classList.add('scale-0', 'opacity-0')
    }
    if (this.hasTieBadgeTarget) {
      this.tieBadgeTarget.classList.add('scale-0', 'opacity-0')
    }

    // Reset player 2 winner glow
    if (this.hasPlayer2Target) {
      const avatar = this.player2Target.querySelector('div')
      if (avatar) avatar.classList.remove('winner-glow')
    }
  }

  runPhase(phase) {
    if (this.hasPhaseIndicatorTarget) {
      this.phaseIndicatorTarget.textContent = this.phases[phase]
    }
    this.setStep(phase)

    switch(phase) {
      case 0: // Statement appears
        this.resetDemo()
        setTimeout(() => {
          if (this.hasStatementCardTarget) {
            this.statementCardTarget.classList.remove('opacity-0', 'scale-75')
          }
        }, 300)
        break

      case 1: // Everyone votes
        if (this.hasVotingAreaTarget) {
          this.votingAreaTarget.classList.remove('opacity-0')
        }
        // Show players one by one
        const players = [this.player1Target, this.player2Target, this.player3Target, this.player4Target].filter(Boolean)
        players.forEach((p, i) => {
          setTimeout(() => p.classList.remove('opacity-0', '-translate-y-4'), i * 200)
        })
        break

      case 2: // Dramatic reveal
        // Show vote counts
        const votes = [this.vote1Target, this.vote2Target, this.vote3Target, this.vote4Target].filter(Boolean)
        votes.forEach((v, i) => {
          setTimeout(() => v.classList.remove('opacity-0', 'scale-0'), i * 300)
        })
        break

      case 3: // Winner drinks
        // Highlight winner (Luis/Player 2)
        if (this.hasPlayer2Target) {
          const avatar = this.player2Target.querySelector('div')
          if (avatar) avatar.classList.add('winner-glow')
        }
        setTimeout(() => {
          if (this.hasWinnerRevealTarget) {
            this.winnerRevealTarget.classList.remove('scale-0', 'opacity-0')
          }
        }, 500)
        // Show tie info
        setTimeout(() => {
          if (this.hasTieBadgeTarget) {
            this.tieBadgeTarget.classList.remove('scale-0', 'opacity-0')
          }
        }, 1500)
        break
    }
  }

  nextPhase() {
    this.phaseValue = (this.phaseValue + 1) % 4
    if (this.phaseValue === 0) {
      this.resetDemo()
      this.timeout = setTimeout(() => this.runPhase(0), 500)
    } else {
      this.runPhase(this.phaseValue)
    }
  }
}
