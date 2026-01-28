import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cards", "form", "cardInputs", "submitButton"]
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
  }

  handleSubmit(event) {
    if (this.isSubmitting) {
      event.preventDefault()
      return
    }

    this.isSubmitting = true

    // Show loading state
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = "Enviando..."
    this.submitButtonTarget.classList.add("animate-pulse")

    // Disable card selection
    this.cardsTarget.querySelectorAll(".game-card").forEach(card => {
      card.classList.add("pointer-events-none", "opacity-50")
    })
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
    }

    this.updateForm()
  }

  updateForm() {
    // Update hidden inputs
    this.cardInputsTarget.innerHTML = this.selectedCards
      .map(id => `<input type="hidden" name="card_ids[]" value="${id}">`)
      .join("")

    // Update button state
    const isValid = this.selectedCards.length === this.pickCountValue
    this.submitButtonTarget.disabled = !isValid

    if (this.pickCountValue > 1) {
      this.submitButtonTarget.textContent = isValid
        ? "Enviar Cartas"
        : `Selecciona ${this.pickCountValue - this.selectedCards.length} carta(s) mas`
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
