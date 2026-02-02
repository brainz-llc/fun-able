import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "phaseIndicator",
    "playerIndicator",
    "choiceButtons",
    "truthButton",
    "dareButton",
    "cardContainer",
    "cardInner",
    "cardFront",
    "cardType",
    "cardContent",
    "cardIcon",
    "actionButtons",
    "completeButton",
    "drinkButton",
    "successMessage",
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
      { text: "Es tu turno...", color: "text-amber-400" },
      { text: "Verdad o Reto?", color: "text-amber-400" },
      { text: "Elegiste Reto!", color: "text-amber-500" },
      { text: "Completa el reto o toma!", color: "text-amber-500" },
      { text: "Reto completado!", color: "text-green-400" }
    ]

    this.challenges = {
      truth: [
        "Cual es tu secreto mas vergonzoso?",
        "Cual es tu mayor miedo?",
        "Que es lo mas loco que has hecho por amor?",
        "Si pudieras cambiar algo de tu pasado, que seria?"
      ],
      dare: [
        "Imita a alguien del grupo hasta que adivinen quien es.",
        "Baila sin musica por 30 segundos.",
        "Deja que el grupo publique algo en tus redes.",
        "Cuenta un chiste malo con cara seria."
      ]
    }

    this.currentType = 'dare' // Will alternate
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
    // Hide player indicator
    this.playerIndicatorTarget.classList.add("opacity-0")
    this.playerIndicatorTarget.classList.remove("opacity-100")

    // Hide choice buttons
    this.choiceButtonsTarget.classList.add("opacity-0", "scale-90")
    this.choiceButtonsTarget.classList.remove("opacity-100", "scale-100")

    // Hide card
    this.cardContainerTarget.classList.add("opacity-0", "scale-75")
    this.cardContainerTarget.classList.remove("opacity-100", "scale-100")
    this.cardInnerTarget.style.transform = "rotateY(0deg)"

    // Hide action buttons
    this.actionButtonsTarget.classList.add("opacity-0", "translate-y-8")
    this.actionButtonsTarget.classList.remove("opacity-100", "translate-y-0")

    // Hide success message
    this.successMessageTarget.classList.add("opacity-0", "scale-0")
    this.successMessageTarget.classList.remove("opacity-100", "scale-100")

    // Reset button highlights
    this.truthButtonTarget.classList.remove("ring-4", "ring-cyan-400", "scale-105", "ring-pulse-active")
    this.dareButtonTarget.classList.remove("ring-4", "ring-amber-400", "scale-105", "ring-pulse-active")
    this.completeButtonTarget.classList.remove("ring-4", "ring-green-400", "scale-105")

    // Reset step indicators
    this.resetSteps()
  }

  resetSteps() {
    [this.step1Target, this.step2Target, this.step3Target, this.step4Target].forEach(step => {
      step.classList.remove("active")
    })
  }

  activateStep(stepNum) {
    const steps = [this.step1Target, this.step2Target, this.step3Target, this.step4Target]
    // Activate all steps up to and including the current step
    for (let i = 0; i < stepNum && i < steps.length; i++) {
      steps[i].classList.add("active")
    }
  }

  updatePhaseIndicator(phaseIndex) {
    const phase = this.phases[phaseIndex]
    this.phaseIndicatorTarget.innerHTML = `<span class="${phase.color}">${phase.text}</span>`
    this.phaseIndicatorTarget.classList.add("animate-pulse")
    setTimeout(() => this.phaseIndicatorTarget.classList.remove("animate-pulse"), 500)
  }

  // Phase 0: Show player indicator - "It's your turn"
  runPhase0() {
    this.updatePhaseIndicator(0)
    this.activateStep(1)

    this.timeout = setTimeout(() => {
      // Show player indicator with animation
      this.playerIndicatorTarget.classList.remove("opacity-0")
      this.playerIndicatorTarget.classList.add("opacity-100")

      this.timeout = setTimeout(() => {
        this.phaseValue = 1
        this.runPhase1()
      }, 1800)
    }, 400)
  }

  // Phase 1: Show choice buttons - "Truth or Dare?"
  runPhase1() {
    this.updatePhaseIndicator(1)
    this.activateStep(2)

    this.timeout = setTimeout(() => {
      // Hide player indicator
      this.playerIndicatorTarget.classList.add("opacity-0")
      this.playerIndicatorTarget.classList.remove("opacity-100")

      // Show choice buttons
      this.timeout = setTimeout(() => {
        this.choiceButtonsTarget.classList.remove("opacity-0", "scale-90")
        this.choiceButtonsTarget.classList.add("opacity-100", "scale-100")

        // Simulate hovering between choices
        this.timeout = setTimeout(() => {
          // Hover Truth
          this.truthButtonTarget.classList.add("ring-4", "ring-cyan-400", "scale-105")

          this.timeout = setTimeout(() => {
            // Move to Dare
            this.truthButtonTarget.classList.remove("ring-4", "ring-cyan-400", "scale-105")
            this.dareButtonTarget.classList.add("ring-4", "ring-amber-400", "scale-105", "ring-pulse-active")

            this.timeout = setTimeout(() => {
              // Select Dare
              this.phaseValue = 2
              this.runPhase2()
            }, 1000)
          }, 800)
        }, 1000)
      }, 300)
    }, 200)
  }

  // Phase 2: Card flip reveal
  runPhase2() {
    this.updatePhaseIndicator(2)
    this.activateStep(3)

    // Pick a random dare
    const randomDare = this.challenges.dare[Math.floor(Math.random() * this.challenges.dare.length)]
    this.cardTypeTarget.textContent = "Reto"
    this.cardContentTarget.textContent = randomDare

    // Update card front styling for dare (amber/orange)
    this.cardFrontTarget.style.borderColor = "rgba(245, 158, 11, 0.6)"
    this.cardFrontTarget.style.boxShadow = "0 0 50px rgba(245, 158, 11, 0.35)"

    // Update icon
    if (this.hasCardIconTarget) {
      this.cardIconTarget.style.background = "linear-gradient(135deg, #f59e0b 0%, #d97706 100%)"
      this.cardIconTarget.innerHTML = `<svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>`
    }

    this.timeout = setTimeout(() => {
      // Hide choice buttons
      this.choiceButtonsTarget.classList.add("opacity-0", "scale-90")
      this.choiceButtonsTarget.classList.remove("opacity-100", "scale-100")
      this.dareButtonTarget.classList.remove("ring-4", "ring-amber-400", "scale-105", "ring-pulse-active")

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
          }, 1200)
        }, 1000)
      }, 400)
    }, 400)
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
        this.completeButtonTarget.classList.add("ring-4", "ring-green-400", "scale-105")

        this.timeout = setTimeout(() => {
          this.phaseValue = 4
          this.runPhase4()
        }, 1000)
      }, 1500)
    }, 600)
  }

  // Phase 4: Success and restart
  runPhase4() {
    this.updatePhaseIndicator(4)

    // Hide action buttons
    this.actionButtonsTarget.classList.add("opacity-0", "translate-y-8")
    this.actionButtonsTarget.classList.remove("opacity-100", "translate-y-0")
    this.completeButtonTarget.classList.remove("ring-4", "ring-green-400", "scale-105")

    // Hide card with animation
    this.cardContainerTarget.classList.add("opacity-0", "scale-75")
    this.cardContainerTarget.classList.remove("opacity-100", "scale-100")

    this.timeout = setTimeout(() => {
      // Show success message
      this.successMessageTarget.classList.remove("opacity-0", "scale-0")
      this.successMessageTarget.classList.add("opacity-100", "scale-100", "success-bounce")

      // Restart demo after delay
      this.timeout = setTimeout(() => {
        this.successMessageTarget.classList.remove("success-bounce")
        this.startDemo()
      }, 2800)
    }, 400)
  }
}
