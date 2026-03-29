import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["difficultyGroup"]

  toggleDifficulty(event) {
    const hasVerb = event.target.value.trim().length > 0
    this.difficultyGroupTargets.forEach(el => {
      el.style.display = hasVerb ? "none" : ""
    })
  }
}
