require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BisCode do
  before(:each) do
    @valid_attributes = {
      :parent_id => 1,
      :own_code => "value for own_code",
      :label => "value for label",
      :description => "value for description"
    }
  end

  it "should create a new instance given valid attributes" do
    BisCode.create!(@valid_attributes)
  end
end
