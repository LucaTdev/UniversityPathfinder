import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    guest: Boolean,
    loginUrl: String,
  }

  connect() {
    this.loginModalEl = document.getElementById("faqVoteLoginModal")
    if (this.loginModalEl && window.bootstrap?.Modal) {
      this.loginModal = window.bootstrap.Modal.getOrCreateInstance(this.loginModalEl)
    }
  }

  closeLoginModal(event) {
    // Make closing deterministic even if data-bs-dismiss doesn't fire for some reason.
    if (event) event.preventDefault()
    this.loginModal?.hide()
  }

  vote(event) {
    if (this.guestValue) {
      event.preventDefault()

      if (this.loginModal) {
        this.loginModal.show()
      } else {
        // Fallback minimale se Bootstrap non e' disponibile per qualche motivo.
        window.location.href = this.loginUrlValue || "/login"
      }

      return
    }

    // UI-only: evidenzia il voto selezionato senza inventare contatori/persistenza.
    const votesRoot = event.currentTarget.closest(".faq-votes")
    if (!votesRoot) return

    const buttons = votesRoot.querySelectorAll("button[data-valutazione-faqs-vote-param]")
    buttons.forEach((b) => b.classList.remove("active"))
    event.currentTarget.classList.add("active")
  }
}
