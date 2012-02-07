require 'rubygems'
require 'mechanize'
require 'highline/import'
require 'progressbar'

puts "\n===================================="
puts "Runkeeper activity downloader"
puts "===================================="

username = ask("Please enter your username:  ")
password = ask("Please enter your password:  ") { |q| q.echo = "*" }

puts "Please wait..."

agent = Mechanize.new
page = agent.get('http://runkeeper.com/login')
login_form = page.form('loginForm')
login_form.email = username
login_form.password = password

page = agent.submit(login_form, login_form.buttons.first)
page = agent.click(page.link_with(:text => /Activities/))

begin
  Dir::mkdir('gpx')
rescue
  # Directory exists
end

begin
  Dir::mkdir('kml')
rescue
  # Directory exists
end

pbar = ProgressBar.new("Downloading", page.search('div.activityMonth').size)
page.search('div.activityMonth').each_with_index do |div, i|
  if div.attributes["link"].value =~ /user\/.*\/activity\/(\d*)/
    unless File.exist? "./gpx/#{$1}.gpx"
      agent.get("http://runkeeper.com/download/activity?activityId=#{$1}&downloadType=gpx").save_as "./gpx/#{$1}.gpx"
    end
    unless File.exist? "./kml/#{$1}.kml"
      agent.get("http://runkeeper.com/download/activity?activityId=#{$1}&downloadType=googleEarth").save_as "./kml/#{$1}.kml"
    end
    pbar.inc
  end
end
pbar.finish