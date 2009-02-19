class BisCodesController < ApplicationController
  # GET /bis_codes
  # GET /bis_codes.xml
  def index
    @bis_codes = BisCode.get_hierachy_root

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @bis_codes.to_xml(:only => [:full_code,:label], :include => [:children]) }
    end
  end

  # GET /bis_codes/1
  # GET /bis_codes/1.xml
  def show
    @bis_code = BisCode.find_by_full_code(params[:id].split('-')[0].gsub('__','/').gsub('_','.'))

    unless @bis_code.to_param == params[:id]
      headers["Status"] = "301 Moved Permanently"
      redirect_to bis_code_url @bis_code
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @bis_code.to_xml(:only => [:full_code,:label], :include => [:children, :parent]) }
      end
    end
  end

  # GET /bis_codes/new
  # GET /bis_codes/new.xml
  def new
    @bis_code = BisCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @bis_code }
    end
  end

  # GET /bis_codes/1/edit
  def edit
    @bis_code = BisCode.find_by_full_code(params[:full_code])
  end

  # POST /bis_codes
  # POST /bis_codes.xml
  def create
    @bis_code = BisCode.new(params[:bis_code])

    respond_to do |format|
      if @bis_code.save
        flash[:notice] = 'BisCode was successfully created.'
        format.html { redirect_to(@bis_code) }
        format.xml  { render :xml => @bis_code, :status => :created, :location => @bis_code }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @bis_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bis_codes/1
  # PUT /bis_codes/1.xml
  def update
    @bis_code = BisCode.find_by_full_code(params[:full_code])

    respond_to do |format|
      if @bis_code.update_attributes(params[:bis_code])
        flash[:notice] = 'BisCode was successfully updated.'
        format.html { redirect_to(@bis_code) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bis_code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bis_codes/1
  # DELETE /bis_codes/1.xml
  def destroy
    @bis_code = BisCode.find_by_full_code(params[:full_code])
    @bis_code.destroy

    respond_to do |format|
      format.html { redirect_to(bis_codes_url) }
      format.xml  { head :ok }
    end
  end
  
  def search
    @bis_codes = BisCode.find_by_sql(["SELECT id, full_code, label FROM bis_codes WHERE label LIKE ? OR full_code LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%"])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @bis_code.to_xml(:only => [:full_code,:label], :include => [:children, :parent]) }
    end
  end
end
