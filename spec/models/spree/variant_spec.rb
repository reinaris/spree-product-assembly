require 'spec_helper'

module Spree
  describe Variant do
    context "filter assemblies" do
      let(:mug) { create(:product) }
      let(:tshirt) { create(:product) }
      let(:variant) { create(:variant) }

      context "variant has more than one assembly" do
        before { variant.assemblies.push [mug, tshirt] }

        it "returns both products" do
          expect(variant.assemblies_for([mug, tshirt])).to include mug
          expect(variant.assemblies_for([mug, tshirt])).to include tshirt
        end

        it { expect(variant).to be_a_part }
      end

      context "variant no assembly" do
        it "returns both products" do
          variant.assemblies_for([mug, tshirt]).should be_empty
        end
      end
    end

    context "#can_supply?" do
      include_context "product is ordered as individual and within a bundle"

      before { bundle.parts.each { |v| bundle.set_part_count(v, 2) } }

      it "should call itself for each part" do
        bundle.parts.each do |part|
          expect(part).to receive(:can_supply?).with(3 * 2).and_return(true)
        end

        bundle_variant.can_supply?(3)
      end
    end

  end
end
