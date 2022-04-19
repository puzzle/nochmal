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

  namespace :carrierwave do
    desc "Analyse uploaders and suggest change to migrate from carrierwave to active_storage"
    task :analyze, %i[to] => :environment do |_t, args|
      to = args[:to] || ENV["REUPLOAD_TO"]

      Nochmal::Reupload.new(from: :unused, to: to, helper: Nochmal::Adapters::CarrierwaveAnalyze.new).all
    end

    desc "Migrate uploads from carrierwave to active_storage"
    task :migrate, %i[to] => :environment do |_t, args|
      to = args[:to] || ENV["REUPLOAD_TO"]

      Nochmal::Reupload.new(from: :unused, to: to, helper: Nochmal::Adapters::CarrierwaveMigration.new).all
    end

    desc "Resume uploads from carrierwave to active_storage"
    task :resume, %i[to] => :environment do |_t, args|
      to = args[:to] || ENV["REUPLOAD_TO"]

      Nochmal::Reupload.new(from: :unused, to: to, helper: Nochmal::Adapters::CarrierwaveResume.new).all
    end

    desc "Count uploads to be migrated from carrierwave to active_storage"
    task :count, %i[to] => :environment do |_t, args|
      to = args[:to] || ENV["REUPLOAD_TO"]

      Nochmal::Reupload.new(from: :unused, to: to, helper: Nochmal::Adapters::CarrierwaveMigration.new).count
    end
  end
end
