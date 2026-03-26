import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Cached Anki note type fields fetched from AnkiConnect
  ankiFields = null

  connect() {
    // Auto-fetch fields on load if note type is already set
    const noteType = this.element.querySelector("#note_type")?.value?.trim()
    if (noteType) this.loadAnkiFields(noteType)
  }

  async testConnection() {
    const url = this.element.querySelector("#url").value
    const status = this.element.querySelector("#connection-status")
    status.textContent = "Testing…"
    try {
      const res = await fetch(this.testConnectionPath + "?url=" + encodeURIComponent(url), { method: "POST", headers: { "X-CSRF-Token": this.csrfToken } })
      const data = await res.json()
      status.textContent = data.ok ? "✓ Connected" : "✗ " + data.error
    } catch {
      status.textContent = "✗ Request failed"
    }
  }

  async fetchDecks() {
    const url = this.element.querySelector("#url").value
    const list = this.element.querySelector("#decks-list")
    const field = this.element.querySelector("#deck_name")
    list.textContent = "Fetching…"
    try {
      const res = await fetch(this.fetchDecksPath + "?url=" + encodeURIComponent(url))
      const data = await res.json()
      if (data.error) { list.textContent = "✗ " + data.error; return }
      list.innerHTML = data.decks.map(d => `<a href="#" class="tag" data-deck="${d}">${d}</a>`).join(" ")
      list.querySelectorAll("[data-deck]").forEach(a => {
        a.addEventListener("click", e => { e.preventDefault(); field.value = a.dataset.deck; list.textContent = "" })
      })
    } catch {
      list.textContent = "✗ Request failed"
    }
  }

  async fetchNoteTypes() {
    const url = this.element.querySelector("#url").value
    const list = this.element.querySelector("#note-types-list")
    const field = this.element.querySelector("#note_type")
    list.textContent = "Fetching…"
    try {
      const res = await fetch(this.fetchNoteTypesPath + "?url=" + encodeURIComponent(url))
      const data = await res.json()
      if (data.error) { list.textContent = "✗ " + data.error; return }
      list.innerHTML = data.note_types.map(t => `<a href="#" class="tag" data-type="${t}">${t}</a>`).join(" ")
      list.querySelectorAll("[data-type]").forEach(a => {
        a.addEventListener("click", e => {
          e.preventDefault()
          field.value = a.dataset.type
          list.textContent = ""
          this.loadAnkiFields(a.dataset.type)
        })
      })
    } catch {
      list.textContent = "✗ Request failed"
    }
  }

  // Fetch note type fields and apply them to all mapping rows
  async loadAnkiFields(noteType) {
    const url = this.element.querySelector("#url")?.value
    try {
      const params = new URLSearchParams({ note_type: noteType })
      if (url) params.set("url", url)
      const res = await fetch(this.fetchFieldsPath + "?" + params)
      const data = await res.json()
      if (data.error || !data.fields) return
      this.ankiFields = data.fields
      this.applyFieldValidation()
    } catch {
      // AnkiConnect unreachable — leave inputs as-is
    }
  }

  // Validate all existing text inputs against known Anki fields
  applyFieldValidation() {
    if (!this.ankiFields) return
    this.element.querySelectorAll("[data-role='field-name']").forEach(input => {
      this.validateFieldInput(input)
      input.addEventListener("input", () => this.validateFieldInput(input), { once: false })
    })
  }

  validateFieldInput(input) {
    const value = input.value.trim()
    let hint = input.nextElementSibling?.classList.contains("field-name-hint")
      ? input.nextElementSibling
      : null

    if (!hint) {
      hint = document.createElement("span")
      hint.className = "field-name-hint"
      input.parentNode.insertBefore(hint, input.nextSibling)
    }

    if (!value) {
      hint.textContent = ""
    } else if (this.ankiFields.includes(value)) {
      hint.textContent = "✓"
      hint.className = "field-name-hint field-name-hint--ok"
    } else {
      hint.textContent = "✗ not in note type"
      hint.className = "field-name-hint field-name-hint--error"
    }
  }

  addMappingRow() {
    const container = this.element.querySelector("#field-mappings")
    // Remove the empty-state placeholder if present
    const empty = container.querySelector(".field-mappings-empty")
    if (empty) empty.remove()

    const sourceFields = ["request","request_reading","request_audio","response","response_reading","response_audio","context","difficulty","notes"]
    const row = document.createElement("div")
    row.className = "field-mapping-row"
    row.dataset.controller = "mapping-row"

    // If we have Anki fields cached, use a select; otherwise a text input
    const ankiFieldInput = this.ankiFields
      ? `<select class="form-select" data-role="field-name" data-action="change->mapping-row#updateNameFromSelect" data-mapping-row-target="ankiSelect">
           <option value="">— Anki field —</option>
           ${this.ankiFields.map(f => `<option value="${f}">${f}</option>`).join("")}
         </select>`
      : `<input type="text" class="form-input" placeholder="Anki field name"
                data-role="field-name" data-action="input->mapping-row#updateName">`

    row.innerHTML = `
      ${ankiFieldInput}
      <span> → </span>
      <select class="form-select" data-role="field-source" data-mapping-row-target="select" name="">
        <option value="">— source field —</option>
        ${sourceFields.map(f => `<option value="${f}">${f}</option>`).join("")}
      </select>
    `
    container.appendChild(row)
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  get testConnectionPath() { return "/settings/listen/conversations/test_connection" }
  get fetchDecksPath()     { return "/settings/listen/conversations/fetch_decks" }
  get fetchNoteTypesPath() { return "/settings/listen/conversations/fetch_note_types" }
  get fetchFieldsPath()    { return "/settings/listen/conversations/fetch_fields" }
}
