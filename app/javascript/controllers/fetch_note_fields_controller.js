import { Controller } from "@hotwired/stimulus"

// Fetches fields for an Anki note by ID and renders two pickers:
//   - source picker: non-empty fields → clicking populates the source textarea
//   - target picker: all fields → clicking sets the save destination
//
// Targets:
//   noteId            — input where the user types the note ID
//   fieldPicker       — container for source field buttons
//   targetFieldPicker — container for target field buttons (in save section)
//   targetFieldLabel  — span showing the currently selected target field name
//   source            — the textarea to populate with source value
//   error             — element to show error messages
//   hiddenNoteId          — hidden input carrying note ID through Transform POST
//   hiddenFieldName       — hidden input carrying source field name through Transform POST
//   hiddenSaveNoteId      — hidden input carrying note ID in the save form
//   hiddenTargetFieldName — hidden input carrying target field name in the save form
export default class extends Controller {
  static targets = [
    "noteId", "fieldPicker", "targetFieldPicker", "targetFieldLabel",
    "source", "error",
    "hiddenNoteId", "hiddenFieldName",
    "hiddenSaveNoteId", "hiddenTargetFieldName"
  ]

  async fetch() {
    const id = this.noteIdTarget.value.trim()
    if (!id) return

    this.fieldPickerTarget.innerHTML = "<span style='color:#888;font-size:0.85rem'>Loading…</span>"
    this.fieldPickerTarget.style.display = ""
    this.errorTarget.textContent = ""

    try {
      const res = await window.fetch(`/notes/${id}/fields`)
      const data = await res.json()

      if (!res.ok) {
        this.errorTarget.textContent = data.error || "Failed to fetch note."
        this.fieldPickerTarget.style.display = "none"
        return
      }

      if (this.hasHiddenNoteIdTarget) this.hiddenNoteIdTarget.value = id
      if (this.hasHiddenSaveNoteIdTarget) this.hiddenSaveNoteIdTarget.value = id

      // Source picker — only non-empty fields
      this.fieldPickerTarget.innerHTML = ""
      Object.entries(data.fields).forEach(([name, value]) => {
        if (!value) return
        const btn = document.createElement("button")
        btn.type = "button"
        btn.className = "button button--small button--ghost"
        btn.textContent = name
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
        this.targetFieldPickerTarget.style.display = ""
        Object.entries(data.fields).forEach(([name, _value]) => {
          const btn = document.createElement("button")
          btn.type = "button"
          btn.className = "button button--small button--ghost"
          btn.textContent = name
          btn.addEventListener("click", () => {
            if (this.hasHiddenTargetFieldNameTarget) this.hiddenTargetFieldNameTarget.value = name
            if (this.hasTargetFieldLabelTarget) this.targetFieldLabelTarget.textContent = `→ ${name}`
            // enable the save button
            const saveBtn = this.targetFieldPickerTarget.closest(".enrichment-save-section")?.querySelector("button[type='submit']")
            if (saveBtn) saveBtn.disabled = false
            this.targetFieldPickerTarget.querySelectorAll("button").forEach(b => b.classList.remove("button--active"))
            btn.classList.add("button--active")
          })
          this.targetFieldPickerTarget.appendChild(btn)
        })
      }
    } catch (e) {
      this.errorTarget.textContent = "Network error — is Anki synced?"
      this.fieldPickerTarget.style.display = "none"
    }
  }
}
