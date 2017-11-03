class QuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quote, only: [:update, :destroy]

  def create
    @template_id = params[:quote][:quote_id]
    @quote = Quote.new(quote_params)
    respond_to do |format|
      if @quote.save
        add_updated_user(quote_params[:message_id])
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
      if @quote.update_attributes(quote_params)
        add_updated_user(quote_params[:message_id])
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
      add_updated_user(set_quote.message_id)
      if @quote.destroy
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  private

  def set_quote
    @quote = Quote.find_by_id(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:message_id, :content, :quote_source, :quote_url, :referral_comment)
  end

end
