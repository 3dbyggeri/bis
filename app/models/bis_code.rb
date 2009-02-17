class BisCode < ActiveRecord::Base

  has_many :references_as_referrer, :foreign_key => 'referrer_id', :class_name => 'BisCodeReference'
  has_many :references, :through => :references_as_referrer
  has_many :references_as_referenced, :foreign_key => 'reference_id', :class_name => 'BisCodeReference'  
  has_many :referrers, :through => :references_as_referenced
  belongs_to :parent, :class_name => 'BisCode'
  has_many :children, :foreign_key => 'parent_id', :class_name => 'BisCode'

  validates_presence_of :full_code, :label

  def self.get_hierachy_root
    result = Array.new
    %w{ 0 1 2 3 4 5 6 7 8 9 A B P }.each do |full_code|
      result << BisCode.find_by_full_code(full_code)
    end
    result.select { |code| !code.nil? }
  end
  
  def parents_until_root
    result = []
    parent_recursive(result)
    result
  end
  
  def root
    parents_until_root.first
  end
  
  def parent_recursive(arr)
    unless parent.nil?
      arr.insert(0, parent)
      parent.parent_recursive(arr)
    end
  end

end
