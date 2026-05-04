class ApplicationController < ActionController::Base
  ActionView::Base.default_form_builder = Kube::Station::FomanticFormBuilder

  before_action :set_page_title

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

    def set_page_title
      @page_title = "#{controller_name.humanize} - #{action_name.humanize}"
    end
end
