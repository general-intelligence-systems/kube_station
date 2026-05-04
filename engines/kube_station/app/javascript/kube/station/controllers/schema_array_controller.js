import { Controller } from "@hotwired/stimulus"

// Handles add/remove of dynamic array rows in schema-driven forms.
//
// Targets:
//   list     - container for visible items
//   item     - individual array row (removed on "remove" action)
//   template - a hidden <template> element containing a blank row to clone
//
// Actions:
//   add    - clones the template and appends to the list, focuses first input
//   remove - removes the clicked item's row

export default class extends Controller {
  static targets = ["list", "item", "template"]

  add() {
    const list = this.listTarget

    if (this.hasTemplateTarget) {
      const clone = this.templateTarget.content.cloneNode(true)
      list.appendChild(clone)
    } else if (this.itemTargets.length > 0) {
      const last = this.itemTargets[this.itemTargets.length - 1]
      const clone = last.cloneNode(true)
      clone.querySelectorAll("input").forEach(input => { input.value = "" })
      list.appendChild(clone)
    }

    // Focus the first input in the newly added row
    const items = this.itemTargets
    if (items.length > 0) {
      const newRow = items[items.length - 1]
      const firstInput = newRow.querySelector("input")
      if (firstInput) firstInput.focus()
    }
  }

  remove(event) {
    const item = event.target.closest("[data-schema-array-target='item']")
    if (item) {
      item.remove()
    }
  }
}
