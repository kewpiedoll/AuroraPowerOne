#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/process_files"

# filearray = []
# x=0
# ARGV.each do |a|
# 	filearray[x] = a
#   x += 1
# end
# f = ProcessFiles.new(filearray)
#f = ProcessFiles.new("power.cht", "energy.cht")
f = ProcessFiles.new(ARGV[0], ARGV[1])
f.read_file
#f.output_report