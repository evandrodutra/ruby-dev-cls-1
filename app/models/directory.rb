class Directory < ApplicationRecord
  has_many_attached :files

  belongs_to :parent, class_name: 'Directory', foreign_key: 'parent_id', optional: true
  has_many :subdirectories, class_name: 'Directory', foreign_key: 'parent_id', dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :parent_id }, allow_blank: false

  scope :roots, -> { where(parent_id: nil).order(:name) }
end
