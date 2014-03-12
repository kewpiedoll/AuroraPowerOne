module Constants
  CO2_USGRID = 592.5 # g CO2 per kWh source: carbonfund.org (ca. 2012)
  ENERGY_USGRID = 4143 # TWh energy, US eletrical grid, 2012 (wiki)
  ENERGY_TYPES = {
  	PV_Solar: 46, 
  	Thermal_Solar: 22, 
  	Onshore_Wind: 12,
  	Geothermal: 45,
  	Hydroelectric: 4,
  	Biomass: 18, 	# can vary
  	 }
end

# addition of these two methods to class string credited to Renee's thanksgiving_dinner.rb answer
class String
	def titlecase
		self.gsub(/\b\w/){|f| f.upcase}
	end
	def humanize
		self.gsub('_',' ').titlecase
	end
end

class ProcessFiles
	include Constants

	attr_reader :energy_amount
	attr_reader :energy_run_time
	attr_reader :filename
	attr_reader :max_power
	attr_reader :min_power
	attr_reader :ave_power
	attr_reader :carbon_savings
	attr_reader :system_type
	attr_reader :carbon_savings

	def initialize filename1, filename2
		@filename = [filename1, filename2]
		p @filename
		@parsed_energy = false
		@parsed_power = false
		@file_count = 0
	end

  # can't close the file (??)
  def read_file
  	@readin = []
    file = File.open(@filename[@file_count], 'r') 
    #self do |line|
	    @readin = file.each.to_a
    #end
    @readin.map! {|s| s.chomp}
    @file_count += 1
    file.close
  	if @readin[0] =~ /Wh/
  		parse_energy
  	else @readin[0] =~ /W/
  		parse_power
  	end
  end

  def parse_hash 
  	hash = {}
  	# Remove the first five lines of the file
  	temp_array = @readin[5, @readin.length]
  	# Split the input at the semicolon: the left hand side is a timestamp and the right hand side 
  	# is the value (either power in W, or energy in Wh depending on the file type).
  	# This is committed to a hash with time as the key and the W/Wh as the value.
  	temp_array.each do |s|
  		k,v = s.split(/;/)
  		# the Aurora reports time as seconds since 1/1/0000 and Ruby reports time utilizing an epoch
  		# that began on 1/1/1970. The time stamp is adjusted for the time in seconds between these
  		# two dates.
  		hash[Time.at(k.to_i - 62167104000)] = v.to_f
  	end
  	return hash
  end

  def parse_energy
  	energy_hash = parse_hash
  	# total energy produced
  	temp_array = []
  	temp_array = energy_hash.to_a
  	# runtime in hours
  	@energy_run_time = (temp_array[temp_array.length - 1][0] - temp_array[0][0])/3600.0
  	# energy in Wh
  	@energy_amount = (temp_array[temp_array.length - 1][1] - temp_array[0][1])
  	
  	# if it parsed energy before power, do power now
  	@parsed_energy = true
  	read_file unless @parsed_power
  	output_report
  end

  def parse_power
  	power_hash = parse_hash
  	@max_power = power_hash.values.max
  	@min_power = power_hash.values.min
  	@parsed_power = true
  	read_file unless @parsed_energy
  end

  def output_report
  	puts "Enter the number for the type of renewable production system?\n"
  	puts "1.\tPV Solar\n"
  	puts "2.\tThermal Solar\n"
  	puts "3.\tOnshore Wind\n"
  	puts "4.\tGeothermal\n"
  	puts "5.\tHydroelectric\n"
  	puts "6.\tBiomass\n"
  	warning = ""
		input = STDIN.gets.chomp
		case input.to_i
		when 1
			@system_type = :PV_Solar
		when 2
			@system_type = :Thermal_Solar
	  when 3
	  	@system_type = :Onshore_Wind
		when 4
			@system_type = :Geothermal
		when 5
			@system_type = :Hydroelectric
		when 6
			@system_type = :Biomass
	  else
	  	warning = "Invalid energy type give. Default is "
	  	@system_type = :PV_Solar
		end
		p input
		@carbon_savings = (@energy_amount / 1000.0) * (CO2_USGRID - ENERGY_TYPES[@system_type])
		@ave_power = (@energy_amount / @energy_run_time).round(2)
		# Write a new output file. Note that this overwrites any existing file.
  	output_file = File.open("Energy Report", 'w+') 
  	output_file.write("ENERGY REPORT\n")
  	output_file.write("Energy System Type: #{warning} #{@system_type.to_s.humanize}\n\n")
  	output_file.write("Total Operating Time: #{@energy_run_time} hours\n")
    output_file.write("Total Energy Produced: #{@energy_amount} Wh\n")
    output_file.write("Your Power Range was #{@min_power} to #{@max_power} W.\n")
    output_file.write("Your Average Power was: #{@ave_power} W\n\n")
    output_file.write("Carbon Productivity-Sequestration:\n")
    output_file.write("#{@system_type.to_s.humanize} Rating: #{ENERGY_TYPES[@system_type]} g CO2 per kWh\n")
    output_file.write("US Average: #{CO2_USGRID} g CO2 per kWh\n")
    output_file.write("Your energy production resulted in #{@carbon_savings.to_i} g net " \
    	"CO2 Productivity-Sequestration\n")
    output_file.close
  end

end


