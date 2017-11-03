class Tag < ApplicationRecord
  has_many :tag_messages, :dependent => :restrict_with_error
  has_many :messages, through: :tag_messages

  belongs_to :created_user, class_name: 'User', foreign_key: 'created_user_id', optional: true
  belongs_to :updated_user, class_name: 'User', foreign_key: 'updated_user_id', optional: true

  acts_as_paranoid
  validates :name, presence: true
  validates_length_of :name, :maximum => 200
  validates :name, uniqueness: true


  ransacker :id do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '99999999')")
  end

  ACTIVITY = [[I18n.t('categories.form.activity.active'),true], [I18n.t('categories.form.activity.inactive'),false]]
end
