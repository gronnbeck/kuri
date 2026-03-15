import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["word"]

  connect() {
    this._tooltip = null
    this._dismissHandler = (e) => {
      if (this._tooltip && !this._tooltip.contains(e.target)) {
        this._hide()
      }
    }
  }

  disconnect() {
    this._hide()
  }

  async lookup(event) {
    const wordEl = event.currentTarget
    const word = wordEl.dataset.word
    if (!word) return

    // If clicking the same word while tooltip is open, close it
    if (this._activeWord === wordEl && this._tooltip) {
      this._hide()
      return
    }

    this._activeWord = wordEl
    this._show(wordEl, "…")

    try {
      const res = await fetch(`/practice/word_hint?word=${encodeURIComponent(word)}`)
      const data = await res.json()
      if (this._activeWord === wordEl) {
        this._show(wordEl, data.japanese || data.error || "?")
      }
    } catch {
      if (this._activeWord === wordEl) this._show(wordEl, "?")
    }
  }

  _show(anchor, text) {
    this._hide()

    const tip = document.createElement("div")
    tip.className = "word-hint-tooltip"
    tip.textContent = text
    document.body.appendChild(tip)
    this._tooltip = tip

    const rect = anchor.getBoundingClientRect()
    const tipRect = tip.getBoundingClientRect()
    let top = rect.bottom + window.scrollY + 6
    let left = rect.left + window.scrollX + rect.width / 2 - tipRect.width / 2

    // Keep within viewport
    left = Math.max(8, Math.min(left, window.innerWidth - tipRect.width - 8))

    tip.style.top = `${top}px`
    tip.style.left = `${left}px`

    anchor.classList.add("sp-word--active")
    // Defer so the current click event doesn't immediately trigger dismiss
    setTimeout(() => document.addEventListener("click", this._dismissHandler), 0)
  }

  _hide() {
    if (this._tooltip) {
      this._tooltip.remove()
      this._tooltip = null
    }
    if (this._activeWord) {
      this._activeWord.classList.remove("sp-word--active")
      this._activeWord = null
    }
    document.removeEventListener("click", this._dismissHandler)
  }
}
