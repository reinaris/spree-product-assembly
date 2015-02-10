shared_context "product is ordered as individual and within a bundle" do
  let(:order) do
    create(:order_with_line_items).tap do |o|
      if o.line_items.count < 2
        create(:line_item, order: o)
        o.line_items.reload
      end
    end
  end
  let(:parts) { (1..3).map { create(:variant) } }

  let(:bundle_variant) { order.variants.first }
  let(:bundle) { bundle_variant.product }

  let(:common_product) { order.variants.last }

  before do
    expect(bundle_variant).to_not eql common_product

    bundle.parts << [parts, common_product]
  end
end
