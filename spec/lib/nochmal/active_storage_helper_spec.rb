# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveStorageHelper do
  let(:user) { double("User") }
  let(:blob) { double("Blob") }
  let(:descendants) { [user, blob] }

  let(:avatar) { double("Avatar") }
  let(:avatar_association) { double("AvatarAssociation") }
  let(:associations) { [avatar_association] }

  let(:location) { Pathname.new(__dir__).dirname.dirname.dirname.expand_path }

  describe "#storage_service" do
    subject { described_class.new.storage_service }

    it { is_expected.to be_a ActiveStorage::Service::DiskService }
    its(:root) { is_expected.to eq "#{location}/spec/dummy/tmp/storage" }

    context "with the :remote service" do
      subject { described_class.new.storage_service(:remote) }
      its(:root) { is_expected.to eq "#{location}/spec/dummy/tmp/remote_storage" }
    end
  end

  describe "#models_with_attachments" do
    subject { described_class.new.models_with_attachments }

    context "when user has attachments" do
      before { prepare_models }

      it { is_expected.not_to include blob }
      it { is_expected.to include user }
    end

    it "should be memoized" do
      expect(ActiveRecord::Base).to receive(:descendants).once.and_return([])
      subject
      subject
    end
  end

  describe "#attachment_types_for" do
    subject { described_class.new.attachment_types_for(user) }

    context "when user has attachments" do
      before do
        prepare_models
        prepare_types
      end

      it { is_expected.not_to include("test") }
      it { is_expected.to include("avatar") }
    end

    it "should be memoized" do
      expect(user).to receive(:methods).once.and_return([])
      subject
      subject
    end
  end

  def prepare_models
    allow(ActiveRecord::Base).to receive(:descendants).and_return(descendants)
    allow(user).to receive(:abstract_class?).and_return(false)
    allow(user).to receive(:reflect_on_all_associations).and_return(associations)
    allow(blob).to receive(:abstract_class?).and_return(false)
    allow(blob).to receive(:reflect_on_all_associations).and_return(associations)
    allow(blob).to receive(:is_a?).and_return(ActiveStorage::Blob)
    allow(avatar_association).to receive(:klass).and_return(ActiveStorage::Attachment)
  end

  def prepare_types
    allow(user).to receive(:methods).and_return(%i[test with_attached_avatar])
  end
end
