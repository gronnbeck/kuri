import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["bar", "completed", "failed", "status", "viewLink"]
  static values  = { batchId: Number, complete: Boolean }

  connect() {
    if (this.completeValue) return

    this.subscription = consumer.subscriptions.create(
      { channel: "BatchChannel", batch_id: this.batchIdValue },
      { received: (data) => this.handleMessage(data) }
    )
  }

  disconnect() {
    this.subscription?.unsubscribe()
  }

  handleMessage(data) {
    if (data.type === "progress") {
      const done = data.completed + data.failed
      const pct  = data.total > 0 ? Math.round(done / data.total * 100) : 0
      this.barTarget.style.width           = pct + "%"
      this.completedTarget.textContent     = data.completed
      this.failedTarget.textContent        = data.failed
    } else if (data.type === "done") {
      this.statusTarget.textContent = "Completed"
      this.subscription?.unsubscribe()
      if (this.hasViewLinkTarget) this.viewLinkTarget.style.display = ""
    }
  }
}
