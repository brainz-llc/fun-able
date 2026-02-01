import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "phaseIndicator",
    "choiceButtons",
    "truthButton",
    "dareButton",
    "cardContainer",
    "cardInner",
    "cardFront",
    "cardType",
    "cardContent",
    "actionButtons",
    "completeButton",
    "drinkButton",
    "successMessage",
    "playerIndicator",
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
      { text: "Es tu turno...", color: "text-purple-400" },
      { text: "Elige: Verdad o Reto?", color: "text-purple-400" },
      { text: "Elegiste Reto!", color: "text-pink-400" },
      { text: "Completa el reto o toma!", color: "text-pink-400" },
      { text: "Siguiente turno...", color: "text-green-400" }
    ]

    this.challenges = {
      truth: [
        "Cual es tu secreto mas vergonzoso?",
        "Cual es tu mayor miedo?",
        "Que es lo mas loco que has hecho por amor?"
      ],
      dare: [
        "Imita a alguien del grupo hasta que adivinen quien es.",
        "Baila sin musica por 30 segundos.",
        "Deja que el grupo publique algo en tus redes."
      ]
    }

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
    // Hide all elements
    this.choiceButtonsTarget.classList.add("opacity-0", "scale-90")
    this.choiceButtonsTarget.classList.remove("opacity-100", "scale-100")

    this.cardContainerTarget.classList.add("opacity-0", "scale-75")
    this.cardContainerTarget.classList.remove("opacity-100", "scale-100")
    this.cardInnerTarget.style.transform = "rotateY(0deg)"

    this.actionButtonsTarget.classList.add("opacity-0", "translate-y-8")
    this.actionButtonsTarget.classList.remove("opacity-100", "translate-y-0")

    this.successMessageTarget.classList.add("opacity-0", "scale-0")
    this.successMessageTarget.classList.remove("opacity-100", "scale-100")

    this.playerIndicatorTarget.classList.add("opacity-0")
    this.playerIndicatorTarget.classList.remove("opacity-100")

    // Reset button highlights
    this.truthButtonTarget.classList.remove("ring-4", "ring-cyan-400", "scale-110")
    this.dareButtonTarget.classList.remove("ring-4", "ring-pink-400", "scale-110")
    this.completeButtonTarget.classList.remove("ring-4", "ring-green-400", "scale-110")

    // Reset step indicators
    this.resetSteps()
  }

  resetSteps() {
    [this.step1Target, this.step2Target, this.step3Target, this.step4Target].forEach(step => {
      step.style.background = "rgba(168, 85, 247, 0.3)"
      step.style.boxShadow = "none"
    })
  }

  activateStep(stepNum) {
    const steps = [this.step1Target, this.step2Target, this.step3Target, this.step4Target]
    if (stepNum >= 1 && stepNum <= 4) {
      steps[stepNum - 1].style.background = "#a855f7"
      steps[stepNum - 1].style.boxShadow = "0 0 10px rgba(168, 85, 247, 0.6)"
    }
  }

  updatePhaseIndicator(phaseIndex) {
    const phase = this.phases[phaseIndex]
    this.phaseIndicatorTarget.innerHTML = `<span class="${phase.color}">${phase.text}</span>`
    this.phaseIndicatorTarget.classList.add("animate-pulse")
    setTimeout(() => this.phaseIndicatorTarget.classList.remove("animate-pulse"), 500)
  }

  // Phase 0: Show player indicator
  runPhase0() {
    this.updatePhaseIndicator(0)
    this.activateStep(1)

    this.timeout = setTimeout(() => {
      this.playerIndicatorTarget.classList.remove("opacity-0")
      this.playerIndicatorTarget.classList.add("opacity-100")

      this.timeout = setTimeout(() => {
        this.phaseValue = 1
        this.runPhase1()
      }, 1500)
    }, 500)
  }

  // Phase 1: Show choice buttons
  runPhase1() {
    this.updatePhaseIndicator(1)
    this.activateStep(2)

    // Hide player indicator
    this.playerIndicatorTarget.classList.add("opacity-0")
    this.playerIndicatorTarget.classList.remove("opacity-100")

    this.timeout = setTimeout(() => {
      this.choiceButtonsTarget.classList.remove("opacity-0", "scale-90")
      this.choiceButtonsTarget.classList.add("opacity-100", "scale-100")

      // Simulate hovering between choices
      this.timeout = setTimeout(() => {
        this.truthButtonTarget.classList.add("ring-4", "ring-cyan-400", "scale-110")

        this.timeout = setTimeout(() => {
          this.truthButtonTarget.classList.remove("ring-4", "ring-cyan-400", "scale-110")
          this.dareButtonTarget.classList.add("ring-4", "ring-pink-400", "scale-110")

          this.timeout = setTimeout(() => {
            // Select Dare
            this.phaseValue = 2
            this.runPhase2()
          }, 800)
        }, 600)
      }, 800)
    }, 300)
  }

  // Phase 2: Card flip reveal
  runPhase2() {
    this.updatePhaseIndicator(2)
    this.activateStep(3)

    // Pick a random dare
    const randomDare = this.challenges.dare[Math.floor(Math.random() * this.challenges.dare.length)]
    this.cardTypeTarget.textContent = "Reto"
    this.cardTypeTarget.classList.remove("text-cyan-400")
    this.cardTypeTarget.classList.add("text-pink-400")
    this.cardContentTarget.textContent = randomDare

    // Update card front border color to pink
    this.cardFrontTarget.style.borderColor = "rgba(236, 72, 153, 0.6)"
    this.cardFrontTarget.style.boxShadow = "0 0 40px rgba(236, 72, 153, 0.35)"

    this.timeout = setTimeout(() => {
      // Hide choice buttons
      this.choiceButtonsTarget.classList.add("opacity-0", "scale-90")
      this.choiceButtonsTarget.classList.remove("opacity-100", "scale-100")
      this.dareButtonTarget.classList.remove("ring-4", "ring-pink-400", "scale-110")

      // Show card (back side first)
      this.timeout = setTimeout(() => {
        this.cardContainerTarget.classList.remove("opacity-0", "scale-75")
        this.cardContainerTarget.classList.add("opacity-100", "scale-100")

        // Flip the card after a moment
        this.timeout = setTimeout(() => {
          this.cardInnerTarget.style.transform = "rotateY(180deg)"

          this.timeout = setTimeout(() => {
            this.phaseValue = 3
            this.runPhase3()
          }, 1000)
        }, 800)
      }, 400)
    }, 300)
  }

  // Phase 3: Show action buttons
  runPhase3() {
    this.updatePhaseIndicator(3)
    this.activateStep(4)

    this.timeout = setTimeout(() => {
      this.actionButtonsTarget.classList.remove("opacity-0", "translate-y-8")
      this.actionButtonsTarget.classList.add("opacity-100", "translate-y-0")

      // Simulate choosing to complete
      this.timeout = setTimeout(() => {
        this.completeButtonTarget.classList.add("ring-4", "ring-green-400", "scale-110")

        this.timeout = setTimeout(() => {
          this.phaseValue = 4
          this.runPhase4()
        }, 800)
      }, 1200)
    }, 500)
  }

  // Phase 4: Success and restart
  runPhase4() {
    this.updatePhaseIndicator(4)

    // Hide action buttons
    this.actionButtonsTarget.classList.add("opacity-0", "translate-y-8")
    this.actionButtonsTarget.classList.remove("opacity-100", "translate-y-0")
    this.completeButtonTarget.classList.remove("ring-4", "ring-green-400", "scale-110")

    // Hide card
    this.cardContainerTarget.classList.add("opacity-0", "scale-75")
    this.cardContainerTarget.classList.remove("opacity-100", "scale-100")

    this.timeout = setTimeout(() => {
      // Show success message
      this.successMessageTarget.classList.remove("opacity-0", "scale-0")
      this.successMessageTarget.classList.add("opacity-100", "scale-100")

      // Restart demo after delay
      this.timeout = setTimeout(() => {
        this.startDemo()
      }, 2500)
    }, 300)
  }
}
