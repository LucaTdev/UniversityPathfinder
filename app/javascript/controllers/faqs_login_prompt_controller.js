import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    loginUrl: String,
  }

  connect() {
    this.modalEl = document.getElementById("faqs-login-modal")
    this.modalTitleEl = this.modalEl?.querySelector("[data-faqs-login-modal-title]")
    this.modalBodyEl = this.modalEl?.querySelector("[data-faqs-login-modal-body]")

    if (this.modalEl && window.bootstrap?.Modal) {
      this.modal = window.bootstrap.Modal.getOrCreateInstance(this.modalEl)
    }

    this.cleanupModalState()

    this.boundBeforeCache = () => this.cleanupModalState()
    this.boundPageShow = () => this.cleanupModalState()
    document.addEventListener("turbo:before-cache", this.boundBeforeCache)
    window.addEventListener("pageshow", this.boundPageShow)
  }

  disconnect() {
    if (this.boundBeforeCache) {
      document.removeEventListener("turbo:before-cache", this.boundBeforeCache)
    }
    if (this.boundPageShow) {
      window.removeEventListener("pageshow", this.boundPageShow)
    }
  }

  prompt(event) {
    event.preventDefault()

    const message = event.params?.message
    const title = event.params?.title

    if (this.modalTitleEl && title) this.modalTitleEl.textContent = title
    if (this.modalBodyEl && message) this.modalBodyEl.textContent = message

    if (this.modal) {
      this.modal.show()
      return
    }

    this.redirectToLogin()
  }

  redirectToLogin(event) {
    if (event) event.preventDefault()
    window.location.href = this.loginUrlValue || "/login"
  }

  cleanupModalState() {
    if (!this.modalEl) return

    try {
      this.modal?.hide()
    } catch {
      // ignore
    }

    this.modalEl.classList.remove("show")
    this.modalEl.style.display = "none"
    this.modalEl.setAttribute("aria-hidden", "true")
    this.modalEl.removeAttribute("aria-modal")

    document.querySelectorAll(".modal-backdrop").forEach((el) => el.remove())
    document.body.classList.remove("modal-open")
    document.body.style.removeProperty("overflow")
    document.body.style.removeProperty("padding-right")
  }
}
