DocType(:html)

Html {
  Head {
    Title { text @page_title }

    Meta(name: "viewport", content: "width=device-width,initial-scale=1")

    CsrfMetaTags()
    CspMetaTag()
    ContentFor(:head) if content_for?(:head)

    StylesheetLink("stylesheets.css", "data-turbo-track": "reload")
    StylesheetLink("application", "data-turbo-track": "reload")

    text fui_javascript_tags
    JavascriptImportmap()

    Style "
      body {
        height: 100%;
        background-color: #f0f0f0;
        margin: 0;
        padding: 0;
        overflow-x: hidden;
      }

      #site-content {
        flex-grow: 1;
        overflow: hidden;
      }

      #graph-wrapper {
        position: relative;
        border: 1px solid #ffffff;
        background-color: #ffffff;
        border-radius: 15px;
        margin: 7px;
      }

      #graph-wrapper::after {
        content: '';
        position: absolute;
        inset: 0;
        box-shadow: inset 0px 0px 4px 1px rgb(0 0 0 / 19%);
        pointer-events: none;
        border-radius: inherit;
        border: 1px solid rgb(151 151 151 / 79%);
      }

      #site-content-scroll {
        height: 100%;
        overflow-y: auto;
      }
    "
  }

  Body(data: { controller: "popup-linkify" }) {
    Wrapper(id: "site-wrapper") {
      Wrapper(id: "site-content") {
        Wrapper(id: "site-content-scroll") {
          text yield
        }
      }
    }

    Modal(turbo: true, blurring: true)
  }
}
