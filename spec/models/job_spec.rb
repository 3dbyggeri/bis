require File.dirname(__FILE__) + '/../spec_helper'
require "yaml"

describe Job do

  before(:each) do
    @valid_params = [ {"label"=>"Indretninger", "full_code"=>"6"}, 
                      {"label"=>"Standardiserede byggesystemer, præfab. bygninger og rum", "full_code"=>"7"}, 
                      {"label"=>"Materiel og værktøjer til byggeplads og drift", "full_code"=>"8"}, 
                      {"label"=>"Specialarbejder", "full_code"=>"9"}, 
                      {"label"=>"Installationer for væsker, gasser, varme, køling, luftbehandling", "full_code"=>"3"}, 
                      {"label"=>"Elektriske installationer", "full_code"=>"4"}, 
                      {"label"=>"Løft og transport", "full_code"=>"5"},
                      {"label"=>"Produkter til konstruktioner - generelt anvendelige", "full_code"=>"1"},
                      {"label"=>"Sten, blokke, profiler, rør", "full_code"=>"11"},
                      {"label"=>"Sten, blokke, overliggere til murværk", "full_code"=>"111"},
                      {"label"=>"Picksten, marksten", "full_code"=>"111 01"},
                      {"label"=>"Produkter til konstruktioner - specielt anvendelige", "full_code"=>"2"},
                      {"label"=>"BYGNINGSDELE TIL BÆREVÆRK, AFSKÆRMINGER OG RUMDELING", "full_code"=>"26"},
                      {"label"=>"Trapper, trappetrin og -gelændere, stiger, ramper", "full_code"=>"266"},
                      {"label"=>"Trapper i beton og murværk", "full_code"=>"266.01",
                        "references"=>[{"description" => "for trappetrin se gruppe", "reference_to" => "266.04"},
                                       {"description" => "for alt muligt andet se gruppe", "reference_to" => "1"}]},
                      {"label"=>"Trappetrin", "full_code"=>"266.04"}]
    @invalid_params = "I'm invalid!"
    @logger = mock('logger')
  end
  
  # the test parameter will make the Job forward any exceptions thrown, to enable a proper stacktrace i rspec tests.
  # parameter 'test = false' prohibits the Job from forwarding exceptions if we need the exception to be caught and handled as if in production
  def create_job(params, test = true)
    args = Hash.new
    args[:args] = Hash.new
    args[:args][:params] = params
    args[:args][:debug] = true
    args[:args][:test] = test
    @job = Job.create(args)
    puts @job.errors.full_messages.join(', ') unless @job.valid?
    # The worker would normally call process_products, but in this case (we removed the MiddleMan from env) we need to 'simulate'
    @job.process_bis_codes(args[:args], @logger)
  end

  it "should finish" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params)
    @job.reload.should be_finished
  end

  it "should finish with success" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params)
    # puts @job.reload.message
    # puts @job.reload.report
    @job.reload.should be_a_success
    @job.should be_finished
  end

  it "should fail when no parameters" do
    @logger.should_receive(:warn).at_least(:once)
    create_job(nil, false)

    @job.reload.should be_finished
    @job.should_not be_a_success
    @job.message.should == "Job parameters was not supplied."
  end

  it "should fail when invalid parameters" do
    @logger.should_receive(:debug).at_least(:once)
    @logger.should_receive(:warn).at_least(:once)
    create_job(@invalid_params, false)

    @job.reload.should be_finished
    @job.should_not be_a_success
    @job.message.should == "Job parameters was not well formed: Not a Ruby Array - is your xml correct?"
  end
  
  it "should fail when there's an invalid bis code present" do
    @valid_params.first['full_code']=nil
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params, false)

    @job.reload.should be_finished
    @job.should_not be_a_success
    @job.message.should == "Job had errors - see report for details."
    @job.report.should == "bis code #1( Indretninger): Full code can't be blank.\n"
  end

  it "should progress" do
    @logger.should_receive(:debug).at_least(:once)
    @job = Job.create(:args => { :debug => true, :test => true })
    @job.should_receive(:progress=).at_least(4).times
    # The worker would normally call process_products, but in this case (we removed the MiddleMan from env) we need to 'simulate'
    @job.process_bis_codes({ :params => @valid_params, :debug => true, :test => true }, @logger)
  end

  it "should commit bis codes" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params)
    BisCode.find_by_full_code("6").should_not be_blank
  end

  it "should create correct hierachy" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params)
    BisCode.find_by_full_code("1").children.should_not be_blank
    BisCode.find_by_full_code("1").children.size.should == 1
    BisCode.find_by_full_code("11").children.should_not be_blank
    BisCode.find_by_full_code("11").children.size.should == 1
    BisCode.find_by_full_code("111").children.should_not be_blank
    BisCode.find_by_full_code("111").children.size.should == 1
    BisCode.find_by_full_code("2").children.size.should == 1
    BisCode.find_by_full_code("26").children.size.should == 1
    BisCode.find_by_full_code("266").children.size.should == 2
  end
  
  it "should have references" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params)
    BisCode.find_by_full_code("266.01").references_as_referrer.size.should == 2
    BisCode.find_by_full_code("266.01").references.size.should == 2
    BisCode.find_by_full_code("266.01").references.include?(BisCode.find_by_full_code("266.04")).should be_true
  end

  it "should update bis code" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params)
    BisCode.find_all_by_full_code("1").size.should == 1
    BisCode.find_by_full_code("1").children.size.should == 1
  end
end
