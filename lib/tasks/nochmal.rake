# frozen_string_literals: true

require "./lib/nochmal/reupload.rb"

namespace :nochmal do
  desc "Reuploads attachments from ENV['FROM'] to ENV['TO'] or configured active_storage service"
  task reupload: :environment do
    from = ENV["FROM"]
    to = ENV["TO"]

    Reupload.new(from: from, to: to).all
  end
end
