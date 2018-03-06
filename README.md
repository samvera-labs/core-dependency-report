= (Optional) Configure a github OAuth token
The scripts will look in *./fixtures/token*, See https://github.com/settings/tokens


= Find Lock files for orgs in fixtures/partners.csv
```ruby
ruby lib/search.rb
```

= Download Gemfile.lock files
```ruby
ruby lib/fetch.rb
```

= Parse the lock files into a CSV
```ruby
ruby lib/parse.rb # expects tmp/refs/* and tmp/dates.csv
```

