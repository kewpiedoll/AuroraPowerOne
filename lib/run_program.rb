require_relative "aurora_file_processor"

f = AuroraFileProcessor.new(ARGV[0], ARGV[1])
f.read_file

# this file is not part of the gem and is only needed to run the code directly from github