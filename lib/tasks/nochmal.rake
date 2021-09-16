# frozen_string_literals: true

# require_relative "../nochmal/reupload.rb"

namespace :nochmal do
  desc "Reuploads attachments from ENV['REUPLOAD_FROM'] to ENV['REUPLOAD_TO'] or configured active_storage service"
  task reupload: :environment do
    from = ENV["REUPLOAD_FROM"] || raise("The ENV variable REUPLOAD_FROM is required")
    to = ENV["REUPLOAD_TO"]

    Reupload.new(from: from, to: to).all
  end
end
