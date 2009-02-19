class Job < ActiveRecord::Base

  def finished?
    self.progress == 100
  end

  def success?
    self.success
  end

  def process_bis_codes(args, logger = ActiveRecord::Base.logger)
    initialize_task(args[:debug], logger)
    begin
      raise "Job parameters was not supplied." if args[:params].blank?
      params = args[:params]
      @step = 100.0 / (params.size*5)
      @logger.send(:debug, Time.now.to_s + ": Worker ##{self.id}: step determined: #{@step}") if @debug
      @message = "Job had errors - see report for details." unless @success = validate_parameters(deepcopy(params))
      unless args[:validate_only] || !@success
        raise "Job failed during commit, database might be left inconsistent!: " + @message unless @success = commit_bis_codes(params, false)
        @message = "Job failed during build of bis codes hierachy." unless @success = rebuild_bis_codes_hierachy
        @message = "Job failed during build of bis codes references." unless @success = build_bis_codes_references(params)
      end
    rescue Exception => exc
      # if this is a test, the exception should be forwarded to the test runnner
      raise if ENV["RAILS_ENV"] == 'test' && args[:test]
      @success = false
      @message = exc.message
      @logger.send(:warn, Time.now.to_s + ": Worker ##{self.id} caught exception: #{exc.message}:")
      @logger.send(:warn, exc.backtrace.join("\n"))
    end
    update_and_save_with_lock
  end

  # helper methods
  def rebuild_bis_codes_hierachy
    success = true
    BisCode.get_hierachy_root.each { |code| create_bis_code_children_hierachy(code) }
    hierachy_root = BisCode.get_hierachy_root
    BisCode.find(:all).each do |code|
      if code.parent.blank? && !hierachy_root.include?(code)
        found_in_last_minute = false
        parent = nil
        # if the code is from group 0-9 find the parent backwards
        if (0..9).to_a.include? code.full_code.first.to_i
          #first se if it's a combined code
          if code.full_code =~ /[\/\+]/
            parent_code = code.full_code.split('+').first.split('/').first
            parent = BisCode.find_by_full_code(parent_code)
          end
          
          # otherwise chop of chars from the right and see if a parent hides somewhere down the lane
          parent_code = code.full_code.chop
          while parent.nil? && parent_code.length > 1
            parent = BisCode.find_by_full_code(parent_code)
            parent_code.chop!
          end

          unless parent.blank?
            code.parent = parent
            code.save
            found_in_last_minute = true
          end
        end
        unless found_in_last_minute
          @report += "BIS code #{code.full_code} did not find any parent\n"
          success = false
        end
      end
    end
    return success
  end

  def create_bis_code_children_hierachy(parent)
    select_code = ("AB".include? parent.full_code.first) ? parent.full_code.first : parent.full_code
    @bis_codes = BisCode.find_by_sql("SELECT id, full_code, label FROM bis_codes WHERE full_code LIKE '#{select_code}%'")
    raise "Internal error - the @bis_codes var was not available" if @bis_codes.blank?
    update_progress(2)
    # first, clean up. This hierachy will be rebuilt
    parent.children.each { |child| child.parent_id = nil; child.save }
    # now to the rebuilding
    parent_code = parent.full_code
    children = []
    
    if parent_code.first == 'A' 
      
      if parent_code == 'A' # root code
        children = @bis_codes.select{ |code| code.full_code =~ /^A\d{2}\-\d{2}$/ }.sort_by { |code| code.full_code }
      
      elsif parent_code.include?('-') # a level 2 code
        parent_code_from, parent_code_to = parent_code.split('-')
        parent_code_from.reverse!.chop!.reverse!
        potential_children = @bis_codes.select{ |code| code.full_code =~ /^A\d{2}$/ }.sort_by { |code| code.full_code }
        children = potential_children.select { |code| (parent_code_from .. parent_code_to).include? code.full_code.reverse.chop.reverse }
      end
      
    elsif parent_code.first == 'B'
      
      if parent_code == 'B' # root code
        children = @bis_codes.select{ |code| code.full_code =~ /^B\d{2}\-\d{2}$/ }.sort_by { |code| code.full_code }
      
      elsif parent_code.include?('-') # a level 2 code
        parent_code_from, parent_code_to = parent_code.split('-')
        parent_code_from.reverse!.chop!.reverse!
        potential_children = @bis_codes.select{ |code| code.full_code =~ /^B\d{2}$/ }.sort_by { |code| code.full_code }
        children = potential_children.select { |code| (parent_code_from .. parent_code_to).include? code.full_code.reverse.chop.reverse }
      end
      
    elsif parent_code.first == 'P'
      children = @bis_codes.select{ |code| code.full_code =~ /^#{parent_code}\d{2}$/ }.sort_by { |code| code.full_code } if children.blank?
    
    # groups 1-9
    elsif (1..9).to_a.include? parent_code.first.to_i
      children = @bis_codes.select{ |code| code.full_code =~ /^#{parent_code}\d$/ }.sort_by { |code| code.full_code }
      children = @bis_codes.select{ |code| code.full_code =~ /^#{parent_code}\d{2}$/ }.sort_by { |code| code.full_code } if children.blank?
      children = @bis_codes.select{ |code| code.full_code =~ /^#{parent_code}\s\d{2}$/ }.sort_by { |code| code.full_code } if children.blank?
      children = @bis_codes.select{ |code| code.full_code =~ /^#{parent_code}\s\d{3}$/ }.sort_by { |code| code.full_code } if children.blank?
      # children = @bis_codes.select{ |code| code.full_code =~ /^#{parent_code}\+\d*$/ }.sort_by { |code| code.full_code } if children.blank?
    
    # group 0
    elsif parent_code.first.to_i == 0
      children = @bis_codes.select{ |code| code.full_code =~ /^#{parent_code}\d$/ }.sort_by { |code| code.full_code } if children.blank?
    end
    unless children.blank?
      children.each do |child|
        child.parent = parent
        child.save
        create_bis_code_children_hierachy(child) # recursive call
      end
    end
  end

  def validate_parameters(params)
    raise "Job parameters was not well formed: Not a Ruby Array - is your xml correct?" unless params.class == Array
    commit_bis_codes(params)
  end
  
  def commit_bis_codes(bis_codes, only_validate = true)
    success = true
    bis_codes.each_with_index do |bis_code_params,bis_code_index|
      bis_code = BisCode.find_by_full_code(bis_code_params['full_code'])

      if bis_code.nil?
        bis_code = BisCode.new(:full_code => bis_code_params['full_code'], :label => bis_code_params['label'], :description => bis_code_params['description'])
      else
        bis_code.full_code = bis_code_params['full_code']
        bis_code.label = bis_code_params['label']
        bis_code.description = bis_code_params['description']
      end

      unless bis_code.valid?
        @report += "bis code ##{bis_code_index+1}(#{bis_code.full_code} #{bis_code.label}): " + bis_code.errors.full_messages.join(', ') + ".\n"
        success = false
      else
        bis_code.save unless only_validate
      end

      update_progress
    end
    return success
  end

  def build_bis_codes_references(bis_codes, only_validate = true)
    success = true
    bis_codes.each_with_index do |bis_code_params,bis_code_index|
      referrer = BisCode.find_by_full_code(bis_code_params['full_code'])
      if referrer.nil?
        @report += "reference parent ##{bis_code_index+1}(#{bis_code_params['full_code']}) was not found in database when trying to create reference (should never happen!).\n"
        success = false
        next
      else
        unless bis_code_params['references'].blank?
          bis_code_params['references'].each do |ref|
            referenced = BisCode.find_by_full_code(ref['reference_to'])
            if referenced.nil?
              @report += "reference child for ##{bis_code_index+1}(#{bis_code_params['full_code']} with code #{ref['reference_to']}) was not found in database.\n"
              # success = false
            else
              BisCodeReference.create(:description => ref['description'], :referrer => referrer, :reference => referenced)
            end
          end
        end
      end
      update_progress
    end
    return success
  end

  def deepcopy(obj)
    Marshal::load(Marshal::dump(obj))
  end

  def initialize_task(debug, logger = ActiveRecord::Base.logger)
    @debug = true if debug
    @logger = logger
    @entities = 0
    @progress = 0.0
    @success = false
    @message = ""
    @report = ""
  end

  def update_and_save_with_lock
    self.lock!
    self.success = @success
    self.progress = 100
    self.message = @message
    self.report = @report
    self.save
  end

  def update_progress(multiplier = 1)
    (@progress + (@step*multiplier)) > 99 ? @progress = 99 : @progress += (@step*multiplier) # never cross the magic 100 boundary - this is done in do_work above
    self.lock!
    self.progress = @progress
    # self.update_attribute('progress', @progress)
    unless self.save
      raise "Could not update Job ##{self.id} when processing: " + self.errors.full_messages.join(', ') + "."
    end
  end

end
