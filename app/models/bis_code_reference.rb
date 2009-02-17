class BisCodeReference < ActiveRecord::Base
  belongs_to :reference, :foreign_key => 'reference_id', :class_name => 'BisCode'
  belongs_to :referrer, :foreign_key => 'referrer_id', :class_name => 'BisCode'
end
