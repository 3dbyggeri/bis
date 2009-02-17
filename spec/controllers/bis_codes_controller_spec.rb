require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BisCodesController do

  def mock_bis_code(stubs={})
    @mock_bis_code ||= mock_model(BisCode, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all bis_codes as @bis_codes" do
      BisCode.should_receive(:find).with(:all).and_return([mock_bis_code])
      get :index
      assigns[:bis_codes].should == [mock_bis_code]
    end

    describe "with mime type of xml" do
  
      it "should render all bis_codes as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        BisCode.should_receive(:find).with(:all).and_return(bis_codes = mock("Array of BisCodes"))
        bis_codes.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested bis_code as @bis_code" do
      BisCode.should_receive(:find).with("37").and_return(mock_bis_code)
      get :show, :id => "37"
      assigns[:bis_code].should equal(mock_bis_code)
    end
    
    describe "with mime type of xml" do

      it "should render the requested bis_code as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        BisCode.should_receive(:find).with("37").and_return(mock_bis_code)
        mock_bis_code.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new bis_code as @bis_code" do
      BisCode.should_receive(:new).and_return(mock_bis_code)
      get :new
      assigns[:bis_code].should equal(mock_bis_code)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested bis_code as @bis_code" do
      BisCode.should_receive(:find).with("37").and_return(mock_bis_code)
      get :edit, :id => "37"
      assigns[:bis_code].should equal(mock_bis_code)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created bis_code as @bis_code" do
        BisCode.should_receive(:new).with({'these' => 'params'}).and_return(mock_bis_code(:save => true))
        post :create, :bis_code => {:these => 'params'}
        assigns(:bis_code).should equal(mock_bis_code)
      end

      it "should redirect to the created bis_code" do
        BisCode.stub!(:new).and_return(mock_bis_code(:save => true))
        post :create, :bis_code => {}
        response.should redirect_to(bis_code_url(mock_bis_code))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved bis_code as @bis_code" do
        BisCode.stub!(:new).with({'these' => 'params'}).and_return(mock_bis_code(:save => false))
        post :create, :bis_code => {:these => 'params'}
        assigns(:bis_code).should equal(mock_bis_code)
      end

      it "should re-render the 'new' template" do
        BisCode.stub!(:new).and_return(mock_bis_code(:save => false))
        post :create, :bis_code => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested bis_code" do
        BisCode.should_receive(:find).with("37").and_return(mock_bis_code)
        mock_bis_code.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bis_code => {:these => 'params'}
      end

      it "should expose the requested bis_code as @bis_code" do
        BisCode.stub!(:find).and_return(mock_bis_code(:update_attributes => true))
        put :update, :id => "1"
        assigns(:bis_code).should equal(mock_bis_code)
      end

      it "should redirect to the bis_code" do
        BisCode.stub!(:find).and_return(mock_bis_code(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(bis_code_url(mock_bis_code))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested bis_code" do
        BisCode.should_receive(:find).with("37").and_return(mock_bis_code)
        mock_bis_code.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bis_code => {:these => 'params'}
      end

      it "should expose the bis_code as @bis_code" do
        BisCode.stub!(:find).and_return(mock_bis_code(:update_attributes => false))
        put :update, :id => "1"
        assigns(:bis_code).should equal(mock_bis_code)
      end

      it "should re-render the 'edit' template" do
        BisCode.stub!(:find).and_return(mock_bis_code(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested bis_code" do
      BisCode.should_receive(:find).with("37").and_return(mock_bis_code)
      mock_bis_code.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the bis_codes list" do
      BisCode.stub!(:find).and_return(mock_bis_code(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(bis_codes_url)
    end

  end

end
