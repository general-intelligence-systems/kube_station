# frozen_string_literal: true

# FomanticFormBuilder
#
# A Rails FormBuilder wrapping every helper in Fomantic-UI markup.
#
# Usage in a view:
#
#   <%= form_with model: @user, builder: FomanticFormBuilder do |f| %>
#     <%= f.text_field :name %>
#     <%= f.email_field :email, required: true %>
#     <%= f.select :role, [['Admin', 'admin'], ['User', 'user']], dropdown: true %>
#     <%= f.check_box :terms, label: 'I agree to the Terms and Conditions' %>
#     <%= f.fields_group(equal_width: true) do %>
#       <%= f.text_field :first_name %>
#       <%= f.text_field :last_name %>
#     <% end %>
#     <%= f.submit 'Save', color: 'green' %>
#   <% end %>
#
# Field options (shared across all helpers):
#   label:        String  – override label text (nil to suppress label)
#   required:     Boolean – adds "required" class and asterisk
#   disabled:     Boolean – adds "disabled" class
#   readonly:     Boolean – adds "read-only" class
#   inline:       Boolean – label sits beside the input
#   width:        String  – Fomantic grid column word, e.g. "six", "three"
#   error:        String  – error message; adds "error" class + inline message
#   warning:      String  – warning message; adds "warning" class + inline message
#   hint:         String  – rendered as a small grey note beneath the input
#   field_class:  String  – extra classes on the wrapping .field div
#   input_class:  String  – extra classes on the input element itself
#
class FomanticFormBuilder < ActionView::Helpers::FormBuilder
  COLUMN_WORDS = %w[
    one two three four five six seven eight nine ten
    eleven twelve thirteen fourteen fifteen sixteen
  ].freeze

  # ──────────────────────────────────────────────────────────────────────────
  # Text-like inputs
  # ──────────────────────────────────────────────────────────────────────────

  %i[
    text_field email_field password_field
    number_field url_field telephone_field phone_field
    search_field color_field date_field datetime_local_field
    month_field week_field time_field range_field
  ].each do |method_name|
    define_method(method_name) do |attribute, options = {}|
      fomantic_field(attribute, options) do |attr, opts|
        opts[:class] = class_names("", opts.delete(:input_class))
        super(attr, opts)
      end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Text area
  # ──────────────────────────────────────────────────────────────────────────

  def text_area(attribute, options = {})
    transparent = options.delete(:transparent)
    fomantic_field(attribute, options) do |attr, opts|
      input_class = class_names(("transparent" if transparent), opts.delete(:input_class))
      opts[:class] = input_class.presence
      super(attr, opts)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Emoji picker
  # ──────────────────────────────────────────────────────────────────────────

  def emoji_field(attribute, options = {})
    fomantic_field(attribute, options) do |attr, opts|
      current = object&.public_send(attr) rescue nil
      name = object_name ? "#{object_name}[#{attr}]" : attr.to_s

      @template.tag.div(data: { controller: "fui-emoji-picker" }) {
        @template.safe_join([
          @template.hidden_field_tag(name, current, data: { fui_emoji_picker_target: "input" }),
          @template.tag.button(
            type: "button",
            class: "ui basic button",
            data: { fui_emoji_picker_target: "preview", action: "click->fui-emoji-picker#toggle" }
          ) { (current.presence || "Pick emoji").html_safe },
          @template.tag.div(
            style: "display:none; position:absolute; z-index:1000;",
            data: { fui_emoji_picker_target: "dropdown" }
          )
        ])
      }
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Select / Dropdown
  # ──────────────────────────────────────────────────────────────────────────

  def select(attribute, choices = nil, options = {}, html_options = {}, &block)
    use_dropdown = options.delete(:dropdown)
    fomantic_field(attribute, options) do |attr, opts|
      merged_html = html_options.merge(class: class_names(html_options[:class], opts.delete(:input_class)))
      raw_select  = super(attr, choices, opts, merged_html, &block)

      use_dropdown ? dropdown_wrap(raw_select) : raw_select
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Check box
  # ──────────────────────────────────────────────────────────────────────────

  def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
    label_text = options.delete(:label) { label_for(attribute) }
    kind       = options.delete(:kind) { :checkbox } # :checkbox | :slider | :toggle

    fomantic_field(attribute, options.merge(suppress_label: true)) do |attr, opts|
      opts.delete(:input_class)
      checkbox_html = super(attr, opts, checked_value, unchecked_value)
      checkbox_ui(checkbox_html, label_text, kind)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Radio button
  # ──────────────────────────────────────────────────────────────────────────

  def radio_button(attribute, value, options = {})
    label_text = options.delete(:label) { value.to_s.humanize }

    fomantic_field(attribute, options.merge(suppress_label: true)) do |attr, opts|
      opts.delete(:input_class)
      radio_html = super(attr, value, opts)
      checkbox_ui(radio_html, label_text, :radio)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # File field
  # ──────────────────────────────────────────────────────────────────────────

  def file_field(attribute, options = {})
    fomantic_field(attribute, options) do |attr, opts|
      opts.delete(:input_class)
      super(attr, opts)
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Hidden field (no wrapper)
  # ──────────────────────────────────────────────────────────────────────────

  def hidden_field(attribute, options = {})
    super(attribute, options)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Submit button
  # ──────────────────────────────────────────────────────────────────────────

  def submit(value = nil, options = {})
    color   = options.delete(:color)
    basic   = options.delete(:basic)
    inverted = options.delete(:inverted)
    size    = options.delete(:size)
    icon    = options.delete(:icon)

    button_class = class_names(
      "ui", "button",
      color,
      size,
      ("basic" if basic),
      ("inverted" if inverted),
      options.delete(:class)
    )
    options[:class] = button_class

    icon_html = icon ? @template.tag.i(class: "#{icon} icon") : "".html_safe
    icon_html + super(value, options)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Label override — produces a plain <label> (called internally too)
  # ──────────────────────────────────────────────────────────────────────────

  def label(attribute, text = nil, options = {}, &block)
    super(attribute, text, options, &block)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # fields_group — wraps children in <div class="fields ...">
  #
  # Options:
  #   equal_width: Boolean – adds "equal width"
  #   inline:      Boolean – adds "inline"
  #   count:       Integer – "N fields" (evenly divided)
  # ──────────────────────────────────────────────────────────────────────────

  def fields_group(options = {}, &block)
    equal_width = options.delete(:equal_width)
    inline      = options.delete(:inline)
    count       = options.delete(:count)
    extra       = options.delete(:class)

    count_word = COLUMN_WORDS[count.to_i - 1] if count

    css = class_names(
      count_word,
      "fields",
      ("equal width" if equal_width),
      ("inline" if inline),
      extra
    )

    @template.tag.div(class: css, &block)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Form-level message helpers
  # ──────────────────────────────────────────────────────────────────────────

  def error_message(header, messages = [])
    form_message("error", header, messages)
  end

  def success_message(header, body = nil)
    form_message("success", header, [], body)
  end

  def warning_message(header, messages = [])
    form_message("warning", header, messages)
  end

  def info_message(header, messages = [])
    form_message("info", header, messages)
  end

  private

  # ── Core field wrapper ─────────────────────────────────────────────────────

  def fomantic_field(attribute, options, &block)
    required       = options.delete(:required)
    disabled       = options.delete(:disabled)
    readonly_opt   = options.delete(:readonly)
    inline         = options.delete(:inline)
    width          = options.delete(:width)
    error_msg      = options.delete(:error)
    warning_msg    = options.delete(:warning)
    hint           = options.delete(:hint)
    field_class    = options.delete(:field_class)
    suppress_label = options.delete(:suppress_label)
    custom_label   = options.delete(:label)

    has_error   = error_msg.present?   || object_has_error?(attribute)
    has_warning = warning_msg.present?

    div_class = class_names(
      width,
      "field",
      ("required"  if required),
      ("disabled"  if disabled),
      ("read-only" if readonly_opt),
      ("inline"    if inline),
      ("error"     if has_error),
      ("warning"   if has_warning),
      field_class
    )

    label_html = unless suppress_label
      text = custom_label.nil? ? label_for(attribute) : custom_label
      text ? label(attribute, text) : nil
    end

    input_html = block.call(attribute, options)

    note_html  = inline_note(error_msg || (has_error && first_error(attribute)), "red")
    note_html  = inline_note(warning_msg, "orange") if note_html.blank? && has_warning
    note_html  = inline_note(hint, "grey")          if note_html.blank? && hint

    @template.tag.div(class: div_class) do
      safe_join([ label_html, input_html, note_html ].compact)
    end
  end

  # ── Checkbox / Radio UI shell ──────────────────────────────────────────────

  def checkbox_ui(input_html, label_text, kind)
    modifier = { radio: "radio", slider: "slider", toggle: "toggle" }[kind]
    css      = class_names("ui", modifier, "checkbox")

    @template.tag.div(class: css) do
      safe_join([ input_html, @template.tag.label(label_text.is_a?(String) ? label_text : nil) ])
    end
  end

  # ── Dropdown wrapper ───────────────────────────────────────────────────────

  def dropdown_wrap(select_html)
    @template.tag.div(class: "ui selection dropdown") do
      safe_join([
        @template.tag.i(class: "dropdown icon"),
        select_html
      ])
    end
  end

  # ── Form-level messages ────────────────────────────────────────────────────

  def form_message(type, header, messages = [], body = nil)
    list_html = messages.any? ? @template.tag.ul(class: "list") {
      safe_join(messages.map { |m| @template.tag.li(m) })
    } : nil

    body_html = body ? @template.tag.p(body) : nil

    @template.tag.div(class: "ui #{type} message") do
      safe_join([
        @template.tag.div(class: "header") { header },
        list_html,
        body_html
      ].compact)
    end
  end

  # ── Inline note beneath input ──────────────────────────────────────────────

  def inline_note(text, color = nil)
    return nil if text.blank?

    @template.tag.small(class: class_names("ui", color, "text")) { text }
  end

  # ── Humanise attribute name for label ─────────────────────────────────────

  def label_for(attribute)
    attr_str = attribute.to_s.delete_suffix("_id")
    if object && object.class.respond_to?(:human_attribute_name)
      object.class.human_attribute_name(attr_str)
    else
      attr_str.humanize
    end
  end

  # ── ActiveModel error introspection ───────────────────────────────────────

  def object_has_error?(attribute)
    object.respond_to?(:errors) && object.errors[attribute].any?
  end

  def first_error(attribute)
    object.errors[attribute].first if object.respond_to?(:errors)
  end

  # ── Safe join delegated to template ───────────────────────────────────────

  def safe_join(parts)
    @template.safe_join(parts)
  end

  # ── class_names helper (Rails 6.1+ ships this) ────────────────────────────

  def class_names(*args)
    args.flatten.compact.reject { |v| v == false || v.to_s.strip.empty? }.join(" ")
  end
