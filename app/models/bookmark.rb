class Bookmark < ActiveRecord::Base

  belongs_to :list

  validates :title,
            presence: true

  validates :url,
            presence: true
            # format: {with: url_regexp}

  validates :description,
            length: {minimun: 1, maximum: 100}

  validates :tag_1,
            length: {minimun: 1, maximum: 20}

  validates :tag_2,
            length: {minimun: 1, maximum: 20}

  validates :tag_3,
            length: {minimun: 1, maximum: 20}

  validates :rating,
            presence: true,
            inclusion: 0..5

  # def url_regexp
  #   return /\A(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?\z/i
  # end
end
