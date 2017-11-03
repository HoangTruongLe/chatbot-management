class ApikeyController < ApplicationController
  before_action :authenticate_user!

  def index
    @apikeys = ApiKey.all
  end

  def generate_new_api_key
    ApiKey.create!
    redirect_to action: "index"
  end

end