end

# ─────────────────────────────────────────────────────────────────────────────
# Usage examples (views)
# ─────────────────────────────────────────────────────────────────────────────

# ── 1. Basic user registration form ──────────────────────────────────────────
#
# <%= form_with model: @user, builder: FomanticFormBuilder, class: "ui form" do |f| %>
#
#   <%# grouped equal-width row %>
#   <%= f.fields_group(equal_width: true) do %>
#     <%= f.text_field  :first_name, required: true %>
#     <%= f.text_field  :last_name,  required: true %>
#   <% end %>
#
#   <%= f.email_field    :email,    required: true %>
#   <%= f.password_field :password, required: true,
#                        hint: "Minimum 8 characters" %>
#
#   <%# Native select styled by Fomantic %>
#   <%= f.select :role, [["Admin", "admin"], ["Member", "member"]],
#                { prompt: "Select a role" } %>
#
#   <%# Fomantic dropdown widget (adds JS .dropdown() wrapper) %>
#   <%= f.select :country, country_options,
#                { dropdown: true, required: true } %>
#
#   <%= f.check_box :terms,
#                   label:    "I agree to the Terms and Conditions",
#                   required: true %>
#
#   <%# Error/success messages from model %>
#   <%= f.error_message "We had some issues",
#                       @user.errors.full_messages if @user.errors.any? %>
#
#   <%= f.submit "Sign up", color: "green" %>
# <% end %>


