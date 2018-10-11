require 'fileutils'
require 'json'
require 'csv'
require 'net/http'
require 'base64'
def sleep_time(http, headers)
	rate_uri = URI("https://api.github.com/rate_limit")
	result = headers['Authorization'] ? 0.5 : 60
	now = Time.now.to_i - 1 # I'm nervous about clock synching
	remaining = 0
	http.request_get(rate_uri, headers) do |response|
		rate_info = JSON.load(response.body)
		result = rate_info.fetch("rate",{})["reset"] || now + result
		result = result - now
		remaining = rate_info.fetch("rate",{})["remaining"] || 0
	end
	remaining > 0 ? 0 : result
end

headers = {
	'Accept' => "application/vnd.github.v3.text-match+json"
}
fetch_endpoint = "https://api.github.com/repositories"
if File.exist?("fixtures/token")
	headers['Authorization'] = "token " + File.read("fixtures/token")
end
uri = URI(fetch_endpoint)
dates = {}
FileUtils.mkdir_p("tmp/refs")
# rate limits: 5000/hr for OAuth, 60/hour without
counter = 0
Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
	CSV.foreach('fixtures/partners.csv', headers: true) do |row|
		org = row['Github Org']
		search_results = JSON.load(File.read("tmp/#{org}/response.json"))['items'] || []
		puts "#{org} had no items" unless search_results[0]
		links = search_results.map {|result| result['url'] }
		links.each do |link|
			uri = URI(link)
			parms = URI.decode_www_form(uri.query)
			ref = parms.detect {|parm| parm[0] == 'ref'}
			http.request_get(uri, headers) do |response|
				date = Date._httpdate(response['Last-Modified'])
				dates[ref[1]] = Date.new(date[:year],date[:mon],date[:mday]).to_s
				open("tmp/refs/#{ref[1]}",'wb') do |blob|
					file_info = JSON.load(response.body)
					enc = file_info['content']
					blob.write(Base64.decode64(enc))
				end
				counter += 1
			end
			if counter > 2_000
				time = sleep_time(http, headers)
				if time > 0
					sleep(time)
					counter = 0
				end
			end
		end
	end
end

CSV.open("tmp/dates.csv", "wb") do |csv|
	csv << ["ref","date"]
	dates.each {|date| csv << date}
end