require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/bis_codes/index.html.erb" do
  include BisCodesHelper
  
  before(:each) do
    assigns[:bis_codes] = [
      stub_model(BisCode,
        :parent_id => 1,
        :own_code => "value for own_code",
        :label => "value for label",
        :description => "value for description"
      ),
      stub_model(BisCode,
        :parent_id => 1,
        :own_code => "value for own_code",
        :label => "value for label",
        :description => "value for description"
      )
    ]
  end

  it "should render list of bis_codes" do
    render "/bis_codes/index.html.erb"
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for own_code".to_s, 2)
    response.should have_tag("tr>td", "value for label".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
  end
end

