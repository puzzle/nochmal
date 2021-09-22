# frozen_string_literal: true

require "spec_helper"

RSpec.describe Nochmal::Railtie do
  subject(:task) { Rake::Task["nochmal:reupload"] }

  before(:all) { Rails.application.load_tasks } # rubocop:disable RSpec/BeforeAfterAll

  describe "loads the task correctly" do
    its(:name) { is_expected.to eq("nochmal:reupload") }
  end

  describe "The Task" do
    let(:reupload) { instance_double(Reupload) }
    let(:from) { "local" }
    let(:to) { "remote" }

    before do
      ENV["REUPLOAD_FROM"] = from
      ENV["REUPLOAD_TO"] = to

      allow(Reupload).to receive(:new).and_return(reupload)
      allow(reupload).to receive(:all)
    end

    it "calls #all on reupload" do
      allow(Reupload).to receive(:new).and_return(reupload)
      allow(reupload).to receive(:all)

      task.execute

      expect(reupload).to have_received(:all)
    end

    describe "without ENV variables given" do
      let(:from) { nil }
      let(:to) { nil }

      it { expect { task.execute }.to raise_error(/REUPLOAD_FROM.*required/) }
    end

    describe "with from ENV variable given" do
      let(:to) { nil }

      it "calls Reupload.new with from" do
        task.execute
        expect(Reupload).to have_received(:new).with(from: from, to: to)
      end
    end

    describe "with from and to ENV variable given" do
      it "calls Reupload.new with from and to" do
        task.execute
        expect(Reupload).to have_received(:new).with(from: from, to: to)
      end
    end
  end
end
