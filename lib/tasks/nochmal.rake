# frozen_string_literal: true

require_relative "../nochmal/reupload"

namespace :nochmal do
  desc "Reuploads attachments from ENV['REUPLOAD_FROM'] to ENV['REUPLOAD_TO'] or configured active_storage service"
  task :reupload, %i[from to] => :environment do |_t, args|
    from = args[:from] ||
           ENV["REUPLOAD_FROM"] ||
           raise("The ENV variable REUPLOAD_FROM is required")

    to = args[:to] ||
         ENV["REUPLOAD_TO"]

    Nochmal::Reupload.new(from: from, to: to).all
  end

  desc "List attachments that would be reuploaded from ENV['REUPLOAD_FROM']"
  task :list, [:from] => :environment do |_t, args|
    from = args[:from] ||
           ENV["REUPLOAD_FROM"] ||
           raise("The ENV variable REUPLOAD_FROM is required")

    Nochmal::Reupload.new(from: from).list
  end
end
