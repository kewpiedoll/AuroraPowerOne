#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/process_files"

f = ProcessFiles.new(ARGV[0], ARGV[1])
f.read_file