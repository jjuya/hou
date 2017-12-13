class List < ActiveRecord::Base

  belongs_to :board

  has_many :bookmarks

  validates :title,
            presence: true,
            length: {minimun: 1, maximum: 20}

end
