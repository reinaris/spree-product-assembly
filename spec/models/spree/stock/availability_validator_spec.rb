require 'spec_helper'

describe Spree::Stock::AvailabilityValidator do
  include_context "product is ordered as individual and within a bundle"

  let(:line_item) { order.line_items.first }

  subject { described_class.new }

  it 'should be valid when supply is sufficient' do
    allow_any_instance_of(Spree::Stock::Quantifier).to receive(:can_supply?) { true }
    expect(line_item).not_to receive(:errors)
    subject.validate(line_item)
  end

  it 'should be invalid when supply is insufficent' do
    allow_any_instance_of(Spree::Stock::Quantifier).to receive(:can_supply?) { false }
    expect(line_item.errors).to receive(:[]).exactly(4).times.with(:quantity).and_return([])
    subject.validate(line_item)
  end

  it 'should consider existing inventory_units sufficient' do
    units = Spree::Stock::InventoryUnitBuilder.new(order).units

    allow_any_instance_of(Spree::Stock::Quantifier).to receive(:can_supply?) { false }
    expect(line_item).not_to receive(:errors)
    allow(line_item).to receive(:inventory_units) { units }
    subject.validate(line_item)
  end
end
