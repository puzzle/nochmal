# frozen_string_literal: true

require_relative "../nochmal/reupload"

namespace :nochmal do
  desc "Reuploads attachments from ENV['REUPLOAD_FROM'] to ENV['REUPLOAD_TO'] or configured active_storage service"
  task :reupload, %i[from to] => :environment do |_t, args|
    from = args[:from] || ENV["REUPLOAD_FROM"] || raise("The ENV variable REUPLOAD_FROM is required")
    to = args[:to] || ENV["REUPLOAD_TO"]

    Nochmal::Reupload.new(from: from, to: to).all
  end

  desc "List attachments that would be reuploaded from ENV['REUPLOAD_FROM']"
  task :list, [:from] => :environment do |_t, args|
    from = args[:from] || ENV["REUPLOAD_FROM"] || raise("The ENV variable REUPLOAD_FROM is required")

    Nochmal::Reupload.new(from: from).list
  end

  desc "Count attachments that would be reuploaded from ENV['REUPLOAD_FROM']"
  task :count, [:from] => :environment do |_t, args|
    from = args[:from] || ENV["REUPLOAD_FROM"] || raise("The ENV variable REUPLOAD_FROM is required")

    Nochmal::Reupload.new(from: from).count
  end

  desc "Migrate uploads from carrierwave to active_storage"
  # task :carrierwave_files, %i[to] => :environment do |_t, args|
  task :carrierwave, %i[to] => :environment do |_t, args|
    from = "unused-but-call-me-ishmael" # is carrierwave-migration my white whale?
    to = args[:to] || ENV["REUPLOAD_TO"]

    Nochmal::Reupload.new(from: from, to: to, helper: Nochmal::Adapters::CarrierwaveMigration.new).migrate
  end

  desc "Count uploads from carrierwave to active_storage"
  # task :carrierwave_files, %i[to] => :environment do |_t, args|
  task :carrierwave_count, %i[to] => :environment do |_t, args|
    from = "unused-but-call-me-ishmael" # is carrierwave-migration my white whale?
    to = args[:to] || ENV["REUPLOAD_TO"]

    Nochmal::Reupload.new(from: from, to: to, helper: Nochmal::Adapters::CarrierwaveMigration.new).count
  end

  # desc "Things that need to be done to migrate from carrierwave to active_storage"
  # task :carrierwave, %i[to] => :environment do |_t, args|
  #   to = args[:to] || ENV["REUPLOAD_TO"]
  #   Rake::Task["nochmal:carrierwave_files"].call(to)
  #   # generate migration to change attachment-name (remove carrierwave_ prefix)
  #   # change mount_uploader to has_one_attached
  #   # list view containing calls to image-helpers
  # end
end
