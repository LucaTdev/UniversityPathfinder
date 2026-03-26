import { Controller } from "@hotwired/stimulus"

const MOBILE_BREAKPOINT = 1069.98

export default class extends Controller {
  static targets = ["menu", "toggle"]

  connect() {
    this.resetIfDesktop()
  }

  hideOnNavClick(event) {
    const link = event.target.closest("a.nav-link")
    if (!link || !this.isMobile()) return

    this.hide()
  }

  resetIfDesktop() {
    if (this.isMobile()) return

    this.hideImmediately()
  }

  hideImmediately() {
    if (!this.hasMenuTarget || !this.hasToggleTarget) return

    this.menuTarget.classList.remove("show", "collapsing")
    this.menuTarget.style.height = ""
    this.toggleTarget.setAttribute("aria-expanded", "false")
  }

  hide() {
    if (!this.hasMenuTarget || !this.hasToggleTarget) return

    const collapse = window.bootstrap?.Collapse?.getOrCreateInstance(this.menuTarget, { toggle: false })

    if (collapse) {
      collapse.hide()
    } else {
      this.hideImmediately()
    }
  }

  isMobile() {
    return window.innerWidth <= MOBILE_BREAKPOINT
  }
}
