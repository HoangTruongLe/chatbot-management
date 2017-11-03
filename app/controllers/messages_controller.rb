class MessagesController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :set_message, only: [:show, :destroy, :copy_message, :message_preview,
    :edit, :update, :update_primary_keyword,:update_message_priority,
    :create_relative_keyword, :update_message_type, :update_message_activity, :destroy_relative_keyword,
    :update_message_tag, :message_detail_report]
  before_action :find_keyword, only: [:destroy_relative_keyword]
  before_action :message_breadcrumb, except: [:edit, :message_preview]
  before_action :keyword, only: [:edit, :index, :update]
  before_action :product, only: [:edit, :update]
  before_action :message_ranksack, only: [:index, :edit, :update]
  before_action :add_updated_user, only: [:update, :update_primary_keyword,:update_message_priority,
    :update_message_type, :update_message_activity, :destroy_relative_keyword, :update_message_tag, :create_relative_keyword, :destroy]
  before_action :add_created_user, only: [:create]

  def index
  end

  def show
  end

  def new
    add_breadcrumb t('.new_title')
    @message = Message.new(is_draft: true, priority: 50, message_type: 'open', activity: true)

    respond_to do |format|
      @message.created_user = current_user
      if @message.save
        format.html { redirect_to edit_message_path(@message.id) }
      end
    end
  end

  def edit
    if @message.is_draft
      add_breadcrumb t('.new_title')
    else
      add_breadcrumb t('message_title'), messages_path
      add_breadcrumb @message.id
    end
    @chatbot_emotions = ChatbotEmotion.all
    # @messages = Message.published.includes(:keyword)
    @tags = Tag.all
    @tag_messages = TagMessage.includes(:tag).where(message_id: @message.id)
    @pri_keyword = Keyword.find_by_id(@message.keyword_id)
    @rev_keywords = RelativeKeyword.includes(:keyword).where(message_id: @message.id)
    @message_contents = @message.message_contents.includes(:content).order(:row_order)
  end

  def message_preview
    add_breadcrumb t('message_title'), messages_path
    add_breadcrumb @message.id
    @message_contents = @message.message_contents.includes(:content).order(:row_order) if @message
    respond_to do |format|
      format.html
      format.js { render partial: 'messages/message_preview_modal', locals: { message_contents: @message_contents }}
    end
  end

  def copy_message
    new_message = @message.dup
    new_message.id = nil
    copied_message = Message.new(new_message.attributes)
    if copied_message.save!
      copied_message.tags = @message.tags
      copied_message.keywords = @message.keywords
      @message.message_contents.order(:row_order).each do |msg_cnt|
        case msg_cnt.content_type
        when 'TextMessage'
          TextMessageJob.perform_later(copied_message, msg_cnt)
        when 'Question'
          QuestionJob.perform_later(copied_message, msg_cnt)
        when 'LinkCard'
          LinkcardJob.perform_later(copied_message, msg_cnt)
        when 'ProductMessage'
          ProductJob.perform_later(copied_message, msg_cnt)
        when 'PhotoGroup'
          PhotoJob.perform_later(copied_message, msg_cnt)
        when 'VideoGroup'
          VideoJob.perform_later(copied_message, msg_cnt)
        when 'Quote'
          QuoteJob.perform_later(copied_message, msg_cnt)
        end
      end
      redirect_to edit_message_path(copied_message.id)
    end
  end

  def message_detail_report
    respond_to do |format|
      format.csv { send_data @message.message_detail_report.encode(Encoding::SJIS),
                              filename: "message-detail-report-#{Date.today}.csv",
                              type: 'text/csv; charset=shift_jis' }
    end
  end

  def keyword
    @k = Keyword.ransack(params[:q])
    @keywords = @k.result.includes(:master_category).order(:id).page(params[:page])
  end

  def product
    @p = Product.ransack(params[:q])
    @products = @p.result.includes(:category, :site).page(params[:page]).order(:id)
  end

  def create
    add_breadcrumb t('.new_title')
  end

  def update
    respond_to do |format|
      @message.is_draft = false
      if @message.update_attributes(message_params)
        format.html { redirect_to messages_path }
      else
        flash[:error] = @message.errors.full_messages
        format.html { redirect_to edit_message_path(@message) }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @message.destroy
        format.html { redirect_to messages_path, notice: t('.message_destroy_successfully') }
      end
    end
  end

  def update_message_tag
    tag_messages = TagMessage.where(message_id: params[:id])
    tag_messages.destroy_all
    tag = []
    if params[:tags]
      params[:tags].each do |t|
        tag << [tag_id: t, message_id: params[:id]]
      end
    end
    tags = TagMessage.create(tag)
    tags_name = []
    if tags.count > 0
      tags.each do |tn|
        tags_name << tn.first.tag.name
      end
      render json: tags_name, status: 200
    end
    @message.touch
  end

  def get_tag_messages
    res = TagMessage.includes(:tag).where(message_id: params[:id])
    return_tags =[]
    res.each do |t|
      return_tags << [id: t.tag.id, name: t.tag.name]
    end
    render json: return_tags, status: 200
  end

  def update_primary_keyword
    if @message.update_attributes(keyword_id: params[:keyword_id])
      render json: { keyword: Keyword.find_by_id(params[:keyword_id]).name }, status: 200
    else
      render json: @message.errors
    end
  end

  def create_relative_keyword
    relative_keyword = RelativeKeyword.new(keyword_id: params[:keyword_id], message_id: params[:id])
    return_keyword = Keyword.find_by_id(params[:keyword_id])
    if relative_keyword.save
      @message.touch
      render json: return_keyword, status: 200
    else
      render json: relative_keyword.errors
    end
  end

  def get_relative_keywords
    rev_keywords = RelativeKeyword.includes(:keyword).where(message_id: params[:id])
    return_rev_keys =[]
    rev_keywords.each do |rev|
      return_rev_keys << [id: rev.keyword.id, name: rev.keyword.name]
    end
    render json: return_rev_keys, status: 200
  end

  def destroy_relative_keyword
    if params[:keyword_id]
      if keyword = @delete_keyword.destroy
        @message.touch
        render json: [{id: keyword.keyword_id}], status: 200
      else
        render json: keyword.errors
      end
    else
      if keywords = @message.keywords.destroy_all
        @message.touch
        render json: keywords, status: 200
      else
        render json: keywords.errors
      end
    end
  end

  def update_message_type
    if @message.update_attributes(message_type: params[:message_type])
      render json: @message, status: 200
    else
      render json: @message.errors
    end
  end

  def update_message_activity
    if @message.update_attributes(activity: params[:message_activity])
      render json: @message, status: 200
    else
      render json: @message.errors
    end
  end

  def update_message_priority
    if @message.update_attributes(priority: params[:message_priority])
      render json: @message, status: 200
    else
      render json: @message.errors
    end
  end

  def summary_message_report
    respond_to do |format|
      format.csv { send_data Message.to_csv.encode(Encoding::SJIS),
                              filename: "summary-message-report-#{Date.today}.csv",
                              type: 'text/csv; charset=shift_jis' }
    end
  end

  private

  def message_ranksack
    @q = Message.published.ransack(params[:q])
    @messages = @q.result(distinct: true).includes(:keywords, [keyword: :master_category]).order(:id).page(params[:page])
  end

  def find_keyword
    @delete_keyword = RelativeKeyword.find_by(keyword_id: params[:keyword_id], message_id: params[:id])
  end

  def set_message
    @message = Message.find_by_id(params[:id])
  end

  def message_params
    params.require(:message).permit(:id, :priority, :activity, :message_type)
  end

  def add_updated_user
    @message.updated_user = current_user
    @message.save
  end

  def message_breadcrumb
    add_breadcrumb t('message_title'), messages_path
  end
end
