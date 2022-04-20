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

### Reuploading from one service to another

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
     rake nochmal:reupload REUPLOAD_FROM=local REUPLOAD_TO=remote # or rake nochmal:reupload[local,remote]
   ```

### Migrating from Carrierwave (Disk-Storage) to ActiveStorage

The migration from Carrierwave is mostly series manual steps, nochmal provides some advice for preparation and helps with the copying of data. No automated code-changes are made, you are the master of your ~~fate~~_app_, you are the captain of your ~~soul~~_code_. The journey includes mostly these steps:

1. Analyze your application for exisiting uploaders and needed changes
   ```bash
     rake nochmal:carrierwave:analyze
   ```
2. Change your application and test it automatically and manually
   With the provided helper, you can read from active_storage and carrierwave and upload to active_storage

3. Deploy your application with this hybrid setup

4. Reupload all carrierwave-uploads to active_storage
   ```bash
     NOCHMAL_MIGRATION=yay rake nochmal:carrierwave:migrate
   ```
   Nochmal store some metadata to allow resuming a migration if the process dies or gets interrupted. If you want to keep this data either way, you can pass the environment-variable `NOCHMAL_KEEP_METADATA` with any value:
   ```bash
     NOCHMAL_MIGRATION=yay NOCHMAL_KEEP_METADATA=any rake nochmal:carrierwave:migrate
   ```
   If you want or need to resume a migration, run the command again and follow the suggestion that works best for you.

5. Remove all remainders of carrierwave, deploy that, remove all carrierwave-uploads

## Project Scope

- [x] Works for `has_one_attached` attachments
- [x] Works for `has_many_attached` attachments
- [x] Works for single-file disk-based carrierwave-uploaders
- [ ] Does not yet work for multi-file carrierwave-uploaders
- [ ] Does not yet help you with migrating from paperclip

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
