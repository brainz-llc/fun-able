import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "results", "selected", "urlInput"]
  static values = {
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.searchTimeout = null
  }

  search(event) {
    const query = event.target.value.trim()

    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }

    if (query.length < 2) {
      this.clearResults()
      return
    }

    this.searchTimeout = setTimeout(() => {
      this.performSearch(query)
    }, this.debounceValue)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`/api/v1/memes/search?q=${encodeURIComponent(query)}&limit=12`)
      const data = await response.json()

      if (data.success) {
        this.renderResults(data.data.gifs)
      }
    } catch (error) {
      console.error("Meme search failed:", error)
    }
  }

  renderResults(gifs) {
    if (!this.hasResultsTarget) return

    this.resultsTarget.innerHTML = gifs.map(gif => `
      <div class="meme-item" data-action="click->meme-picker#selectGif" data-url="${gif.url}">
        <img src="${gif.preview_url}" alt="${gif.title}" class="w-full h-20 object-cover">
      </div>
    `).join("")
  }

  selectGif(event) {
    const url = event.currentTarget.dataset.url

    if (this.hasUrlInputTarget) {
      this.urlInputTarget.value = url
    }

    if (this.hasSelectedTarget) {
      this.selectedTarget.innerHTML = `<img src="${url}" class="max-w-full h-32 object-contain rounded">`
    }

    // Highlight selected
    this.resultsTarget.querySelectorAll(".meme-item").forEach(item => {
      item.classList.remove("meme-item-selected")
    })
    event.currentTarget.classList.add("meme-item-selected")
  }

  clearResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ""
    }
  }

  async loadTrending() {
    try {
      const response = await fetch("/api/v1/memes/trending?limit=12")
      const data = await response.json()

      if (data.success) {
        this.renderResults(data.data.gifs)
      }
    } catch (error) {
      console.error("Trending load failed:", error)
    }
  }
}
