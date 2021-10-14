# (Optional) Configure a github OAuth token
The scripts will look in *./fixtures/token*, See https://github.com/settings/tokens


# Find Lock files for orgs in fixtures/partners.csv
```ruby
ruby lib/search.rb
```

# Download Gemfile.lock files
```ruby
ruby lib/fetch.rb
```

# Parse the lock files into a CSV
```ruby
ruby lib/parse.rb # expects tmp/refs/* and tmp/dates.csv
```

# Contributing 

If you're working on a PR for this project, create a feature branch off of `main`. 

This repository follows the [Samvera Community Code of Conduct](https://samvera.atlassian.net/wiki/spaces/samvera/pages/405212316/Code+of+Conduct) and [language recommendations](https://github.com/samvera/maintenance/blob/master/templates/CONTRIBUTING.md#language).  Please ***do not*** create a branch called `master` for this repository or as part of your pull request; the branch will either need to be removed or renamed before it can be considered for inclusion in the code base and history of this repository.
