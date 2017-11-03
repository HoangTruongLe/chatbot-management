class Site < ApplicationRecord
  has_one :api_key
  has_many :products
  has_many :product_statistics
  has_many :product_reports
  has_many :product_logs
  belongs_to :user, optional: true

  before_create :generate_new_key
  before_create :generate_aibot_address

  validates :name, presence: true
  validates :site_url, presence: true

  ransacker :id do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '99999999')")
  end

  private

  def generate_new_key
    self.build_api_key
  end

  def generate_aibot_address
    self.aibot_address = Settings.site.aibot_address
  end
end
