import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["timer", "blackCard", "submissions", "scoreboard", "judgeMessage", "victoryModal", "victoryTitle", "victoryGif"]
  static values = {
    id: Number,
    playerId: Number,
    isJudge: Boolean
  }

  connect() {
    this.subscribeToChannel()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribeToChannel() {
    this.subscription = consumer.subscriptions.create(
      { channel: "GameChannel", game_id: this.idValue },
      {
        connected: () => this.handleConnected(),
        disconnected: () => this.handleDisconnected(),
        received: (data) => this.handleReceived(data)
      }
    )
  }

  handleConnected() {
    console.log("Connected to GameChannel")
    this.subscription.perform("request_state")
  }

  handleDisconnected() {
    console.log("Disconnected from GameChannel")
  }

  handleReceived(data) {
    console.log("Received:", data.type, data)

    switch (data.type) {
      case "game_state":
        this.updateGameState(data)
        break
      case "player_joined":
      case "player_left":
      case "player_status_changed":
        this.updatePlayers(data)
        break
      case "game_started":
      case "new_round":
        this.handleNewRound(data)
        break
      case "card_submitted":
        this.handleCardSubmitted(data)
        break
      case "judging_started":
        this.handleJudgingStarted(data)
        break
      case "winner_selected":
        this.handleWinnerSelected(data)
        break
      case "game_ended":
        this.handleGameEnded(data)
        break
      case "timer_update":
        this.updateTimer(data)
        break
    }
  }

  updateGameState(data) {
    // Refresh page to get latest state
    if (data.game && data.game.status !== "lobby") {
      // Update UI based on game state
    }
  }

  updatePlayers(data) {
    // Turbo will handle this via broadcasts
  }

  handleNewRound(data) {
    // Refresh the page to get new round state
    window.Turbo.visit(window.location.href)
  }

  handleCardSubmitted(data) {
    // Show submission count update
    const submittedCount = data.submissions_count
    const expectedCount = data.expected_count

    if (this.hasJudgeMessageTarget) {
      this.judgeMessageTarget.querySelector("p:last-child").textContent =
        `${submittedCount}/${expectedCount} jugadores han respondido`
    }
  }

  handleJudgingStarted(data) {
    // Refresh to show submissions
    window.Turbo.visit(window.location.href)
  }

  handleWinnerSelected(data) {
    this.showVictory(data.winner_name, "round_win")

    // Update scoreboard
    setTimeout(() => {
      window.Turbo.visit(window.location.href)
    }, 3000)
  }

  handleGameEnded(data) {
    this.showVictory(data.winner_name, "game_win")

    setTimeout(() => {
      window.Turbo.visit(window.location.href)
    }, 5000)
  }

  updateTimer(data) {
    const timerController = this.application.getControllerForElementAndIdentifier(
      this.timerTarget,
      "timer"
    )
    if (timerController) {
      timerController.updateFromServer(data.remaining)
    }
  }

  selectWinner(event) {
    const submissionId = event.currentTarget.dataset.submissionId

    fetch(`/games/${this.idValue}/actions/select_winner`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ submission_id: submissionId })
    })
  }

  toggleScoreboard() {
    if (this.hasScoreboardTarget) {
      this.scoreboardTarget.classList.toggle("hidden")
    }
  }

  showVictory(winnerName, category) {
    if (!this.hasVictoryModalTarget) return

    this.victoryTitleTarget.textContent =
      category === "game_win"
        ? `${winnerName} gana la partida!`
        : `${winnerName} gana la ronda!`

    // Fetch victory GIF
    fetch(`/api/v1/memes/victory?category=${category}`)
      .then(res => res.json())
      .then(data => {
        if (data.success && data.data.url) {
          this.victoryGifTarget.innerHTML = `<img src="${data.data.url}" class="w-full rounded">`
        }
      })

    this.victoryModalTarget.classList.remove("hidden")

    // Trigger confetti if available
    if (typeof confetti === "function") {
      confetti({
        particleCount: 100,
        spread: 70,
        origin: { y: 0.6 }
      })
    }
  }

  closeVictory() {
    if (this.hasVictoryModalTarget) {
      this.victoryModalTarget.classList.add("hidden")
    }
  }
}
