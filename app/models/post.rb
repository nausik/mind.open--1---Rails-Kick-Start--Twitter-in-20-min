class Post < ActiveRecord::Base
  attr_accessible :text
  validates :text, length: {maximum: 140}
   acts_as_taggable_on :tags
  belongs_to :user
end
