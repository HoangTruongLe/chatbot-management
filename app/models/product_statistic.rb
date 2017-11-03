class ProductStatistic < ApplicationRecord
  belongs_to :product
  belongs_to :site

  enum statistic_type: [:display, :click]
end
