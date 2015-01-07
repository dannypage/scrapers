#!/usr/bin/env ruby
 
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'diffy'
 
def clean_up(year, transaction)
  transaction = transaction.gsub!(/IN:/,'') || transaction
  transaction = transaction.gsub!(/OUT:/,'') || transaction
  transaction = transaction.gsub('"',' ') || transaction
  transaction = transaction.gsub("\u00A0",' ')
  transaction = transaction.strip! || transaction
  transaction
end
 
years = [2012,2013,2014]
today = Time.now.strftime("%FT%R")
prior_csv = Dir.glob('*-mls-transactions.csv').max_by {|f| File.mtime(f)}
 
CSV.open("#{today}-mls-transactions.csv", 'wb') do |csv|
  years.each do |year|
    doc = Nokogiri.parse(open("http://www.mlssoccer.com/transactions/#{year}"))
    table = doc.search('tbody')
 
    table.xpath('./tr').each do |team|
      team_td = team.search('img')
      team_pic_uri = team_td.attribute('src').to_s
      team_name = URI.parse(team_pic_uri).path.split('/').last
      team_in = team.xpath('./td[2]/p').text.split(';')
      team_out = team.xpath('./td[3]/p').text.split(';')
 
      if year == 2013 || year == 2014
        players_in = team_in[0].split("\t\t\t\t\t")
        players_out = team_out[0].split("\t\t\t\t\t")
      else
        players_in = team_in
        players_out = team_out
      end
 
      players_in.each do |transaction|
        cleaned = clean_up(year, transaction)
        unless cleaned.strip.empty?
          csv << [year.to_s, team_name, 'IN', cleaned]
        end
      end
      players_out.each do |transaction|
        cleaned = clean_up(year, transaction)
        unless cleaned.strip.empty?
          csv << [year.to_s, team_name, 'OUT', cleaned.to_s]
        end
      end
    end
  end
end
 
new_csv = Dir.glob('*-mls-transactions.csv').max_by {|f| File.mtime(f)}
 
if prior_csv && prior_csv != new_csv
  if FileUtils.identical?(prior_csv, new_csv)
    FileUtils.rm new_csv
  else
    output = File.open( "#{today}-diff.html","w")
    output << Diffy::Diff.new(prior_csv, new_csv, :source => 'files',
                              :include_plus_and_minus_in_html => true,
                              :context => 0).to_s(:color)
    output.close
  end
end
