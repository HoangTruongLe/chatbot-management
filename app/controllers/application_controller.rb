class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  protect_from_forgery prepend: true
  add_breadcrumb "TOP", :root_path
  helper_method :add_updated_user

  def add_updated_user(message_id)
    msg = Message.find_by_id(message_id)
    msg.updated_user = current_user
    msg.save
  end
end
