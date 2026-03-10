import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title",
    "message",
    "inputGroup",
    "inputLabel",
    "input",
    "cancelButton",
    "confirmButton",
  ]

  static defaults = {
    alert: { title: "Avviso", label: "Chiudi", variant: "primary" },
    confirm: { title: "Conferma", label: "Conferma", variant: "danger" },
    prompt: { title: "Modifica", label: "Salva", variant: "primary" },
  }

  connect() {
    this.modalEl = document.getElementById("faqs-dialog-modal")
    this.pending = null

    if (this.modalEl && window.bootstrap?.Modal) {
      this.modal = window.bootstrap.Modal.getOrCreateInstance(this.modalEl, {
        backdrop: false,
      })
    }

    this.boundHidden = this.handleHidden.bind(this)
    this.boundBeforeCache = this.cleanupModalState.bind(this)
    this.modalEl?.addEventListener("hidden.bs.modal", this.boundHidden)
    document.addEventListener("turbo:before-cache", this.boundBeforeCache)

    window.FaqsDialog = this
    this.resetUI()
  }

  disconnect() {
    this.modalEl?.removeEventListener("hidden.bs.modal", this.boundHidden)
    document.removeEventListener("turbo:before-cache", this.boundBeforeCache)

    if (window.FaqsDialog === this) delete window.FaqsDialog
  }

  confirmForm(event) {
    event.preventDefault()

    const form = event.currentTarget.form || event.currentTarget.closest("form")
    if (!form) return

    this.confirm({
      title: event.params?.title || "Conferma",
      message: event.params?.message || "Procedere?",
      confirmLabel: event.params?.confirmLabel || "Conferma",
      confirmVariant: event.params?.confirmVariant || "primary",
    }).then((confirmed) => {
      if (!confirmed) return
      if (typeof form.requestSubmit === "function") form.requestSubmit()
      else form.submit()
    })
  }

  submitCurrent(event) {
    if (event) event.preventDefault()
    this.finish(true)
  }

  cancelCurrent(event) {
    if (event) event.preventDefault()
    this.finish(false)
  }

  alert(options = {}) {
    return this.open({ mode: "alert", ...options })
  }

  confirm(options = {}) {
    return this.open({ mode: "confirm", ...options })
  }

  prompt(options = {}) {
    return this.open({ mode: "prompt", ...options })
  }

  open(options = {}) {
    if (!this.modal) {
      return Promise.resolve(options.mode === "prompt" ? null : options.mode === "alert")
    }

    const mode = options.mode || "alert"
    const promptMode = mode === "prompt"
    const defaults = this.constructor.defaults[mode] || this.constructor.defaults.alert

    this.pending = { mode, resolve: null }
    this.titleTarget.textContent = options.title || defaults.title
    this.messageTarget.textContent = options.message || ""
    this.inputGroupTarget.classList.toggle("d-none", !promptMode)
    this.cancelButtonTarget.classList.toggle("d-none", mode === "alert")

    if (promptMode) {
      this.inputLabelTarget.textContent = options.inputLabel || "Valore"
      this.inputTarget.value = options.value || ""
      this.inputTarget.placeholder = options.placeholder || ""
    } else {
      this.inputTarget.value = ""
      this.inputTarget.placeholder = ""
    }

    this.confirmButtonTarget.textContent = options.confirmLabel || defaults.label
    this.confirmButtonTarget.className = `btn btn-${options.confirmVariant || defaults.variant}`

    this.prepareStacking()
    this.modal.show()
    requestAnimationFrame(() => {
      if (promptMode) this.inputTarget.focus()
    })

    return new Promise((resolve) => {
      this.pending.resolve = resolve
    })
  }

  handleHidden() {
    const pending = this.pending
    this.pending = null
    this.modalEl.style.removeProperty("z-index")
    this.removeOverlay()
    this.resetUI()
    this.restoreParentModalState()
    if (pending?.resolve) {
      pending.resolve(pending.value ?? (pending.mode === "prompt" ? null : pending.mode === "alert"))
    }
  }

  cleanupModalState() {
    this.pending = null
    this.modalEl.classList.remove("show")
    this.modalEl.style.display = "none"
    this.modalEl.style.removeProperty("z-index")
    this.modalEl.setAttribute("aria-hidden", "true")
    this.modalEl.removeAttribute("aria-modal")
    this.removeOverlay()
    this.restoreParentModalState()
  }

  resetUI() {
    this.inputGroupTarget.classList.add("d-none")
    this.inputLabelTarget.textContent = "Valore"
    this.inputTarget.value = ""
    this.inputTarget.placeholder = ""
    this.cancelButtonTarget.classList.remove("d-none")
    this.confirmButtonTarget.textContent = "Conferma"
    this.confirmButtonTarget.className = "btn btn-primary"
  }

  finish(confirmed) {
    if (!this.pending) return

    const { mode } = this.pending
    const value =
      mode === "prompt" ? (confirmed ? this.inputTarget.value.toString() : null) :
      mode === "alert" ? true :
      confirmed

    this.pending.value = value
    this.modal?.hide()
  }

  prepareStacking() {
    const openModals = Array.from(document.querySelectorAll(".modal.show")).filter((el) => el !== this.modalEl)
    const zIndex = 1060 + openModals.length * 20
    this.modalEl.style.zIndex = String(zIndex)
    this.showOverlay(zIndex - 10)
  }

  showOverlay(zIndex) {
    this.removeOverlay()

    const overlay = document.createElement("div")
    overlay.className = "faqs-dialog-overlay"
    overlay.style.position = "fixed"
    overlay.style.inset = "0"
    overlay.style.background = "rgba(0, 0, 0, 0.5)"
    overlay.style.zIndex = String(zIndex)

    document.body.appendChild(overlay)
    this.overlayEl = overlay
  }

  removeOverlay() {
    if (!this.overlayEl) return
    this.overlayEl.remove()
    this.overlayEl = null
  }

  restoreParentModalState() {
    if (document.querySelector(".modal.show")) {
      document.body.classList.add("modal-open")
      document.body.style.overflow = "hidden"
      return
    }

    document.body.classList.remove("modal-open")
    document.body.style.removeProperty("overflow")
    document.body.style.removeProperty("padding-right")
  }
}
