class SitesController < ApplicationController
  before_action :authenticate_user!

  before_action :set_site, only: [:show, :edit, :update, :destroy, :logs]
  before_action :add_sites_index_path

  def index
    @q = Site.ransack(params[:q])
    @sites = @q.result.includes(:api_key, :user).page(params[:page]).order(:id)
  end

  def new
    add_breadcrumb t('sites.new')
    @site = Site.new
  end

  def create
    add_breadcrumb t('sites.new')
    @site = current_user.sites.build(site_params)
    respond_to do |format|
      if @site.update_attributes(site_params)
        format.html { redirect_to sites_path, notice: t('.site_create_successfully') }
      else
        format.html { render :new }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    add_breadcrumb t('sites.edit')
  end

  def update
    add_breadcrumb t('sites.edit')
    respond_to do |format|
      if @site.update_attributes(site_params)
        format.html { redirect_to sites_path, notice: t('.site_update_successfully') }
      else
        format.html { render :edit }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    breadcumb_name = "id#{@site.id}"
    add_breadcrumb breadcumb_name
  end

  def destroy
    respond_to do |format|
      if @site.destroy
        format.html { redirect_to sites_path, notice: t('.destroy_site_successfully') }
      end
    end
  end

  private

  def add_sites_index_path
    add_breadcrumb t('sites.breadcrumb_title'), sites_path
  end

  def set_site
    @site = Site.find(params[:id])
  end

  def site_params
    params.require(:site).permit(:name, :site_url, :aibot_address)
  end
end
