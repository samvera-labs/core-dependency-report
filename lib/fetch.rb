require 'fileutils'
require 'json'
require 'csv'
require 'net/http'
require 'base64'
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
sleep_time = headers['Authorization'] ? 0.5 : 60
Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
	CSV.foreach('fixtures/partners.csv', headers: true) do |row|
		org = row['Github Org']
		search_results = JSON.load(File.read("tmp/#{org}/response.json"))['items']
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
			end
			sleep(sleep_time)
		end
	end
end

CSV.open("tmp/dates.csv", "wb") do |csv|
	csv << ["ref","date"]
	dates.each {|date| csv << date}
end