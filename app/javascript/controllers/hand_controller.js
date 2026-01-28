import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cards", "form", "cardInputs", "submitButton", "mobileForm", "mobileCardInputs", "mobileSubmitButton", "mobileSelectedCount"]
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

    // Add submit handler for mobile form
    if (this.hasMobileFormTarget) {
      this.mobileFormTarget.addEventListener("submit", (e) => this.handleSubmit(e))
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

    // Show loading state on desktop button
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.textContent = "Enviando..."
      this.submitButtonTarget.classList.add("animate-pulse")
    }

    // Show loading state on mobile button
    if (this.hasMobileSubmitButtonTarget) {
      this.mobileSubmitButtonTarget.disabled = true
      this.mobileSubmitButtonTarget.textContent = "Enviando..."
      this.mobileSubmitButtonTarget.classList.add("animate-pulse")
    }

    // Disable card selection
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

    // Update hidden inputs for desktop form
    if (this.hasCardInputsTarget) {
      this.cardInputsTarget.innerHTML = hiddenInputsHtml
    }

    // Update hidden inputs for mobile form
    if (this.hasMobileCardInputsTarget) {
      this.mobileCardInputsTarget.innerHTML = hiddenInputsHtml
    }

    // Update button state
    const isValid = this.selectedCards.length === this.pickCountValue

    // Update desktop button
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = !isValid
      if (this.pickCountValue > 1) {
        this.submitButtonTarget.textContent = isValid
          ? "Enviar Cartas"
          : `Selecciona ${this.pickCountValue - this.selectedCards.length} carta(s) mas`
      }
    }

    // Update mobile button
    if (this.hasMobileSubmitButtonTarget) {
      this.mobileSubmitButtonTarget.disabled = !isValid
    }

    // Update mobile selected count
    if (this.hasMobileSelectedCountTarget) {
      this.mobileSelectedCountTarget.textContent = this.selectedCards.length
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
