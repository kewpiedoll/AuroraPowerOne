require "aurora_file_processor"

# NOTE: all tests pass if "1" is always chosen

describe AuroraFileProcessor do
	before do
		@e_instance = AuroraFileProcessor.new("energy.cht", "power.cht")
		@p_instance = AuroraFileProcessor.new("power.cht", "energy.cht")
		@e_instance.read_file
  end

  it "should handle two files" do
  	@e_instance.filename.count.should eq 2
  end

  it "should not matter the order of the files" do
    @p_instance.read_file
    @p_instance.min_power.should eq @e_instance.min_power
    @p_instance.energy_amount.should eq @e_instance.energy_amount
  end

  it "should report the correct amount of energy in Wh" do
  	@e_instance.energy_amount.should eq 265.0
  end

  it "should report the time operated" do
  	@e_instance.energy_run_time.should eq 0.58
  end

  context "#output_report" do
  	before do
  		@e_instance.output_report
  	end

    it "should output a file named 'Energy Report'" do
    	File.exists?("#{File.dirname(__FILE__)}/Energy Report").should eq true
    end

    it "should report total sequestered carbon" do
    	@e_instance.carbon_savings.to_i.should eq 144
    end

    it "should report the selected energy type" do
    	@e_instance.system_type.should eq :PV_Solar
    end
  end

end
