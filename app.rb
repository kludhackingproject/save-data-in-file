
require 'bundler'
Bundler.require

$:.unshift File.expand_path("./../lib", __FILE__)
#require 'app/google_spreadsheets'
require 'app/scrappeur'

Scrappeur.new.perform
#GoogleSpreadsheets.new
