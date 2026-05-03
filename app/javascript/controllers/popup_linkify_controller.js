import { Controller } from "@hotwired/stimulus"

// Auto-linkifies URLs in Fomantic-UI popup content.
//
// Attach to a container element. It observes the DOM for popup elements
// that appear (Fomantic creates them dynamically) and converts bare URLs
// into clickable links.
//
// Usage (in layout):
//   <body data-controller="popup-linkify">

export default class extends Controller {
  connect() {
    this.observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        for (const node of mutation.addedNodes) {
          if (node.nodeType === 1 && node.classList?.contains("ui") && node.classList?.contains("popup")) {
            this._linkifyNode(node)
          }
        }
      }
    })
    this.observer.observe(document.body, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  _linkifyNode(node) {
    const content = node.querySelector(".content") || node
    const html = content.innerHTML
    const linkified = html.replace(/(https?:\/\/[^\s<]+)/g, '<a href="$1" target="_blank" rel="noopener noreferrer">$1</a>')
    if (linkified !== html) {
      content.innerHTML = linkified
    }
  }
}
