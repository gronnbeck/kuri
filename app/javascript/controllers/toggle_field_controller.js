import { Controller } from "@hotwired/stimulus"

// Shows a target field when a select matches a specific value.
//
// Usage:
//   data-controller="toggle-field"
//   data-toggle-field-show-value="custom"        ← value that triggers show
//   On the <select>: data-toggle-field-target="select" data-action="change->toggle-field#toggle"
//   On the field to show/hide: data-toggle-field-target="field"
export default class extends Controller {
  static targets = ["select", "field"]
  static values  = { show: String }

  connect() {
    this.toggle()
  }

  toggle() {
    const visible = this.selectTarget.value === this.showValue
    this.fieldTargets.forEach(el => el.style.display = visible ? "" : "none")
  }
}
