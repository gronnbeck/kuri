import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["enriched", "failed", "bar", "status"]
  static values  = { batchId: Number, complete: Boolean }

  connect() {
    if (this.completeValue) return

    this.subscription = consumer.subscriptions.create(
      { channel: "NoteEnrichmentChannel", batch_id: this.batchIdValue },
      {
        received: (data) => {
          if (data.type === "progress") {
            if (this.hasEnrichedTarget) this.enrichedTarget.textContent = data.enriched
            if (this.hasFailedTarget)   this.failedTarget.textContent   = data.failed
            if (this.hasBarTarget) {
              const pct = data.total > 0 ? Math.round((data.enriched + data.failed) / data.total * 100) : 0
              this.barTarget.style.width = pct + "%"
            }
          }
          if (data.type === "ready_for_review" || data.type === "done") {
            this.subscription?.unsubscribe()
            window.location.reload()
          }
        }
      }
    )
  }

  disconnect() {
    this.subscription?.unsubscribe()
  }
}
