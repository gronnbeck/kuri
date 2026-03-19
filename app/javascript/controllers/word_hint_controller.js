import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["word"]
  static values = {
    url:     { type: String, default: "/practice/word_hint" },
    display: { type: String, default: "japanese" }
  }

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

    this._showLoading(wordEl)

    try {
      const res = await fetch(`${this.urlValue}?word=${encodeURIComponent(word)}`)
      const data = await res.json()
      if (this._activeWord === wordEl) {
        this._show(wordEl, data[this.displayValue] || data.error || "?")
      }
    } catch {
      if (this._activeWord === wordEl) this._show(wordEl, "?")
    }
  }

  _showLoading(anchor) {
    this._hide()
    this._activeWord = anchor

    const tip = document.createElement("div")
    tip.className = "word-hint-tooltip word-hint-tooltip--loading"
    tip.innerHTML = '<span class="wh-dot">·</span><span class="wh-dot">·</span><span class="wh-dot">·</span>'
    document.body.appendChild(tip)
    this._tooltip = tip
    this._position(tip, anchor)
    anchor.classList.add("sp-word--active")
    setTimeout(() => document.addEventListener("click", this._dismissHandler), 0)
  }

  _show(anchor, text) {
    this._hide()
    this._activeWord = anchor

    const tip = document.createElement("div")
    tip.className = "word-hint-tooltip"
    tip.textContent = text
    document.body.appendChild(tip)
    this._tooltip = tip

    this._tooltip = tip
    this._position(tip, anchor)
    anchor.classList.add("sp-word--active")
    setTimeout(() => document.addEventListener("click", this._dismissHandler), 0)
  }

  _position(tip, anchor) {
    const rect = anchor.getBoundingClientRect()
    const tipRect = tip.getBoundingClientRect()
    let top = rect.bottom + window.scrollY + 6
    let left = rect.left + window.scrollX + rect.width / 2 - tipRect.width / 2
    left = Math.max(8, Math.min(left, window.innerWidth - tipRect.width - 8))
    tip.style.top = `${top}px`
    tip.style.left = `${left}px`
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
