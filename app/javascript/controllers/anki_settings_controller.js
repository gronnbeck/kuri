import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
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
        a.addEventListener("click", e => { e.preventDefault(); field.value = a.dataset.type; list.textContent = "" })
      })
    } catch {
      list.textContent = "✗ Request failed"
    }
  }

  addMappingRow() {
    const container = this.element.querySelector("#field-mappings")
    const row = document.createElement("div")
    row.className = "field-mapping-row"
    row.innerHTML = `
      <input type="text" class="form-input" placeholder="Anki field name" data-role="field-name" data-action="input->anki-settings#updateRowName">
      <span> → </span>
      <select class="form-select" data-role="field-source" name="">
        <option value="">— select —</option>
        ${["request","response","context","difficulty","notes"].map(f => `<option value="${f}">${f}</option>`).join("")}
      </select>
    `
    row.querySelector("[data-role='field-name']").addEventListener("input", e => {
      row.querySelector("[data-role='field-source']").name = `anki_conversation_setting[field_mappings][${e.target.value}]`
    })
    container.appendChild(row)
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }

  get testConnectionPath() {
    return "/settings/listen/conversations/test_connection"
  }

  get fetchDecksPath() {
    return "/settings/listen/conversations/fetch_decks"
  }

  get fetchNoteTypesPath() {
    return "/settings/listen/conversations/fetch_note_types"
  }
}
