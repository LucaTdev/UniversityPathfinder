import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.modalEl = this.element

    if (this.modalEl && window.bootstrap?.Modal) {
      this.modal = window.bootstrap.Modal.getOrCreateInstance(this.modalEl)
    }

    this.cleanupModalState()

    this.boundBeforeCache = () => this.cleanupModalState()
    this.boundPageShow = () => this.cleanupModalState()
    document.addEventListener("turbo:before-cache", this.boundBeforeCache)
    window.addEventListener("pageshow", this.boundPageShow)

    this.boundShow = () => this.cleanupBackdropsIfOrphaned()
    this.boundHidden = () => this.cleanupBackdropsIfOrphaned()
    this.modalEl.addEventListener("show.bs.modal", this.boundShow)
    this.modalEl.addEventListener("hidden.bs.modal", this.boundHidden)
  }

  disconnect() {
    if (this.boundBeforeCache) {
      document.removeEventListener("turbo:before-cache", this.boundBeforeCache)
    }
    if (this.boundPageShow) {
      window.removeEventListener("pageshow", this.boundPageShow)
    }
    if (this.modalEl && this.boundShow) {
      this.modalEl.removeEventListener("show.bs.modal", this.boundShow)
    }
    if (this.modalEl && this.boundHidden) {
      this.modalEl.removeEventListener("hidden.bs.modal", this.boundHidden)
    }
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

    this.cleanupBackdropsIfOrphaned()
  }

  cleanupBackdropsIfOrphaned() {
    const openModals = document.querySelectorAll(".modal.show")
    if (openModals.length > 0) return

    document.querySelectorAll(".modal-backdrop").forEach((el) => el.remove())
    document.body.classList.remove("modal-open")
    document.body.style.removeProperty("overflow")
    document.body.style.removeProperty("padding-right")
  }
}

