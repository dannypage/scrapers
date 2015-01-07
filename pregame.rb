#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'cgi'
require 'fileutils'
require "date"

begin
	date = '20131229'

	output = File.open("pregame_results_2013.csv","w")

	output << 'date,pro,sport,pick,score,odds,size,wl,result\n'

	while date != '20121231'
		puts "Working on #{date}."

		doc = Nokogiri::HTML(open("http://pregame.com/pregamepros/picks/date.aspx?date=#{date}"))
		a = doc.xpath('//*[@id="contmain"]/div/div[3]')

		start = 3

		ending = a.children.count

		while start < ending

			b = a.xpath("./div[#{start}]")


			result_date = Date.strptime(date,'%Y%m%d')
			result_date = '"' + result_date.strftime('%m/%d/%Y') + '"'
			pro = '"' + b.xpath('./div[1]').text.gsub(/(\r\n(\s)+)/,'').sub(/\u00a0/,'').strip + '"'
			sport = '"' + b.xpath('./div[2]').text.gsub(/(\r\n(\s)+)/,'').sub(/\u00a0/,'').strip + '"'
			pick = '"' + b.xpath('./div[3]').text.gsub(/(\r\n(\s)+)/,'').sub(/\u00a0/,'').strip + '"'
			score = '"' + b.xpath('./div[4]').text.gsub(/(\r\n(\s)+)/,'').sub(/\u00a0/,'').strip + '"'
			odds = '"' + b.xpath('./div[5]').text.gsub(/(\r\n(\s)+)/,'').sub(/\u00a0/,'').strip + '"'
			size = '"' + b.xpath('./div[6]').text.gsub(/(\r\n(\s)+)/,'').sub(/\u00a0/,'').strip + '"'
			wl = '"' + b.xpath('./div[7]').text.gsub(/(\r\n(\s)+)/,'').sub(/\u00a0/,'').strip + '"'
			result = '"' + b.xpath('./div[8]').text.gsub(/(\r\n(\s)+)/,'').sub(/\u00a0/,'').strip + '"'

			start += 1

			if pro != ''
				output << [result_date,pro,sport,pick,score,odds,size,wl,result].join(',')
				output << "\n"
			end
		end

		d = Date.strptime(date,'%Y%m%d')
		d -= 1
		date = d.strftime('%Y%m%d')
	end

	output.close
	
end