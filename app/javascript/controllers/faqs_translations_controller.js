import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "modalTitle",
    "error",
    "listSection",
    "baseQuestion",
    "list",
    "editorSection",
    "editorLocaleLabel",
    "editorLocaleBadge",
    "editorLocale",
    "domanda",
    "risposta",
    "saveButton",
  ]

  static values = {
    locales: Array,
  }

  connect() {
    this.modalEl = document.getElementById("faq-translations-modal")
    this.reset()
  }

  open(event) {
    event.preventDefault()
    const faqId = event.params?.faqId
    if (!faqId) return

    this.reset()
    this.faqId = String(faqId)
    this.showLoading()

    this.modalTitleTarget.textContent = `Traduzioni FAQ #${this.faqId}`

    if (this.modalEl && window.bootstrap?.Modal) {
      this.modal = window.bootstrap.Modal.getOrCreateInstance(this.modalEl)
      this.modal.show()
    }

    this.load()
  }

  async load() {
    this.hideError()

    try {
      const res = await fetch(`/admin/faqs/${this.faqId}/faq_translations`, {
        headers: { Accept: "application/json" },
        credentials: "same-origin",
      })

      if (res.status === 401) {
        const data = await res.json().catch(() => null)
        window.location.href = data?.login_url || "/login"
        return
      }

      const data = await res.json().catch(() => null)
      if (!res.ok) return this.showErrors(data)

      this.baseDomanda = data?.faq?.domanda?.toString() || ""
      this.baseRisposta = data?.faq?.risposta?.toString() || ""
      this.baseQuestionTarget.textContent = this.baseDomanda

      const translations = Array.isArray(data?.translations) ? data.translations : []
      this.translations = {}
      translations.forEach((t) => {
        const loc = this.normalizeLocale(t?.locale)
        if (!loc) return
        this.translations[loc] = {
          id: t?.id ?? null,
          locale: loc,
          domanda: t?.domanda?.toString() || "",
          risposta: t?.risposta?.toString() || "",
          updated_at: t?.updated_at ?? null,
        }
      })

      this.renderList()
      this.showList()
    } catch {
      this.showErrorText("Impossibile caricare le traduzioni.")
    }
  }

  renderList() {
    this.listTarget.innerHTML = ""

    const options = this.localeOptions()
    if (options.length === 0) {
      const empty = document.createElement("div")
      empty.className = "list-group-item text-muted"
      empty.textContent = "Nessuna lingua configurata."
      this.listTarget.appendChild(empty)
      return
    }

    options.forEach(([label, code]) => {
      const normalized = this.normalizeLocale(code)
      const existing = this.translations?.[normalized] || null
      const hasTranslation = !!existing

      const item = document.createElement("div")
      item.className = "list-group-item d-flex justify-content-between align-items-center gap-3"

      const left = document.createElement("div")
      left.className = "d-flex flex-column"

      const titleRow = document.createElement("div")
      titleRow.className = "fw-semibold d-flex align-items-center gap-2 flex-wrap"

      const labelEl = document.createElement("span")
      labelEl.textContent = label

      const codeBadge = document.createElement("span")
      codeBadge.className = "badge text-bg-light"
      codeBadge.textContent = normalized.toUpperCase()

      titleRow.appendChild(labelEl)
      titleRow.appendChild(codeBadge)

      const subtitle = document.createElement("div")
      subtitle.className = "small text-muted"
      subtitle.textContent = hasTranslation ? "Tradotta" : "Non tradotta"

      left.appendChild(titleRow)
      left.appendChild(subtitle)

      const right = document.createElement("div")
      right.className = "d-flex align-items-center gap-2"

      const statusBadge = document.createElement("span")
      statusBadge.className = hasTranslation ? "badge text-bg-success" : "badge text-bg-secondary"
      statusBadge.textContent = hasTranslation ? "OK" : "Manca"

      const actionBtn = document.createElement("button")
      actionBtn.type = "button"
      actionBtn.className = hasTranslation ? "btn btn-sm btn-outline-primary" : "btn btn-sm btn-outline-success"
      actionBtn.innerHTML = hasTranslation
        ? '<i class="fas fa-edit me-1"></i>Modifica'
        : '<i class="fas fa-plus me-1"></i>Aggiungi'
      actionBtn.addEventListener("click", () => this.openEditor(code))

      right.appendChild(statusBadge)
      right.appendChild(actionBtn)

      item.appendChild(left)
      item.appendChild(right)
      this.listTarget.appendChild(item)
    })
  }

  openEditor(localeCode) {
    const code = this.normalizeLocale(localeCode)
    if (!code) return

    const label = this.labelForLocale(code)
    const existing = this.translations?.[code] || null

    this.editorLocaleTarget.value = code
    this.editorLocaleLabelTarget.textContent = label
    this.editorLocaleBadgeTarget.textContent = code.toUpperCase()

    this.domandaTarget.value = existing?.domanda?.toString() || this.baseDomanda || ""
    this.rispostaTarget.value = existing?.risposta?.toString() || this.baseRisposta || ""

    this.showEditor()
  }

  backToList() {
    this.showList()
  }

  async save() {
    const locale = this.normalizeLocale(this.editorLocaleTarget.value)
    const domanda = (this.domandaTarget.value || "").toString().trim()
    const risposta = (this.rispostaTarget.value || "").toString().trim()

    if (!locale) return this.showErrorText("Seleziona una lingua valida.")
    if (!domanda || !risposta) return this.showErrorText("Domanda e risposta sono obbligatorie.")

    this.hideError()

    const button = this.saveButtonTarget
    button.disabled = true
    button.dataset.originalText ||= button.innerHTML
    button.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Salvataggio...'

    try {
      const res = await fetch(`/admin/faqs/${this.faqId}/faq_translations`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          Accept: "application/json",
        },
        body: JSON.stringify({ faq_translation: { locale, domanda, risposta } }),
        credentials: "same-origin",
      })

      if (res.status === 401) {
        const data = await res.json().catch(() => null)
        window.location.href = data?.login_url || "/login"
        return
      }

      const data = await res.json().catch(() => null)
      if (!res.ok) return this.showErrors(data)

      this.closeAndRefresh()
    } catch {
      this.showErrorText("Salvataggio non riuscito.")
    } finally {
      button.disabled = false
      button.innerHTML = button.dataset.originalText
    }
  }

  reset() {
    this.faqId = null
    this.baseDomanda = ""
    this.baseRisposta = ""
    this.translations = {}

    if (this.hasBaseQuestionTarget) this.baseQuestionTarget.textContent = ""
    if (this.hasListTarget) this.listTarget.innerHTML = ""
    if (this.hasDomandaTarget) this.domandaTarget.value = ""
    if (this.hasRispostaTarget) this.rispostaTarget.value = ""
    if (this.hasEditorLocaleTarget) this.editorLocaleTarget.value = ""

    this.hideError()
    this.showList()
  }

  // ---- UI helpers ----

  showLoading() {
    if (!this.hasListTarget) return
    this.listTarget.innerHTML = ""

    const item = document.createElement("div")
    item.className = "list-group-item text-muted"
    item.textContent = "Caricamento..."
    this.listTarget.appendChild(item)
  }

  showList() {
    if (this.hasListSectionTarget) this.listSectionTarget.classList.remove("d-none")
    if (this.hasEditorSectionTarget) this.editorSectionTarget.classList.add("d-none")
    if (this.hasSaveButtonTarget) this.saveButtonTarget.classList.add("d-none")
  }

  showEditor() {
    if (this.hasListSectionTarget) this.listSectionTarget.classList.add("d-none")
    if (this.hasEditorSectionTarget) this.editorSectionTarget.classList.remove("d-none")
    if (this.hasSaveButtonTarget) this.saveButtonTarget.classList.remove("d-none")
  }

  showErrors(data) {
    const messages = Array.isArray(data?.messages) ? data.messages : []
    const text = messages.length ? messages.join("\n") : "Operazione non riuscita."
    this.showErrorText(text)
  }

  showErrorText(text) {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = text
    this.errorTarget.classList.remove("d-none")
  }

  hideError() {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = ""
    this.errorTarget.classList.add("d-none")
  }

  // ---- data helpers ----

  localeOptions() {
    const raw = Array.isArray(this.localesValue) ? this.localesValue : []
    const pairs = raw
      .map((pair) => {
        const label = (pair?.[0] || "").toString().trim()
        const code = this.normalizeLocale(pair?.[1])
        return [label, code]
      })
      .filter(([, code]) => code !== "")

    const seen = new Set()
    const deduped = []
    pairs.forEach(([label, code]) => {
      if (seen.has(code)) return
      seen.add(code)
      deduped.push([label || code.toUpperCase(), code])
    })

    return deduped
  }

  labelForLocale(code) {
    const normalized = this.normalizeLocale(code)
    const pairs = this.localeOptions()
    const found = pairs.find(([, c]) => c === normalized)
    return found?.[0] || normalized.toUpperCase()
  }

  normalizeLocale(raw) {
    return (raw || "").toString().trim().replaceAll("_", "-").toLowerCase()
  }

  csrfToken() {
    const meta = document.querySelector("meta[name='csrf-token']")
    return meta?.getAttribute("content") || ""
  }

  closeAndRefresh() {
    if (!this.modalEl) return this.refreshPage()

    this.modalEl.addEventListener(
      "hidden.bs.modal",
      () => {
        this.refreshPage()
      },
      { once: true }
    )

    try {
      this.modal?.hide()
    } catch {
      this.refreshPage()
    }
  }

  refreshPage() {
    window.location.reload()
  }
}
