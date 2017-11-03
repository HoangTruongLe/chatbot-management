class ProductMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product_message, only: [:update, :destroy]
  before_action :set_params

  def create
    @template_id = params[:product_message][:product_message_id]
    @product_message = ProductMessage.new(product_message_params)
    respond_to do |format|
      if @product_message.save
        add_updated_user(product_message_params[:message_id])
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @product_message.update_attributes(product_message_params)
        add_updated_user(product_message_params[:message_id])
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  def destroy
    respond_to do |format|
      add_updated_user(set_product_message.message_id)
      if @product_message.destroy
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  private

  def set_params
    @p = Product.ransack(params[:q])
    @products = @p.result.includes(:category, :site).page(params[:page]).order(:id)
  end

  def set_product_message
    @product_message = ProductMessage.find_by_id(params[:id])
  end

  def product_message_params
    params.require(:product_message).permit(:message_id, :product_id)
  end
end
