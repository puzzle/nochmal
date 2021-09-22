# Nochmal

This gem adds a rake task to your application that finds all your models that have attachments and reuploads the attachments to the newly configured (or specified) storage service.

You can use this to switch to a different storage service. The keys of the uploaded files stay the same, so your app can remain ignorant.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nochmal'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install nochmal

## Usage

1. Update your `config/storage.yml` with the new service:
   ```yaml
    local:
      service: Disk
      root: <%= Rails.root.join("storage") %>

    remote:
      service: Disk
      root: <%= Rails.root.join("tmp/remote_storage") %>
   ```
1. Update your configured storage `config/environments/production.rb`:
   ```ruby
     config.active_storage.service = :remote
   ```
1. Run the rake task:
   ```bash
     rake nochmal:reupload REUPLOAD_FROM=local REUPLOAD_TO=remote
   ```

## Project Scope

- [x] Works for `has_one_attached` attachments
- [ ] Does not yet work for `has_many_attached` attachments

## What about the name?

Imagine a little child that does something dangerous or exhausting, but yells "again!" at the end. "Nochmal" is german for "again" and uploading files is fun, but also (bandwidth) exhausting. And if we switch the storage for uploaded files, we, the devs also yell "nochmal!" at the app. The app does not care, but this gem does.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/puzzle/nochmal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/puzzle/nochmal/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Nochmal project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/puzzle/nochmal/blob/master/CODE_OF_CONDUCT.md).
