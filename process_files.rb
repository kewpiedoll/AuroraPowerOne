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

	def initialize(file_name1, file_name2)
		@filename = [file_name1, file_name2]
		p @filename.class
	end

  # can't close the file (??)
  def read_file
  	file_count = 0
    File.open(@filename[file_count], 'r') do |line|
	    @readin = line.each.to_a
    end
    file_count += 1
    @readin.map! {|s| s.chomp}
  	if @readin[0] =~ /Wh/
  	  @parsed_power = false		
  		parse_energy
  	else @readin[0] =~ /W/
  		@parsed_energy = false	
  		parse_power
  	end
  end

  def parse_hash 
  	hash = {}
  	temp_array = @readin[5, @readin.length]
  	temp_array.each do |s|
  		k,v = s.split(/;/)
  		hash[Time.at(k.to_i - 62167104000)] = v.to_f
  	end
  	return hash
  end

  def parse_energy
  	@parsed_energy = true
  	if !@parsed_power
  		parse_power
  	end
  	energy_hash = parse_hash
  	#total energy produced
  	temp_array = []
  	temp_array = energy_hash.to_a
  	# runtime in hours
  	@energy_run_time = (temp_array[temp_array.length - 1][0] - temp_array[0][0])/3600.0
  	# energy in Wh
  	@energy_amount = (temp_array[temp_array.length - 1][1] - temp_array[0][1])
  	puts "Enter the number for the type of renewable production system?\n"
  	puts "1.\tPV Solar\n"
  	puts "2.\tThermal Solar\n"
  	puts "3.\tOnshore Wind\n"
  	puts "4.\tGeothermal\n"
  	puts "5.\tHydroelectric\n"
  	puts "6.\tBiomass\n"
  	warning = ""
		input = gets.chomp
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
  	output_file = File.open("Energy Report", 'w+') 
  	output_file.write("ENERGY REPORT\n")
  	output_file.write("Energy System Type: #{warning} #{@system_type.to_s.humanize}\n\n")
  	output_file.write("Total Operating Time:  #{@energy_run_time} hours\n")
    output_file.write("Total Energy Produced: #{@energy_amount} Wh\n")
    output_file.write("Your power range was #{@min_power} to #{@max_power} W.\n\n")
    output_file.write("Carbon Productivity-Sequestration:\n")
    output_file.write("#{@system_type.to_s.humanize} Rating: #{ENERGY_TYPES[@system_type]} g CO2 per kWh\n")
    output_file.write("US Average: #{CO2_USGRID} g CO2 per kWh\n")
    output_file.write("Your energy production resulted in #{@carbon_savings.to_i} g net " \
    	"CO2 Productivity-Sequestration\n")
    output_file.close
  end



  def parse_power
  	read_file
  	power_hash = parse_hash
  	p power_hash
  	@max_power = power_hash.values.max
  	@min_power = power_hash.values.min
  	@parsed_power = true
  	if !@parsed_energy
      parse_energy
    end
  end

end

f = ProcessFiles.new("energy.cht", "power.cht")
f.read_file



# understand that a power file has "W" as the first line
# understand that an energy file has "Wh" as the first line

# both files: skip lines 2-5
# both files, enter left-of-semicolon as key and right-of-semicolon in different has tablesreadin = []