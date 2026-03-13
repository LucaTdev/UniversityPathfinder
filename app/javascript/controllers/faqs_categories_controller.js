import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]
  static values = { initial: Array }

  connect() {
    this.categories = this.normalizeCategories(this.initialValue)
    this.render()
    this.refreshFromServer()
  }

  add() {
    const raw = this.inputTarget.value || ""
    const name = raw.trim()
    if (!name) return

    this.createCategory(name)
  }

  editCategory(category) {
    const current = (category?.name || "").toString().trim()
    if (!current) return
    if (category?.general) return

    const raw = window.prompt("Modifica categoria:", current)
    if (raw === null) return

    const next = raw.trim()
    if (!next) return

    this.updateCategory(category.id, next)
  }

  deleteCategory(category) {
    const value = (category?.name || "").toString().trim()
    if (!value) return
    if (category?.general) return

    const ok = window.confirm(`Eliminare la categoria “${value}” dalla lista?`)
    if (!ok) return

    this.destroyCategory(category.id)
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
      left.textContent = cat.name

      const right = document.createElement("div")
      right.className = "d-flex align-items-center"

      const badge = document.createElement("span")
      badge.className = "badge text-bg-light"
      badge.textContent = typeof cat.faqs_count === "number" ? String(cat.faqs_count) : "FAQ"

      const actions = document.createElement("div")
      actions.className = "btn-group ms-2"
      actions.setAttribute("role", "group")
      actions.setAttribute("aria-label", "Azioni categoria")

      const editBtn = document.createElement("button")
      editBtn.type = "button"
      editBtn.className = "btn btn-sm btn-outline-primary"
      editBtn.title = "Modifica categoria"
      editBtn.innerHTML = '<i class="fas fa-edit"></i>'
      editBtn.disabled = !!cat.general
      editBtn.addEventListener("click", () => this.editCategory(cat))

      const deleteBtn = document.createElement("button")
      deleteBtn.type = "button"
      deleteBtn.className = "btn btn-sm btn-outline-danger"
      deleteBtn.title = "Elimina categoria"
      deleteBtn.innerHTML = '<i class="fas fa-trash"></i>'
      deleteBtn.disabled = !!cat.general
      deleteBtn.addEventListener("click", () => this.deleteCategory(cat))

      actions.appendChild(editBtn)
      actions.appendChild(deleteBtn)

      right.appendChild(badge)
      right.appendChild(actions)

      item.appendChild(left)
      item.appendChild(right)
      this.listTarget.appendChild(item)
    })
  }

  // ---- internals ----

  normalizeCategories(initial) {
    const raw = Array.isArray(initial) ? initial : []
    const normalized = raw
      .map((c) => {
        if (typeof c === "string") return { id: null, name: c, faqs_count: null, general: this.isGeneralName(c) }
        const name = (c?.name || "").toString()
        return {
          id: c?.id ?? null,
          name,
          faqs_count: typeof c?.faqs_count === "number" ? Number(c.faqs_count) : null,
          general: !!c?.general || this.isGeneralName(name),
        }
      })
      .filter((c) => c.name.trim() !== "")

    return this.sortCategories(normalized)
  }

  sortCategories(categories) {
    return [...categories].sort((a, b) => {
      if (a.general && !b.general) return -1
      if (!a.general && b.general) return 1
      return a.name.localeCompare(b.name)
    })
  }

  isGeneralName(name) {
    return (name || "").toString().trim().toLowerCase() === "generale"
  }

  async refreshFromServer() {
    try {
      const res = await fetch("/admin/faq_categories", {
        headers: { Accept: "application/json" },
        credentials: "same-origin",
      })
      if (!res.ok) return

      const data = await res.json()
      this.applyServerCategories(data?.categories)
    } catch {
      // ignore
    }
  }

  applyServerCategories(categories) {
    if (!Array.isArray(categories)) return
    this.categories = this.normalizeCategories(categories)
    this.render()
    this.syncCategorySelects()
  }

  async createCategory(name) {
    try {
      const res = await fetch("/admin/faq_categories", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          Accept: "application/json",
        },
        body: JSON.stringify({ faq_category: { name } }),
        credentials: "same-origin",
      })

      const data = await res.json().catch(() => null)
      if (!res.ok) return this.showErrors(data)

      this.inputTarget.value = ""
      this.applyServerCategories(data?.categories)
    } catch {
      // ignore
    }
  }

  async updateCategory(id, name) {
    if (!id) return

    try {
      const res = await fetch(`/admin/faq_categories/${id}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          Accept: "application/json",
        },
        body: JSON.stringify({ faq_category: { name } }),
        credentials: "same-origin",
      })

      const data = await res.json().catch(() => null)
      if (!res.ok) return this.showErrors(data)

      this.applyServerCategories(data?.categories)
    } catch {
      // ignore
    }
  }

  async destroyCategory(id) {
    if (!id) return

    try {
      const res = await fetch(`/admin/faq_categories/${id}`, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": this.csrfToken(),
          Accept: "application/json",
        },
        credentials: "same-origin",
      })

      const data = await res.json().catch(() => null)
      if (!res.ok) return this.showErrors(data)

      this.applyServerCategories(data?.categories)
    } catch {
      // ignore
    }
  }

  syncCategorySelects() {
    const selects = document.querySelectorAll("select[data-faqs-category-select]")
    if (selects.length === 0) return

    const general = this.categories.find((c) => c.general) || null

    selects.forEach((select) => {
      const currentValue = select.value
      const placeholder = select.querySelector("option[data-faqs-category-placeholder]")

      // Preserve placeholder if present
      select.innerHTML = ""
      if (placeholder) select.appendChild(placeholder)

      this.categories.forEach((cat) => {
        if (!cat.id) return
        const opt = document.createElement("option")
        opt.value = String(cat.id)
        opt.textContent = cat.name
        select.appendChild(opt)
      })

      const stillExists = Array.from(select.options).some((o) => o.value === currentValue)
      if (stillExists) {
        select.value = currentValue
      } else if (general?.id) {
        select.value = String(general.id)
      }
    })
  }

  showErrors(data) {
    const messages = Array.isArray(data?.messages) ? data.messages : []
    const text = messages.length ? messages.join("\n") : "Operazione non riuscita."
    window.alert(text)
  }

  csrfToken() {
    const meta = document.querySelector("meta[name='csrf-token']")
    return meta?.getAttribute("content") || ""
  }
}
