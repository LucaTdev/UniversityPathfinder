import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["upCount", "downCount", "upButton", "downButton"]
  static values = {
    faqId: String,
    up: Number,
    down: Number
  }

  connect() {
    this.restoreVote()
    this.refreshUI()
  }

  toggleUp() {
    if (this.currentVote() === "up") {
      this.setVote(null)
    } else {
      this.setVote("up")
    }
  }

  toggleDown() {
    if (this.currentVote() === "down") {
      this.setVote(null)
    } else {
      this.setVote("down")
    }
  }

  // ---- internals (UI-only) ----

  storageKey() {
    return `faq_vote_${this.faqIdValue}`
  }

  currentVote() {
    try {
      return sessionStorage.getItem(this.storageKey())
    } catch {
      return null
    }
  }

  restoreVote() {
    const vote = this.currentVote()
    if (vote === "up") this.upValue = Number(this.upValue) + 1
    if (vote === "down") this.downValue = Number(this.downValue) + 1
  }

  setVote(nextVote) {
    const prevVote = this.currentVote()
    if (prevVote === nextVote) return

    // remove previous
    if (prevVote === "up") this.upValue = Math.max(0, Number(this.upValue) - 1)
    if (prevVote === "down") this.downValue = Math.max(0, Number(this.downValue) - 1)

    // add next
    if (nextVote === "up") this.upValue = Number(this.upValue) + 1
    if (nextVote === "down") this.downValue = Number(this.downValue) + 1

    try {
      if (nextVote) sessionStorage.setItem(this.storageKey(), nextVote)
      else sessionStorage.removeItem(this.storageKey())
    } catch {
      // ignore: UI-only
    }

    this.refreshUI()
  }

  refreshUI() {
    this.upCountTarget.textContent = this.upValue
    this.downCountTarget.textContent = this.downValue

    const vote = this.currentVote()
    this.toggleActive(this.upButtonTarget, vote === "up", "success")
    this.toggleActive(this.downButtonTarget, vote === "down", "danger")
  }

  toggleActive(button, isActive, variant) {
    button.classList.toggle(`btn-outline-${variant}`, !isActive)
    button.classList.toggle(`btn-${variant}`, isActive)

    const icon = button.querySelector("i")
    if (!icon) return
    icon.classList.toggle("fa-regular", !isActive)
    icon.classList.toggle("fa-solid", isActive)
  }
}

