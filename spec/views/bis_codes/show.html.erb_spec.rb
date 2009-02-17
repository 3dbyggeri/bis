require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/bis_codes/show.html.erb" do
  include BisCodesHelper
  before(:each) do
    assigns[:bis_code] = @bis_code = stub_model(BisCode,
      :parent_id => 1,
      :own_code => "value for own_code",
      :label => "value for label",
      :description => "value for description"
    )
  end

  it "should render attributes in <p>" do
    render "/bis_codes/show.html.erb"
    response.should have_text(/1/)
    response.should have_text(/value\ for\ own_code/)
    response.should have_text(/value\ for\ label/)
    response.should have_text(/value\ for\ description/)
  end
end

