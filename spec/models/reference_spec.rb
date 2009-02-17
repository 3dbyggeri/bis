require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reference do
  before(:each) do
    @valid_attributes = {
      :referenced_id => 1,
      :referrer_id => 1,
      :description => "value for description"
    }
  end

  it "should create a new instance given valid attributes" do
    Reference.create!(@valid_attributes)
  end
end
