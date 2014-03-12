# A module to store constants relating to electrical production and CO2 emission analysis
module Constants
	# g CO2 emitted per kWh produced. (Source: carbonfund.org (ca. 2012))
  CO2_USGRID = 592.5
  # TWh energy, US eletrical grid, 2012 (Source: Wiki)
  ENERGY_USGRID = 4143
  # A hash that stores 6 common types of renewable energy generation as the keys and service lifecycle carbon emissions
  # per kWh generated as the values (source: Wiki)
  ENERGY_TYPES = {
  	PV_Solar: 46, 
  	Thermal_Solar: 22, 
  	Onshore_Wind: 12,
  	Geothermal: 45,
  	Hydroelectric: 4,
  	Biomass: 18, 	
  	 }
end

# String class: adds two methods
#
# Author: Renee Hendrickson 
# Credit: thanksgiving_dinner.rb answer key
#
class String
	# A method that upcases the first letter of each word
	def titlecase
		self.gsub(/\b\w/){|f| f.upcase}
	end

	# A method to replace underscores in variable names with spaces for human reading
	def humanize
		self.gsub('_',' ').titlecase
	end
end

# This class processes energy and power files unique to the Aurora Power-One inverter.
#
# Author: Chris Ashfield
# License: MIT
# 
# More info about the Aurora device can be found here: 
# http://www.power-one.com/renewable-energy/products/solar/string-inverters/aurora-uno-single-phase/pvi-30363842-north-america/series
# 
class ProcessFiles
	include Constants

  # Total energy output in Wh
	attr_reader :energy_amount
	# Total inverter operating time represented by file
	attr_reader :energy_run_time
	# an array containing both files inputted on the command line
	attr_reader :filename
	# Maximum power (in W) recorded in the power file
	attr_reader :max_power
	# Minimum power (in W) recorded in the power file
	attr_reader :min_power
	# Average power (W) calculated by dividing energy by runtime (energy file used only)
	attr_reader :ave_power
	# The differential carbon impact of utilizing a renewable energy system versus the 
	# average of the entire US electrical grid
	attr_reader :carbon_savings
	# The specific type of renewable energy system. Defaults to PV Solar.
	attr_reader :system_type
  
  # The initialization method takes two arguments that were entered on the command line. 
  # There must be exactly one energy file and one power file. They can be named anything 
  # (note: without spaces) and be entered in any order.
  #
  # === Attributes
  #
  # * +filename1+ The first file read from the command line arguments
  # * +filename2+ The second file read from the command line arguments
  #
	def initialize filename1, filename2
		@filename = [filename1, filename2]
		# boolean vasriables to help track which file is read first
		@parsed_energy = false
		@parsed_power = false
		# keeps track of the number of files read in
		@file_count = 0
	end

  # A helper method to read in the file and map it to an array of strings
  #
  def read_file
  	@readin = []
    file = File.open(@filename[@file_count], 'r') 
	  @readin = file.each.to_a
	  # chop off the escaped characters (in this case: \r\n)
    @readin.map! {|s| s.chomp}
    # increment the file count
    @file_count += 1
    file.close
    # determine which file was read in
    # the files either have a "W" (for power) or "Wh" as the first line
  	if @readin[0] =~ /Wh/
  		parse_energy
  	else @readin[0] =~ /W/
  		parse_power
  	end
  end
  
  # A helper method to map the values (now in an array from either file type) to a hash
  #
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
  
  # A method to parse the data originally from the energy file and calculate the amount of time
  # that past respresented by the data and total energy outputted (and assign them to variables)
  #
  def parse_energy
  	energy_hash = parse_hash
  	# total energy produced
  	temp_array = []
  	temp_array = energy_hash.to_a
  	# runtime in hours
  	@energy_run_time = (temp_array[temp_array.length - 1][0] - temp_array[0][0])/3600.0
  	# energy in Wh
  	@energy_amount = (temp_array[temp_array.length - 1][1] - temp_array[0][1])
  	
  	# if the program parsed energy before power, do power now
  	@parsed_energy = true
  	read_file unless @parsed_power
  	output_report
  end

  # A method to parse the data originally from the power file and find the maximum power
  # reading, minimum power reading, and assign them to class variables
  #
  def parse_power
  	power_hash = parse_hash
  	@max_power = power_hash.values.max
  	@min_power = power_hash.values.min
  	@parsed_power = true
  	read_file unless @parsed_energy
  end
  
  # A method to output a human readable report summarizing the data captured in the energy and power files.
  #
  # This method is called after the energy and power files have been parsed and the desired values
  # calculated and comitted to variables.
  #
  def output_report
  	# Have user indicate the type of renewable energy system that generated the file
  	# The Aurora is type-agnostic: it only reports power and energy regardless of the type.
  	#
  	puts "Enter the number for the type of renewable production system?\n"
  	puts "1.\tPV Solar\n"
  	puts "2.\tThermal Solar\n"
  	puts "3.\tOnshore Wind\n"
  	puts "4.\tGeothermal\n"
  	puts "5.\tHydroelectric\n"
  	puts "6.\tBiomass\n"
  	print "Your Choice: "
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
    if File.exists?("Energy Report") 
    	puts "Report generated successfully!"
    end
  end

end


