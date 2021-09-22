# frozen_string_literal: true

require_relative "../nochmal/reupload"

namespace :nochmal do
  desc "Reuploads attachments from ENV['REUPLOAD_FROM'] to ENV['REUPLOAD_TO'] or configured active_storage service"
  task reupload: :environment do
    from = ENV["REUPLOAD_FROM"] || raise("The ENV variable REUPLOAD_FROM is required")
    to = ENV["REUPLOAD_TO"]

    Nochmal::Reupload.new(from: from, to: to).all
  end
end
