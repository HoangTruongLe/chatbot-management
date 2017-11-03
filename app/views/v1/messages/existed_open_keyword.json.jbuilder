json.existed @messages.blank? ? 'false' : 'true'
json.text_message ActionView::Base.full_sanitizer.sanitize(@text_message)
