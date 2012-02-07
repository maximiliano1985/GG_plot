#!/usr/bin/env ruby
#
#************************************************************
#
#Program:      GGplot
#
#File:         GGplot.rb
#
#Description:  Makes the GG plot of accelerometers data
#
#Author:       Carlos Maximiliano Giorgio Bort (cmgb)
#
#Environment:  ruby 1.9.2p290 (2011-07-09 revision 32553)
#              [x86_64-darwin10.8.0]
#
#Notes:        Copyright (c) 2012 Carlos Maximiliano Giorgio Bort.
#              All rights reserved.
#
#Revisions:    1.00  03/07/12 (cmgb) First release
#
#************************************************************ 

folder = File.dirname __FILE__
require File.join(folder, "../lib/analyser.rb")

include Analyser

KEYS = [:ax, :ay, :az,
        :gx, :gy, :gz,
        :mx, :my, :mz,
        :ox, :oy, :oz,
        :T, :livB,
        :Volt, :t]

raw_data = load_data "trento_levico.csv"
data = correct_data raw_data

plot data

