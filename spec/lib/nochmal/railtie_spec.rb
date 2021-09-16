# frozen_string_literal: true

require "spec_helper"

RSpec.describe Nochmal::Railtie do
  before(:all) { Rails.application.load_tasks }
  subject { Rake::Task["nochmal:reupload"] }

  describe "loads the task correctly" do
    its(:name) { is_expected.to eq("nochmal:reupload") }
  end

  describe "The Task" do
    let(:reupload) { double(Reupload) }
    let(:from) { "local" }
    let(:to) { "remote" }

    before do
      ENV["REUPLOAD_FROM"] = from
      ENV["REUPLOAD_TO"] = to
    end

    it "calls #all on reupload" do
      allow(Reupload).to receive(:new).and_return(reupload)
      expect(reupload).to receive(:all)

      subject.execute
    end

    describe "without ENV variables" do
      let(:from) { nil }
      let(:to) { nil }

      it { expect { subject.execute }.to raise_error(/REUPLOAD_FROM.*required/) }
    end

    describe "with ENV variables" do
      before do
        expect(Reupload).to receive(:new).with(from: from, to: to).and_return(reupload)
        allow(reupload).to receive(:all)
      end

      describe "from given" do
        let(:to) { nil }
        it "calls Reupload.new with from" do
          subject.execute
        end
      end

      describe "from and to given" do
        it "calls Reupload.new with from and to" do
          subject.execute
        end
      end
    end
  end
end
