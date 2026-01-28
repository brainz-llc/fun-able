import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "blackCard",
    "playerHand",
    "playerCard1",
    "playerCard2",
    "playerCard3",
    "submittedCards",
    "opponentCard1",
    "opponentCard2",
    "mySubmission",
    "winnerBadge",
    "phaseIndicator"
  ]

  static values = {
    phase: { type: Number, default: 0 }
  }

  connect() {
    this.phases = [
      "El Zar revela la carta negra",
      "Elige tu mejor respuesta",
      "Enviando tu carta...",
      "Todos responden",
      "El Zar decide...",
      "¡Ganaste!"
    ]
    this.startDemo()
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  startDemo() {
    this.resetAll()
    this.phaseValue = 0
    this.runPhase0()
  }

  resetAll() {
    // Hide everything
    this.blackCardTarget.classList.add("opacity-0", "scale-75")
    this.blackCardTarget.classList.remove("animate-float")

    this.playerHandTarget.classList.add("translate-y-full", "opacity-0")

    this.playerCard1Target.classList.remove("ring-2", "ring-cyan-400", "-translate-y-4", "scale-105")
    this.playerCard2Target.classList.remove("ring-2", "ring-cyan-400", "-translate-y-4", "scale-105")
    this.playerCard3Target.classList.remove("ring-2", "ring-cyan-400", "-translate-y-4", "scale-105")

    this.submittedCardsTarget.classList.add("opacity-0")
    this.opponentCard1Target.classList.add("-translate-x-full", "opacity-0")
    this.opponentCard2Target.classList.add("translate-x-full", "opacity-0")
    this.mySubmissionTarget.classList.add("translate-y-full", "opacity-0")
    this.mySubmissionTarget.classList.remove("ring-4", "ring-yellow-400", "shadow-winner")

    this.winnerBadgeTarget.classList.add("scale-0", "opacity-0")
  }

  updatePhaseIndicator() {
    this.phaseIndicatorTarget.textContent = this.phases[this.phaseValue]
    this.phaseIndicatorTarget.classList.add("animate-pulse")
    setTimeout(() => this.phaseIndicatorTarget.classList.remove("animate-pulse"), 500)
  }

  // Phase 0: Black card appears
  runPhase0() {
    this.updatePhaseIndicator()

    this.timeout = setTimeout(() => {
      this.blackCardTarget.classList.remove("opacity-0", "scale-75")
      this.blackCardTarget.classList.add("animate-float")

      this.timeout = setTimeout(() => {
        this.phaseValue = 1
        this.runPhase1()
      }, 1500)
    }, 500)
  }

  // Phase 1: Player hand appears
  runPhase1() {
    this.updatePhaseIndicator()

    this.timeout = setTimeout(() => {
      this.playerHandTarget.classList.remove("translate-y-full", "opacity-0")

      this.timeout = setTimeout(() => {
        this.phaseValue = 2
        this.runPhase2()
      }, 1500)
    }, 300)
  }

  // Phase 2: Player selects a card
  runPhase2() {
    this.updatePhaseIndicator()

    this.timeout = setTimeout(() => {
      // Highlight middle card
      this.playerCard2Target.classList.add("ring-2", "ring-cyan-400", "-translate-y-4", "scale-105")

      this.timeout = setTimeout(() => {
        // Card flies up and hand disappears
        this.playerHandTarget.classList.add("translate-y-full", "opacity-0")

        this.timeout = setTimeout(() => {
          this.phaseValue = 3
          this.runPhase3()
        }, 800)
      }, 1000)
    }, 500)
  }

  // Phase 3: All submitted cards appear
  runPhase3() {
    this.updatePhaseIndicator()

    this.submittedCardsTarget.classList.remove("opacity-0")

    this.timeout = setTimeout(() => {
      // Opponent 1 card slides in
      this.opponentCard1Target.classList.remove("-translate-x-full", "opacity-0")

      this.timeout = setTimeout(() => {
        // My submission slides in
        this.mySubmissionTarget.classList.remove("translate-y-full", "opacity-0")

        this.timeout = setTimeout(() => {
          // Opponent 2 card slides in
          this.opponentCard2Target.classList.remove("translate-x-full", "opacity-0")

          this.timeout = setTimeout(() => {
            this.phaseValue = 4
            this.runPhase4()
          }, 1000)
        }, 400)
      }, 400)
    }, 400)
  }

  // Phase 4: Judge is deciding
  runPhase4() {
    this.updatePhaseIndicator()

    // Simulate judging by highlighting cards briefly
    const highlightSequence = [
      this.opponentCard1Target,
      this.mySubmissionTarget,
      this.opponentCard2Target,
      this.mySubmissionTarget
    ]

    let i = 0
    const highlightNext = () => {
      if (i > 0) {
        highlightSequence[i - 1].classList.remove("ring-2", "ring-purple-400")
      }
      if (i < highlightSequence.length) {
        highlightSequence[i].classList.add("ring-2", "ring-purple-400")
        i++
        this.timeout = setTimeout(highlightNext, 500)
      } else {
        highlightSequence[highlightSequence.length - 1].classList.remove("ring-2", "ring-purple-400")
        this.timeout = setTimeout(() => {
          this.phaseValue = 5
          this.runPhase5()
        }, 300)
      }
    }

    this.timeout = setTimeout(highlightNext, 500)
  }

  // Phase 5: Winner celebration
  runPhase5() {
    this.updatePhaseIndicator()

    this.timeout = setTimeout(() => {
      // Highlight winning card
      this.mySubmissionTarget.classList.add("ring-4", "ring-yellow-400", "shadow-winner", "scale-110")

      // Show winner badge
      this.timeout = setTimeout(() => {
        this.winnerBadgeTarget.classList.remove("scale-0", "opacity-0")

        // Restart loop after delay
        this.timeout = setTimeout(() => {
          this.startDemo()
        }, 3000)
      }, 500)
    }, 300)
  }
}
