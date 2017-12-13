class Board < ActiveRecord::Base

  belongs_to :user

  has_many :lists, dependent: :destroy

  validates :title,
            presence: true,
            length: {minimun: 1, maximum: 20}

  validates :starred,
            inclusion: { in: [ true, false ] }
end
