require 'csv'
require 'bundler'
refs_dir = "tmp/refs"
dates = {}
candidates = {'blacklight' => 0} # just for the knowing
CSV.foreach("fixtures/candidates.csv", headers: true) { |row| candidates[row['candidate']] = 0 }
CSV.foreach("tmp/dates.csv", headers: true) { |row| dates[row['ref']] = row['date'] }
CSV.open("tmp/core-component-report.csv","wb") do |report|
	report << ["name", "feature", "patch", "lastModified"]
	Dir.entries("tmp/refs").each do |file|
		next unless file =~ /[a-z0-9]/ # skip relative paths
		date = dates[file]
		path = File.join(refs_dir, file)
		lockfile = Bundler::LockfileParser.new(File.read(path))
		candidate_specs = lockfile.specs.select { |spec| candidates.include? spec.name }
		candidate_specs.each do |spec|
			feature = spec.version.to_s.split('.')[0..1].join('.')
			report <<  [spec.name, feature, spec.version, date]
		end
	end
end