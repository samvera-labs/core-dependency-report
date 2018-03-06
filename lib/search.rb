require 'fileutils'
require 'csv'
require 'net/http'
headers = {
	'Accept' => "application/vnd.github.v3.text-match+json"
}
search_endpoint = "https://api.github.com/search/code"
if File.exist?("fixtures/token")
	headers['Authorization'] = "token " + File.read("fixtures/token")
end
# rate limit 30/minute with OAuth, 10/minute without
sleep_time = headers['Authorization'] ? 2 : 6
uri = URI(search_endpoint)
Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
	CSV.foreach('fixtures/partners.csv', headers: true) do |row|
		org = row['Github Org']
		FileUtils.mkdir_p("tmp/#{org}")
		params = {
			q: "org:#{org} filename:Gemfile.lock",
			per_page: "100"
		}
		query = URI.encode_www_form(params)
		path = "#{uri.path}?#{query}"
		response = http.get("#{uri.path}?#{query}", headers)
		open("tmp/#{org}/response.json", 'wb') { |blob| blob.write(response.body) }
		sleep(sleep_time)
	end
end