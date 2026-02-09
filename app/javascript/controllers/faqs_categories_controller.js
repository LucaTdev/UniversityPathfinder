import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]
  static values = { initial: Array }

  connect() {
    this.categories = Array.isArray(this.initialValue) ? [...this.initialValue] : []
    this.render()
  }

  add() {
    const raw = this.inputTarget.value || ""
    const name = raw.trim()
    if (!name) return

    const exists = this.categories.some((c) => String(c).toLowerCase() === name.toLowerCase())
    if (exists) {
      this.inputTarget.value = ""
      return
    }

    this.categories.push(name)
    this.categories.sort((a, b) => a.localeCompare(b))
    this.inputTarget.value = ""
    this.render()
  }

  render() {
    this.listTarget.innerHTML = ""

    if (this.categories.length === 0) {
      const empty = document.createElement("div")
      empty.className = "list-group-item text-muted"
      empty.textContent = "Nessuna categoria ancora."
      this.listTarget.appendChild(empty)
      return
    }

    this.categories.forEach((cat) => {
      const item = document.createElement("div")
      item.className = "list-group-item d-flex align-items-center justify-content-between"

      const left = document.createElement("span")
      left.textContent = cat

      const right = document.createElement("span")
      right.className = "badge text-bg-light"
      right.textContent = "FAQ"

      item.appendChild(left)
      item.appendChild(right)
      this.listTarget.appendChild(item)
    })
  }
}

