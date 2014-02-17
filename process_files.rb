readin = []
File.open("energy.cht") do |f|
	readin = f.each.to_a
end
readin.each {|x| puts x}

# understand that a power file has "W" as the first line
# understand that an energy file has "Wh" as the first line

# both files: skip lines 2-5
# both files, enter left-of-semicolon as key and right-of-semicolon in different has tables