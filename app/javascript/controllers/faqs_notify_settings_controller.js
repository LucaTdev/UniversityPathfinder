import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "saveButton"]
  static values = {
    updateUrl: String,
  }

  async save() {
    const enabled = !!this.checkboxTarget.checked
    const button = this.saveButtonTarget

    button.disabled = true
    button.dataset.originalText ||= button.textContent
    button.textContent = "Salvataggio..."

    try {
      const res = await fetch(this.updateUrlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken(),
          Accept: "application/json",
        },
        body: JSON.stringify({ enabled }),
        credentials: "same-origin",
      })

      if (res.status === 401) {
        const data = await res.json().catch(() => null)
        window.location.href = data?.login_url || "/login"
        return
      }

      if (!res.ok) {
        const data = await res.json().catch(() => null)
        const messages = Array.isArray(data?.messages) ? data.messages : []
        const text = messages.length ? messages.join("\n") : "Impossibile salvare le impostazioni."
        this.dialog()?.alert({
          title: "Impostazioni notifiche",
          message: text,
          confirmLabel: "Chiudi",
          confirmVariant: "primary",
        })
        return
      }
    } catch {
      this.dialog()?.alert({
        title: "Impostazioni notifiche",
        message: "Impossibile salvare le impostazioni.",
        confirmLabel: "Chiudi",
        confirmVariant: "primary",
      })
    } finally {
      button.disabled = false
      button.textContent = button.dataset.originalText
    }
  }

  csrfToken() {
    const meta = document.querySelector("meta[name='csrf-token']")
    return meta?.getAttribute("content") || ""
  }

  dialog() {
    return window.FaqsDialog || null
  }
}
