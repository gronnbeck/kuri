import { Controller } from "@hotwired/stimulus"

// Fetches fields for an Anki note by ID and lets the user pick one to
// populate a target textarea. Also keeps hidden noteId/fieldName inputs
// in sync so they carry through the Transform POST.
//
// Targets:
//   noteId      — input where the user types the note ID
//   fieldPicker — container that shows the field buttons (hidden until fetched)
//   source      — the textarea to populate
//   error       — element to show error messages
//   hiddenNoteId    — hidden input in the form (carries note ID through POST)
//   hiddenFieldName — hidden input in the form (carries field name through POST)
export default class extends Controller {
  static targets = ["noteId", "fieldPicker", "source", "error", "hiddenNoteId", "hiddenFieldName"]

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

      // Keep hidden note ID in sync
      if (this.hasHiddenNoteIdTarget) this.hiddenNoteIdTarget.value = id

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
          // highlight the active button
          this.fieldPickerTarget.querySelectorAll("button").forEach(b => b.classList.remove("button--active"))
          btn.classList.add("button--active")
        })
        this.fieldPickerTarget.appendChild(btn)
      })
    } catch (e) {
      this.errorTarget.textContent = "Network error — is Anki synced?"
      this.fieldPickerTarget.style.display = "none"
    }
  }
}
