class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable,
         :recoverable, :trackable, :validatable, :async
  has_many :category_logs, :dependent => :restrict_with_error
  has_many :product_logs, :dependent => :restrict_with_error

  has_many :owner_categories, class_name: "Category", foreign_key: "owner_id", :dependent => :restrict_with_error
  has_many :user_categories, class_name: "Category", foreign_key: "user_id", :dependent => :restrict_with_error

  has_many :owner_products, class_name: "Product", foreign_key: "owner_id", :dependent => :restrict_with_error
  has_many :user_products, class_name: "Product", foreign_key: "user_id", :dependent => :restrict_with_error

  has_many :created_user, class_name: "Message", foreign_key: "created_user_id", :dependent => :restrict_with_error
  has_many :updated_user, class_name: "Message", foreign_key: "updated_user_id", :dependent => :restrict_with_error

  has_many :created_user, class_name: "MasterCategory", foreign_key: "created_user_id", :dependent => :restrict_with_error
  has_many :updated_user, class_name: "MasterCategory", foreign_key: "updated_user_id", :dependent => :restrict_with_error

  has_many :created_user, class_name: "Keyword", foreign_key: "created_user_id", :dependent => :restrict_with_error
  has_many :updated_user, class_name: "Keyword", foreign_key: "updated_user_id", :dependent => :restrict_with_error

  has_many :created_user, class_name: "Tag", foreign_key: "created_user_id", :dependent => :restrict_with_error
  has_many :updated_user, class_name: "Tag", foreign_key: "updated_user_id", :dependent => :restrict_with_error

  has_many :sites, :dependent => :restrict_with_error

  validates :name, presence: true
  validates :name, length: { maximum: 100 }
  validates :email, length: { maximum: 50 }
  validates :email, presence: true
  validates :password, presence: true, on: :create
  validates :password, confirmation: { case_sensitive: true }, on: :create

  after_create :assign_default_role

  def admin?
    self.has_cached_role? :admin
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  ransacker :id do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '99999999')")
  end

  ACTIVITY = [[I18n.t('categories.form.activity.active'),true], [I18n.t('categories.form.activity.inactive'),false]]

  private

  def assign_default_role
    add_role(:manager) if self.roles.blank?
  end
end
