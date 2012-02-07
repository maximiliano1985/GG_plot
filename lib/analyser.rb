#!/usr/bin/env ruby
#
#************************************************************
#
#Program:      GGplot
#
#File:         analyser.rb
#
#Description:  Module with methods for data analysis
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

require 'gnuplotr'
require 'pp'
require 'matrix'

Folder = File.dirname __FILE__

# The smartphone HTC Sensation is placed vertically,
# with the upper edge inclined in the direction of
# travel of aproximately 25 °
########################################
Pitch = 0 # (degrees) corrects the orientation of the smartphone due to the inclination of the support
Yaw = 0
Roll = -25
########################################

G = 9.81 # (m/s^2)

# Analyser module
# @author cmgb
module Analyser
  include Math
  
  # Evaluates the mean value of the elements in the array
  # @return [Float]
  # @author cmgb
  def mean
    begin
      self.inject {|sum,i| sum.to_f + i} / size
    rescue
      nil
    end
  end
  
  # Loads file data in "csv" format
  # @param [String] file_name the name of the file to be read
  # @author cmgb
  def load_data(file_name)
    data = {}
    header = true
    File.open(File.join(Folder, "../data/"+file_name), 'r') do |file|
      file.each do |line|
        tokens = line.split(";")
        if header
          KEYS.each{|key| data[key] = []}
          header = false
        else
          i = 0
          data.each_key{|k| data[k] << tokens[i].to_f; i+=1}
        end # if
      end # file.each
    end # File.open
    
    return data
  end # load_data
  
  # Corrects the accelerometer data accordingly to the smartphone orientation
  # @param [Hash] data the acquired data
  # @author cmgb
  def correct_data(data)
    # This is done to have a right-handed frame
    data[:ay].collect!{|el| -el}
    # Now: +X points to Left, +Y points up, + Z points ahead
    
    # Correct the inclination of the support for the smartphone
    ap = Pitch*PI/180.0 # (rad)
    rpitch = Matrix[[cos(ap),0.0,sin(ap)], [0.0, 1.0, 0.0], [-sin(ap), 0.0, cos(ap)]] # pitch
    
    ar = Roll*PI/180.0 # (rad)
    rroll = Matrix[[1.0,0.0,0.0], [0.0, cos(ar), sin(ar)], [0.0, -sin(ar), cos(ar)]] # roll
    
    ay = Yaw*PI/180.0 # (rad)
    ryaw = Matrix[[cos(ay), -sin(ay), 0.0], [sin(ay), cos(ay), 0.0], [0.0, 0.0, 1.0]] # roll
    
    [:long, :later, :vert].each{|k| data[k] = []}
    data[:ax].each_with_index do |el,ind|
      vec  = Vector[data[:ax][ind], data[:ay][ind], data[:az][ind]]/G
      vecn = ryaw*rpitch*rroll*vec
      #p vecn
      # convert the point in the car frame
      data[:long]  << vecn[2]
      data[:later] << -vecn[0]
      data[:vert]  << vecn[1]
      #p "long #{data[:long].last}, lat #{data[:later].last}, vert #{data[:vert].last}"
    end # index
    
    means = [data[:long].mean, data[:later].mean, data[:vert].mean] 
      [:long, :later, :vert].each_with_index do |k, i|
      data[k].collect!{|el| el-means[i]}  
    end
    return data
  end # correct_data
  
  # Plots the gg plot with the gnuplotr library
  # @param [Hash] data the acquired data
  # @author cmgb
  def plot(data)
    ggplot = GNUPlotr.new
    ggplot.raw "set terminal aqua size 600,600"
    ggplot.new_series(:gg)
    data[:ax].each_with_index{|ax, ind| ggplot.series[:gg] << [data[:long][ind], data[:later][ind]] }
    ggplot.series[:gg].close
    ggplot.set_xlabel "Longitudinal acceleration (g)"
    ggplot.set_xrange -1..1
    ggplot.set_ylabel "Lateral acceleration (g)"
    ggplot.set_yrange -1..1
    ggplot.set_grid
    ggplot.set_title 'GG plot, Trento-Levico, Ford Fiesta mk6 1.4 TDI'
    ggplot.plot :gg

    sleep(0.1)
    system "rm *.dat"
  end # plot
  
end # module