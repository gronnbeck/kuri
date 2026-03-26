import { Controller } from "@hotwired/stimulus"

// Keeps the source-select[name] in sync with the Anki field name (text or select).
export default class extends Controller {
  static targets = ["select", "ankiSelect"]

  // Called when Anki field name is a text input
  updateName(event) {
    this._setName(event.target.value.trim())
  }

  // Called when Anki field name is a <select>
  updateNameFromSelect(event) {
    this._setName(event.target.value.trim())
  }

  _setName(key) {
    this.selectTarget.name = key
      ? `anki_conversation_setting[field_mappings][${key}]`
      : ""
  }
}
