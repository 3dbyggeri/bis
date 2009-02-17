require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/bis_codes/edit.html.erb" do
  include BisCodesHelper
  
  before(:each) do
    assigns[:bis_code] = @bis_code = stub_model(BisCode,
      :new_record? => false,
      :parent_id => 1,
      :own_code => "value for own_code",
      :label => "value for label",
      :description => "value for description"
    )
  end

  it "should render edit form" do
    render "/bis_codes/edit.html.erb"
    
    response.should have_tag("form[action=#{bis_code_path(@bis_code)}][method=post]") do
      with_tag('input#bis_code_parent_id[name=?]', "bis_code[parent_id]")
      with_tag('input#bis_code_own_code[name=?]', "bis_code[own_code]")
      with_tag('input#bis_code_label[name=?]', "bis_code[label]")
      with_tag('textarea#bis_code_description[name=?]', "bis_code[description]")
    end
  end
end


