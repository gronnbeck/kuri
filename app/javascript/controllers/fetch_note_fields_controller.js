import { Controller } from "@hotwired/stimulus"

// Fetches fields for an Anki note by ID and renders two pickers:
//   - source picker: non-empty fields → clicking populates the source textarea
//   - target picker: all fields → clicking sets the save destination
//
// Targets:
//   noteId            — input where the user types the note ID
//   pickersWrapper    — wraps both pickers; shown after a successful fetch
//   fieldPicker       — container for source field buttons
//   targetFieldPicker — container for target field buttons
//   targetFieldLabel  — span showing the currently selected target field name
//   source            — the textarea to populate with source value
//   error             — element to show error messages
//   hiddenNoteId          — hidden input carrying note ID through Transform POST
//   hiddenFieldName       — hidden input carrying source field name through Transform POST
//   hiddenTargetFieldName — hidden input carrying target field name through Transform POST
//   hiddenSaveNoteId      — hidden input carrying note ID in the save form
//   hiddenSaveFieldName   — hidden input carrying target field name in the save form
export default class extends Controller {
  static targets = [
    "noteId", "pickersWrapper", "fieldPicker", "targetFieldPicker", "targetFieldLabel",
    "source", "error",
    "hiddenNoteId", "hiddenFieldName", "hiddenTargetFieldName",
    "hiddenSaveNoteId", "hiddenSaveFieldName"
  ]

  connect() {
    // Auto-fetch fields if the page was rendered with a note ID already filled
    // (e.g. after a Transform POST carries the note ID through).
    if (this.hasNoteIdTarget && this.noteIdTarget.value.trim()) {
      this.fetch()
    }
  }

  async fetch() {
    const id = this.noteIdTarget.value.trim()
    if (!id) return

    this.errorTarget.textContent = ""

    try {
      const res = await window.fetch(`/notes/${id}/fields`)
      const data = await res.json()

      if (!res.ok) {
        this.errorTarget.textContent = data.error || "Failed to fetch note."
        if (this.hasPickersWrapperTarget) this.pickersWrapperTarget.style.display = "none"
        return
      }

      if (this.hasHiddenNoteIdTarget) this.hiddenNoteIdTarget.value = id
      if (this.hasHiddenSaveNoteIdTarget) this.hiddenSaveNoteIdTarget.value = id

      // Show the pickers wrapper
      if (this.hasPickersWrapperTarget) this.pickersWrapperTarget.style.display = ""

      // Source picker — only non-empty fields
      this.fieldPickerTarget.innerHTML = ""
      // Pre-select the field that was active when the page loaded (if any)
      const preselectedSource = this.hasHiddenFieldNameTarget ? this.hiddenFieldNameTarget.value : ""
      Object.entries(data.fields).forEach(([name, value]) => {
        if (!value) return
        const btn = document.createElement("button")
        btn.type = "button"
        btn.className = "button button--small button--ghost"
        btn.textContent = name
        if (name === preselectedSource) btn.classList.add("button--active")
        btn.addEventListener("click", () => {
          this.sourceTarget.value = value
          if (this.hasHiddenFieldNameTarget) this.hiddenFieldNameTarget.value = name
          this.fieldPickerTarget.querySelectorAll("button").forEach(b => b.classList.remove("button--active"))
          btn.classList.add("button--active")
        })
        this.fieldPickerTarget.appendChild(btn)
      })

      // Target picker — all fields (the destination for the enriched result)
      if (this.hasTargetFieldPickerTarget) {
        this.targetFieldPickerTarget.innerHTML = ""
        const preselectedTarget = this.hasHiddenTargetFieldNameTarget ? this.hiddenTargetFieldNameTarget.value : ""
        Object.entries(data.fields).forEach(([name, _value]) => {
          const btn = document.createElement("button")
          btn.type = "button"
          btn.className = "button button--small button--ghost"
          btn.textContent = name
          if (name === preselectedTarget) btn.classList.add("button--active")
          btn.addEventListener("click", () => {
            if (this.hasHiddenTargetFieldNameTarget) this.hiddenTargetFieldNameTarget.value = name
            if (this.hasHiddenSaveFieldNameTarget) this.hiddenSaveFieldNameTarget.value = name
            if (this.hasTargetFieldLabelTarget) this.targetFieldLabelTarget.textContent = `→ ${name}`
            // enable the save button
            const saveBtn = this.element.querySelector(".enrichment-save-section button[type='submit']")
            if (saveBtn) saveBtn.disabled = false
            this.targetFieldPickerTarget.querySelectorAll("button").forEach(b => b.classList.remove("button--active"))
            btn.classList.add("button--active")
          })
          this.targetFieldPickerTarget.appendChild(btn)
        })
      }
    } catch (e) {
      this.errorTarget.textContent = "Network error — is Anki synced?"
      if (this.hasPickersWrapperTarget) this.pickersWrapperTarget.style.display = "none"
    }
  }
}
