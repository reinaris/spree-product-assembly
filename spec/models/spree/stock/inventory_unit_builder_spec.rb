require 'spec_helper'

describe Spree::Stock::InventoryUnitBuilder do
  subject { described_class.new(order) }

  describe "#units" do

    describe "without product assemblies" do
      let(:line_item_1) { build(:line_item) }
      let(:line_item_2) { build(:line_item, quantity: 2) }
      let(:order) { build(:order, line_items: [line_item_1, line_item_2]) }

      it "returns an inventory unit for each quantity for the order's line items" do
        units = subject.units
        expect(units.count).to eq 3
        expect(units.first.line_item).to eq line_item_1
        expect(units.first.variant).to eq line_item_1.variant

        expect(units[1].line_item).to eq line_item_2
        expect(units[1].variant).to eq line_item_2.variant

        expect(units[2].line_item).to eq line_item_2
        expect(units[2].variant).to eq line_item_2.variant
      end

      it "builds the inventory units as pending" do
        expect(subject.units.map(&:pending).uniq).to eq [true]
      end

      it "associates the inventory units to the order" do
        expect(subject.units.map(&:order).uniq).to eq [order]
      end
    end

    describe "with product assemblies" do
      include_context "product is ordered as individual and within a bundle"

      before { bundle.set_part_count(parts.first, 3) }

      it "returns an inventory_unit per line_item per per part quantity" do
        units = subject.units
        expect(units.count).to eq 7 # (3 + 1 + 1 + 1) + 1

        bundle_line_item = order.line_items.first
        normal_line_item = order.line_items.last

        (0..2).each do |i|
          expect(units[i].line_item).to eq bundle_line_item
          expect(units[i].variant).to eq bundle.parts[0]
        end

        expect(units[3].line_item).to eq bundle_line_item
        expect(units[3].variant).to eq bundle.parts[1]

        expect(units[4].line_item).to eq bundle_line_item
        expect(units[4].variant).to eq bundle.parts[2]

        expect(units[5].line_item).to eq bundle_line_item
        expect(units[5].variant).to eq bundle.parts[3]

        expect(units[6].line_item).to eq normal_line_item
      end

      it "builds the inventory units as pending" do
        expect(subject.units.all?(&:pending?)).to eq true
      end

      it "associates the inventory units to the order" do
        expect(subject.units.map(&:order).uniq).to eq [order]
      end
    end
  end
end
