# frozen_string_literal: true

require "spec_helper"

RSpec.describe Nochmal::ActiveStorageHelper do
  let(:user) { instance_double("User") }
  let(:blob) { instance_double("Blob") }
  let(:avatar) { instance_double("Avatar") }
  let(:avatar_association) { instance_double("AvatarAssociation") }

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
    subject(:models) { described_class.new.models_with_attachments }

    context "when user has attachments" do
      before { prepare_models }

      it { is_expected.not_to include blob }
      it { is_expected.to include user }
    end

    context "when association is polymorphic" do
      before do
        prepare_models
        allow(avatar_association).to receive(:options).and_return(polymorphic: true)
      end

      it { is_expected.not_to include user }
    end

    it "is memoized" do
      allow(ActiveRecord::Base).to receive(:descendants).once.and_return([])

      models
      models

      expect(ActiveRecord::Base).to have_received(:descendants)
    end
  end

  describe "#attachment_types_for" do
    subject(:types) { described_class.new.attachment_types_for(user) }

    context "when user has attachments" do
      before do
        prepare_models
        prepare_types
      end

      it { is_expected.not_to include("test") }
      it { is_expected.to include("avatar") }
    end

    it "is memoized" do
      allow(user).to receive(:methods).once.and_return([])

      types
      types

      expect(user).to have_received(:methods)
    end
  end

  def prepare_models
    descendants = [user, blob]
    associations = [avatar_association]
    allow(ActiveRecord::Base).to receive(:descendants).and_return(descendants)
    allow(user).to receive(:abstract_class?).and_return(false)
    allow(user).to receive(:reflect_on_all_associations).and_return(associations)
    allow(blob).to receive(:abstract_class?).and_return(false)
    allow(blob).to receive(:reflect_on_all_associations).and_return(associations)
    allow(blob).to receive(:is_a?).and_return(ActiveStorage::Blob)
    allow(avatar_association).to receive(:klass).and_return(ActiveStorage::Attachment)
    allow(avatar_association).to receive(:options).and_return({})
  end

  def prepare_types
    allow(user).to receive(:methods).and_return(%i[test with_attached_avatar])
  end
end
