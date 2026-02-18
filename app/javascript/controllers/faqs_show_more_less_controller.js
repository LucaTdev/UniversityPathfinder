import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "collapse"]

  connect() {
    this.boundShown = () => this.updateLabel(true)
    this.boundHidden = () => this.updateLabel(false)

    this.collapseTarget.addEventListener("shown.bs.collapse", this.boundShown)
    this.collapseTarget.addEventListener("hidden.bs.collapse", this.boundHidden)
  }

  disconnect() {
    this.collapseTarget.removeEventListener("shown.bs.collapse", this.boundShown)
    this.collapseTarget.removeEventListener("hidden.bs.collapse", this.boundHidden)
  }

  updateLabel(isOpen) {
    const showText = this.buttonTarget.dataset.showText || "Mostra altro"
    const hideText = this.buttonTarget.dataset.hideText || "Mostra meno"
    this.buttonTarget.textContent = isOpen ? hideText : showText
  }
}

