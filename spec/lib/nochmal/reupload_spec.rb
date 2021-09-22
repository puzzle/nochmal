# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Reupload do
  subject(:instance) { described_class.new(from: :local, to: :remote, helper: helper) }

  let(:helper) { instance_double(ActiveStorageHelper) }
  let(:model)  { instance_double("User") }
  let(:models) { instance_double("Users") }
  let(:type)   { instance_double("Avatar") }
  let(:blob)   { instance_double("Blob") }
  let(:local)  { instance_double("LocalService") }
  let(:remote) { instance_double("RemoteService") }

  before do
    stub_helper
    stub_models
    stub_output
  end

  describe "#all" do
    subject(:all) { instance.all }

    before do
      allow(local).to receive(:download).and_return("content")
      allow(remote).to receive(:upload)
    end

    it "calls the from service to download the file" do
      all

      expect(local).to have_received(:download).with("test")
    end

    it "calls the to service to upload the file" do
      all

      expect(remote).to have_received(:upload)
    end

    context "without passed helper" do
      let(:helper) { nil }

      it { expect { all }.not_to raise_error }
    end
  end

  def stub_helper
    return unless helper

    allow(helper).to receive(:models_with_attachments).and_return([model])
    allow(helper).to receive(:attachment_types_for).with(model).and_return(["avatar"])
    allow(helper).to receive(:storage_service).with(:local).and_return(local)
    allow(helper).to receive(:storage_service).with(:remote).and_return(remote)
  end

  def stub_models
    allow(models).to receive(:count).and_return(10)
    allow(models).to receive(:find_each).and_yield(model)
    allow(model).to receive(:with_attached_avatar).and_return(models)
    allow(model).to receive(:avatar).and_return(type)
    allow(type).to receive(:to_str).and_return("avatar")
    allow(type).to receive(:blob).and_return(blob)
    allow(blob).to receive(:key).and_return("test")
  end

  def stub_output
    # Silence Output in tests
    allow(Output).to receive(:reupload).and_yield
    allow(Output).to receive(:model).and_yield
    allow(Output).to receive(:type).and_yield
    allow(Output).to receive(:print_progress_indicator)
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
