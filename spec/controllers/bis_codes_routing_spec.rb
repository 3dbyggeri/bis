require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BisCodesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "bis_codes", :action => "index").should == "/bis_codes"
    end
  
    it "should map #new" do
      route_for(:controller => "bis_codes", :action => "new").should == "/bis_codes/new"
    end
  
    it "should map #show" do
      route_for(:controller => "bis_codes", :action => "show", :id => 1).should == "/bis_codes/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "bis_codes", :action => "edit", :id => 1).should == "/bis_codes/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "bis_codes", :action => "update", :id => 1).should == "/bis_codes/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "bis_codes", :action => "destroy", :id => 1).should == "/bis_codes/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/bis_codes").should == {:controller => "bis_codes", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/bis_codes/new").should == {:controller => "bis_codes", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/bis_codes").should == {:controller => "bis_codes", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/bis_codes/1").should == {:controller => "bis_codes", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/bis_codes/1/edit").should == {:controller => "bis_codes", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/bis_codes/1").should == {:controller => "bis_codes", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/bis_codes/1").should == {:controller => "bis_codes", :action => "destroy", :id => "1"}
    end
  end
end
