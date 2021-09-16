# frozen_string_literal: true

require "spec_helper"

RSpec.describe Reupload do
  let(:helper) { double(ActiveStorageHelper) }
  let(:model)  { double("User") }
  let(:models) { double("Users") }
  let(:type)   { double("Avatar") }
  let(:blob)   { double("Blob") }
  let(:local)  { double("LocalService") }
  let(:remote) { double("RemoteService") }

  before do
    stub_helper
    stub_models
    stub_output
  end

  subject(:instance) { described_class.new(from: :local, to: :remote, helper: helper) }

  describe "#all" do
    subject { instance.all }

    it "should call the from service to download the file" do
      expect(local).to receive(:download).with("test").and_return("content")
      expect(remote).to receive(:upload)
      subject
    end

    context "without passed helper" do
      let(:helper) { nil }

      it { expect { subject }.not_to raise_error }
    end
  end

  def stub_helper
    if helper
      allow(helper).to receive(:models_with_attachments).and_return([model])
      allow(helper).to receive(:attachment_types_for).with(model).and_return(["avatar"])
      allow(helper).to receive(:storage_service).with(:local).and_return(local)
      allow(helper).to receive(:storage_service).with(:remote).and_return(remote)
    end
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
