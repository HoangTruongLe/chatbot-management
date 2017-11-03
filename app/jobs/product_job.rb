class ProductJob < ApplicationJob
  def perform(copied_message, msg_cnt)
    pm = ProductMessage.find_by_id(msg_cnt.content_id)
    copied_message.product_messages.build(pm.dup.attributes)
    copied_message.save
  end
end
