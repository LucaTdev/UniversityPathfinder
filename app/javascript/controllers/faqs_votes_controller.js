import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["upCount", "downCount", "upButton", "downButton"]
  static values = {
    faqId: String,
    up: Number,
    down: Number,
    current: String,
  }

  connect() {
    this.refreshUI()
  }

  toggleUp() {
    this.submitVote("up")
  }

  toggleDown() {
    this.submitVote("down")
  }

  // ---- internals ----

  voteIs(v) {
    return (this.currentValue || "").toString() === v
  }

  async submitVote(direction) {
    const nextValue = direction === "up" ? 1 : -1
    const endpoint = `/faqs/${this.faqIdValue}/vote`

    try {
      const res = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          "Accept": "application/json",
        },
        body: JSON.stringify({ value: nextValue }),
        credentials: "same-origin",
      })

      if (res.status === 401) {
        const data = await res.json().catch(() => null)
        window.location.href = data?.login_url || "/login"
        return
      }

      if (!res.ok) return
      const data = await res.json()
      this.applyServerState(data)
    } catch {
      // UI-only: ignora errori di rete
    }
  }

  applyServerState(data) {
    if (!data) return
    if (data.up != null) this.upValue = Number(data.up)
    if (data.down != null) this.downValue = Number(data.down)
    this.currentValue = data.current || ""
    this.refreshUI()
  }

  refreshUI() {
    this.upCountTarget.textContent = this.upValue
    this.downCountTarget.textContent = this.downValue

    this.toggleActive(this.upButtonTarget, this.voteIs("up"), "success")
    this.toggleActive(this.downButtonTarget, this.voteIs("down"), "danger")
  }

  toggleActive(button, isActive, variant) {
    button.classList.toggle(`btn-outline-${variant}`, !isActive)
    button.classList.toggle(`btn-${variant}`, isActive)

    const icon = button.querySelector("i")
    if (!icon) return
    icon.classList.toggle("fa-regular", !isActive)
    icon.classList.toggle("fa-solid", isActive)
  }

  csrfToken() {
    const meta = document.querySelector("meta[name='csrf-token']")
    return meta?.getAttribute("content") || ""
  }
}
