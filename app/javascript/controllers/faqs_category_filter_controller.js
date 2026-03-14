import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "label"]

  connect() {
    this.selectedCategory = ""
    this.apply()
  }

  select(event) {
    this.selectedCategory = (event.params.category || "").toString().trim()
    this.apply()
  }

  apply() {
    const selected = this.normalize(this.selectedCategory)

    this.cardTargets.forEach((el) => {
      const cardCategory = this.normalize(el.dataset.faqCategory || "")
      el.hidden = selected !== "" && cardCategory !== selected
    })

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = `Categoria: ${this.selectedCategory || "Tutte"}`
    }
  }

  normalize(value) {
    return (value || "").toString().trim().toLowerCase()
  }
}

