# frozen_string_literal: true

require "spec_helper"

RSpec.describe Output do
  subject { described_class }

  describe "#reupload" do
    subject(:reupload) do
      described_class.reupload(models) { object.test }
    end

    let(:object) { instance_double("Test1") }
    let(:models) { [object] }

    before { allow(object).to receive(:test) }

    context "with 1 model" do
      it "is expected to call the yielded block" do
        reupload

        expect(object).to have_received(:test)
      end

      it { expect { reupload }.to output(/1 model/).to_stdout }
      it { expect { reupload }.to output(/InstanceDouble\(Test1\)/).to_stdout }
    end

    context "with 2 models" do
      let(:object2) { instance_double("Test2") }
      let(:models) { [object, object2] }

      it { expect { reupload }.to output(/2 models/).to_stdout }
      it { expect { reupload }.to output(/InstanceDouble\(Test1\)/).to_stdout }
      it { expect { reupload }.to output(/InstanceDouble\(Test2\)/).to_stdout }
    end
  end

  describe "#model" do
    subject(:model) do
      described_class.model(object) { object.test }
    end

    let(:object) { instance_double("Test1") }

    before { allow(object).to receive(:test) }

    it "is expected to call the yielded block" do
      model
      expect(object).to have_received(:test)
    end

    it { expect { model }.to output(/InstanceDouble\(Test1\)/).to_stdout }
    it { expect { model }.to output(/Done!/).to_stdout }
  end

  describe "#type" do
    subject(:type) do
      described_class.type(object, count) { object.test }
    end

    let(:object) { instance_double("Test1") }
    let(:count) { 10 }

    before { allow(object).to receive(:test) }

    it "is expected to call the yielded block" do
      type
      expect(object).to have_received(:test)
    end

    it { expect { type }.to output(/InstanceDouble\(Test1\)/).to_stdout }
    it { expect { type }.to output(/10/).to_stdout }
    it { expect { type }.to output(/Done!/).to_stdout }
  end

  describe "#print_progress_indicator" do
    subject(:print_progress_indicator) { described_class.print_progress_indicator }

    it { expect { print_progress_indicator }.to output(/\./).to_stdout }
  end
end
