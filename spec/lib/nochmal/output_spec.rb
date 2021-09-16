# frozen_string_literal: true

require "spec_helper"

RSpec.describe Output do
  subject { described_class }

  describe "#reupload" do
    let(:object) { double("Test1") }
    let(:models) { [object] }
    let(:reupload) do
      described_class.reupload(models) { object.test }
    end

    subject { -> { reupload } }

    before { expect(object).to receive(:test) }

    context "with 1 model" do
      it { is_expected.to output(/1 model/).to_stdout }
      it { is_expected.to output(/Double \"Test1\"/).to_stdout }
    end

    context "with 2 models" do
      let(:object2) { double("Test2") }
      let(:models) { [object, object2] }

      it { is_expected.to output(/2 models/).to_stdout }
      it { is_expected.to output(/Double \"Test1\"/).to_stdout }
      it { is_expected.to output(/Double \"Test2\"/).to_stdout }
    end
  end

  describe "#model" do
    let(:object) { double("Test1") }
    let(:model) do
      described_class.model(object) { object.test }
    end

    subject { -> { model } }

    before { expect(object).to receive(:test) }

    it { is_expected.to output(/Double \"Test1\"/).to_stdout }
    it { is_expected.to output(/Done!/).to_stdout }
  end

  describe "#type" do
    let(:object) { double("Test1") }
    let(:count) { 10 }
    let(:type) do
      described_class.type(object, count) { object.test }
    end

    subject { -> { type } }

    before { expect(object).to receive(:test) }

    it { is_expected.to output(/Double \"Test1\"/).to_stdout }
    it { is_expected.to output(/10/).to_stdout }
    it { is_expected.to output(/Done!/).to_stdout }
  end

  describe "#print_progress_indicator" do
    let(:print_progress_indicator) { described_class.print_progress_indicator }
    subject { -> { print_progress_indicator } }

    it { is_expected.to output(/\./).to_stdout }
  end
end
