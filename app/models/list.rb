class List < ActiveRecord::Base

  belongs_to :board

  has_many :bookmarks
end
