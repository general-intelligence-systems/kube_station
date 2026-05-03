DocType(:html)

Html {
  Head {
    Title { text "Kube Station" }

    Meta(name: "viewport", content: "width=device-width,initial-scale=1")

    CsrfMetaTags()
    CspMetaTag()
    ContentFor(:head) if content_for?(:head)

    StylesheetLink("stylesheets.css", "data-turbo-track": "reload")
    StylesheetLink("application", "data-turbo-track": "reload")

    text fui_javascript_tags
    JavascriptImportmap()
  }

  Body(data: { controller: "popup-linkify" }) {
    Container {
      text yield
    }

    Modal(turbo: true, blurring: true)
  }
}
