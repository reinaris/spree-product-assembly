class Spree::Stock::AvailabilityValidator < ActiveModel::Validator
  def validate(line_item)

    product = line_item.product

    if product.assembly?
      product.parts.each do |part|
        unit_count = line_item.inventory_units.select{ |iu| iu.variant_id == part.id }.size
        expected_unit_count = line_item.quantity * product.count_of(part)
        next if unit_count >= expected_unit_count

        quantity   = expected_unit_count - unit_count
        quantifier = Spree::Stock::Quantifier.new(part)

        unless quantifier.can_supply? quantity
          display_name = %Q{#{part.name}}
          display_name += %Q{(#{part.options_text})} unless part.options_text.blank?

          line_item.errors[:quantity] << Spree.t(:selected_quantity_not_available, scope: :order_populator, item: display_name.inspect)
        end
      end
    else
      unit_count = line_item.inventory_units.size
      return if unit_count >= line_item.quantity

      quantity = line_item.quantity - unit_count
      quantifier = Spree::Stock::Quantifier.new(line_item.variant)

      unless quantifier.can_supply? quantity
        variant = line_item.variant
        display_name = %Q{#{variant.name}}
        display_name += %Q{(#{variant.options_text})} unless variant.options_text.blank?

        line_item.errors[:quantity] << Spree.t(:selected_quantity_not_available, scope: :order_populator, item: display_name.inspect)
      end
    end
  end
end