# ── 2. Inline field (label beside input) ─────────────────────────────────────
#
# <%= f.text_field :phone, label: "Phone Number", inline: true,
#                           width: "eight" %>


# ── 3. Width-constrained fields ───────────────────────────────────────────────
#
# <%= f.fields_group do %>
#   <%= f.text_field :first_name, width: "six"  %>
#   <%= f.text_field :middle,     width: "three" %>
#   <%= f.text_field :last_name,  width: "seven" %>
# <% end %>


# ── 4. Checkbox kinds ─────────────────────────────────────────────────────────
#
# <%= f.check_box :notifications, label: "Enable notifications", kind: :toggle %>
# <%= f.check_box :public,        label: "Publicly visible",     kind: :slider %>


# ── 5. Radio group ────────────────────────────────────────────────────────────
#
# <%= f.fields_group do %>
#   <%= f.radio_button :plan, "basic",   label: "Basic"   %>
#   <%= f.radio_button :plan, "pro",     label: "Pro"     %>
#   <%= f.radio_button :plan, "enterprise", label: "Enterprise" %>
# <% end %>


# ── 6. Textarea ───────────────────────────────────────────────────────────────
#
# <%= f.text_area :bio,         rows: 4 %>
# <%= f.text_area :description, rows: 2, transparent: true %>


# ── 7. Form-level state messages ──────────────────────────────────────────────
#
# <%= f.error_message   "Action Forbidden", ["Email already registered"] %>
# <%= f.success_message "All done!",        "Your profile has been updated." %>
# <%= f.warning_message "Heads up",         ["Please verify your email"] %>
# <%= f.info_message    "Password rules",   ["Must be at least 8 characters"] %>


# ── 8. Submit variations ──────────────────────────────────────────────────────
#
# <%= f.submit "Save",   color: "blue"  %>
# <%= f.submit "Delete", color: "red",   basic: true %>
# <%= f.submit "Go",     color: "green", size: "large", icon: "checkmark" %>


# ── 9. Opt-in per form (when default builder is not set) ──────────────────────
#
# <%= form_with model: @post, builder: FomanticFormBuilder, class: "ui form" do |f| %>
#   ...
# <% end %>


# ─────────────────────────────────────────────────────────────────────────────
# JavaScript initialisation (application.js or a Stimulus controller)
# ─────────────────────────────────────────────────────────────────────────────
#
# // Initialise all Fomantic dropdowns on the page
# document.addEventListener("DOMContentLoaded", () => {
#   $(".ui.dropdown").dropdown();
#   $(".ui.checkbox").checkbox();
#   $(".ui.calendar").calendar({ type: "date" });
# });
#
# // Or with a Stimulus controller:
# //
# // import { Controller } from "@hotwired/stimulus"
# // export default class extends Controller {
# //   connect() {
# //     $(this.element).find(".ui.dropdown").dropdown()
# //     $(this.element).find(".ui.checkbox").checkbox()
# //   }
# // }
