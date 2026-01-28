import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cards", "form", "cardInputs"]
  static values = {
    pickCount: { type: Number, default: 1 }
  }

  connect() {
    this.selectedCards = []
    this.isSubmitting = false

    // Add submit handler for feedback
    if (this.hasFormTarget) {
      this.formTarget.addEventListener("submit", (e) => this.handleSubmit(e))
    }

    this.setupMobileAutoScroll()
  }

  setupMobileAutoScroll() {
    // Only run on mobile devices (max-width: 768px)
    if (!window.matchMedia("(max-width: 768px)").matches) {
      return
    }

    // Check if user is not the judge (has cards to select)
    const hasCards = this.hasCardsTarget && this.cardsTarget.querySelectorAll(".game-card").length > 0
    if (!hasCards) {
      return
    }

    // Get round identifier from URL
    const roundMatch = window.location.pathname.match(/\/rounds\/(\d+)/)
    if (!roundMatch) {
      return
    }

    const roundId = roundMatch[1]
    const storageKey = `hand_scrolled_round_${roundId}`

    // Check if already scrolled this round
    if (sessionStorage.getItem(storageKey)) {
      return
    }

    // Mark as scrolled and scroll after 3 seconds
    sessionStorage.setItem(storageKey, "true")
    setTimeout(() => {
      this.element.scrollIntoView({ behavior: "smooth", block: "start" })
    }, 3000)
  }

  handleSubmit(event) {
    if (this.isSubmitting) {
      event.preventDefault()
      return
    }

    this.isSubmitting = true

    // Disable card selection and show submitting state
    if (this.hasCardsTarget) {
      this.cardsTarget.querySelectorAll(".game-card, .game-card-touch").forEach(card => {
        card.classList.add("pointer-events-none", "opacity-50")
      })
    }
  }

  toggleCard(event) {
    const card = event.currentTarget
    const cardId = card.dataset.cardId

    if (card.classList.contains("card-selected")) {
      // Deselect
      card.classList.remove("card-selected")
      this.selectedCards = this.selectedCards.filter(id => id !== cardId)
    } else {
      // Check if we can select more
      if (this.selectedCards.length >= this.pickCountValue) {
        // Deselect first card if at limit
        const firstSelectedId = this.selectedCards[0]
        const firstCard = this.cardsTarget.querySelector(`[data-card-id="${firstSelectedId}"]`)
        if (firstCard) {
          firstCard.classList.remove("card-selected")
        }
        this.selectedCards.shift()
      }

      // Select this card
      card.classList.add("card-selected")
      this.selectedCards.push(cardId)

      // Add haptic feedback on mobile if available
      if (navigator.vibrate) {
        navigator.vibrate(10)
      }
    }

    this.updateForm()
  }

  updateForm() {
    const hiddenInputsHtml = this.selectedCards
      .map(id => `<input type="hidden" name="card_ids[]" value="${id}">`)
      .join("")

    // Update hidden inputs
    if (this.hasCardInputsTarget) {
      this.cardInputsTarget.innerHTML = hiddenInputsHtml
    }

    // Auto-submit when required cards are selected
    const isValid = this.selectedCards.length === this.pickCountValue
    if (isValid && !this.isSubmitting) {
      // Small delay for visual feedback before submitting
      setTimeout(() => {
        if (this.hasFormTarget && !this.isSubmitting) {
          this.formTarget.requestSubmit()
        }
      }, 150)
    }
  }

  // Keyboard navigation
  selectByIndex(index) {
    const cards = this.cardsTarget.querySelectorAll(".game-card")
    if (cards[index]) {
      this.toggleCard({ currentTarget: cards[index] })
    }
  }
}
