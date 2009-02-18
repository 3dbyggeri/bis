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
                      {"label"=>"Trapper i beton og murværk", "full_code"=>"266 01+01234",
                        "references"=>[{"description" => "for trappetrin se gruppe", "reference_to" => "266 04"},
                                       {"description" => "for alt muligt andet se gruppe", "reference_to" => "1"}]},
                      {"label"=>"Trappetrin", "full_code"=>"266 04"},
                      {"label"=>"Vinduer i træ", "full_code"=>"273 11"},
                      {"label"=>"Klassiske vinduer i træ", "full_code"=>"273 11 11"},
                      {"label"=>"Palævinduer i træ", "full_code"=>"273 11 111"},
                      {"label"=>"Konstruktioner med søjler og bjælker i støbejern til overdækninger", "full_code"=>"266.06 20"},
                      {"label"=>"Søjler i støbejern til overdækninger", "full_code"=>"266.06 20/261 40 10"}]
                      
    @group0_params = [ {"description"=>nil, "label"=>"Byggeriets råmaterialer", "references"=>nil, "full_code"=>"0"},
                       {"description"=>"(forekommer ikke frit i naturen)\nCESIUM 55\nFRANCIUM 87\nKalium: se Potassium\nLITHIUM 3\nNatrium: se Sodium\n", "label"=>"1 Alkali Metals", "references"=>nil, "full_code"=>"0111"}, 
                       {"description"=>nil, "label"=>"KALK, CEMENT, PUZZALANER", "references"=>nil, "full_code"=>"021"}, 
                       {"description"=>nil, "label"=>"011311", "references"=>nil, "full_code"=>"0113101"},
                       {"description"=>"         \tMagna er flydende silikatsmeltemasse\n", "label"=>"MINERALER FRA MAGNA- OG DYBBJERGARTER - STENDANNENDE MINERALER", "references"=>nil, "full_code"=>"0121"}, 
                       {"description"=>"RUBRIDIUM 37\nSODIUM (Natrium) 11\n\n", "label"=>"POTASSIUM (Kalium) 19", "references"=>nil, "full_code"=>"01111"}, 
                       {"description"=>"\n", "label"=>"GRUNDSTOFFER, MINERALER, JORD, STEN", "references"=>nil, "full_code"=>"01"}, 
                       {"description"=>"\n", "label"=>"MINERALSKE R\303\205MATERIALER", "references"=>nil, "full_code"=>"02"}, 
                       {"description"=>"Grundstofferne - defineret som kemiske elementer - er underopdelt i 9 grupper med referencer til grupperne i 'Periodic Table' fundet p\303\245 www.chemicalelements.com\n\nInden for hver gruppe oplyses grundstofferne i alfabetisk orden inklusive deres atomnummer, dvs antallet af de omkring kernen kredsende atomer. \n\nGrundstoffer fra grupperne for Lanthanider og Actinider er ikke medtaget - se eksempler i gruppe  9 'Rare Earth Elements'.\nGrundstoffer med h\303\270jere atomtal end 102 er heller ikke medtaget - se eksempler i gruppe  3 'Transition Metals'.\n\n\nOm de naturlige grundstoffer\nNaturlige grundstoffer indeholder mineraler, som er komponeret af flere end et grundstof, idet de fleste\nnaturlige mineraler er urene.\n markerer at grundstoffet klassificeres i Klasse 1 Naturlige grundstoffer efter 'The Scientific Mineral System' som n\303\246vnt i indledningen i 012 Mineraler. \n\n\n", "label"=>"GRUNDSTOFFER (Chemical Elements)", "references"=>nil, "full_code"=>"011"}, 
                       {"description"=>"\nHistorien om den mineralske videnskab\nDen f\303\270rste videnskabelige publikation om mineraler blev skrevet af Aristoteles (384-322BC), og hans mineralsystem blev stadigv\303\246k betragtet som v\303\246rdifuldt indtil 1800tallet. Det var den saksiske mineralog A.G. Werner (1749-1817), som udt\303\246nkte en ny klassifikation af mineraler, som stort set er g\303\246ldende i dag. Videnskaben om mineraler kaldes for mineralogi. \n\nMineraler og mineralklasser\nDer findes godt 3000 forskellige mineraler og adskillige tusinde varieteter if\303\270lge the International Mineralogical Association, som er ansvarlig for godkendelse og navngivning af nye mineralarter fundet i naturen. Af disse kan m\303\245ske 150 kaldes for 'almindelige', andre 50 for 'lejlighedsvise', og resten er sj\303\246ldne eller yderst sj\303\246ldne. \nMineralerne er opdelt i 9 klasser efter 'The Scientific Mineral System', som publiceret i Walther Schumanns Handbook of Rocks, Minerals & Gemstones - engelsk udgave fra 1993.\n'The Scientific Mineral System' er en kemisk klassifikation, idet mineralernes kemiske specifikationer m\303\245 anses for den mest sikre fastl\303\246ggelse eller identifikation af de mange mineraler. \n\nOversigt over klasserne i 'The Scientific Mineral System':\nKlasse 10 NATURLIGE GRUNDSTOFFER (The Native Elements Class)\nKlasse 20 SULFIDER OG RELATEREDE MINERALER \nKlasse 30 HALOGENIDER \nKlasse 40 OXYDER OG HYDROOXYDER \nKlasse 50 NITRATER, CARBONATER OG BORATER \nKlasse 60 SULFATER, MOLYBDATER, CHROMATER OG WOLFRAMATER \nKlasse 70 FOSFATER, ARSENATER, VANADATER \nKlasse 80 SILIKATER \nKlasse 90 ORGANISKE MINERALER\n\nDet er imidlertid valgt at klassificere mineralerne med koder efter den kapitelopdeling og kapiteloverskrifter, som fremg\303\245r af ovenn\303\246vnte Handbook of Rocks, Minerals & Gemstones \n\nUdvalgte mineraler\nDe udvalgte og klassificerede mineraler har speciel interesse for byggeriet i videste forstand.\nEfterf\303\270lgende numre i parantes som fx (40) markerer mineralklasse if\303\270lge 'The Scientific Mineral System'.\n\nNOTE: Nogle af mineralerne i grupperne 0121 til 0126 er udvalgt fra Gorm Jensens bog 'Mineraler' efter id\303\251 af Paolo Bignardi - Hernovs Forlag 1988. Udover mineraler som bruges i byggeriet, er der medtaget en del vigtige malme og legeringsmetaller til st\303\245l og metaller.\n\n", "label"=>"MINERALER", "references"=>nil, "full_code"=>"012"}]
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
    BisCode.find_by_full_code("266").children.size.should == 3
    BisCode.find_by_full_code("266.06 20").children.size.should == 1
    BisCode.find_by_full_code("273 11").children.size.should == 1
    BisCode.find_by_full_code("273 11 11").children.size.should == 1
  end
  
  it "should have references" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params)
    BisCode.find_by_full_code("266 01+01234").references_as_referrer.size.should == 2
    BisCode.find_by_full_code("266 01+01234").references.size.should == 2
    BisCode.find_by_full_code("266 01+01234").references.include?(BisCode.find_by_full_code("266 04")).should be_true
  end
  
  it "should have descriptions" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@group0_params)
    BisCode.find_by_full_code("0111").description.should_not be_blank
  end

  it "should update bis code" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@valid_params)
    BisCode.find_all_by_full_code("1").size.should == 1
    BisCode.find_by_full_code("1").children.size.should == 1
  end
  
  it "should process group 0" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@group0_params)
    # puts @job.reload.message
    # puts @job.reload.report
    @job.reload.should be_a_success
    @job.should be_finished
  end
  
  it "should create group 0 hierachy" do
    @logger.should_receive(:debug).at_least(:once)
    create_job(@group0_params)
    BisCode.find_by_full_code("0").children.should_not be_blank
    BisCode.find_by_full_code("0").children.size.should == 2
    BisCode.find_by_full_code("01").children.should_not be_blank
    BisCode.find_by_full_code("01").children.size.should == 2
    BisCode.find_by_full_code("011").children.should_not be_blank
    BisCode.find_by_full_code("011").children.size.should == 2
    BisCode.find_by_full_code("0111").children.should_not be_blank
    BisCode.find_by_full_code("0111").children.size.should == 1
    BisCode.find_by_full_code("02").children.size.should == 1
  end
end
