module Spree
  module Stock
    # Overridden from spree core to make it also check for assembly parts stock
    class AvailabilityValidator < ActiveModel::Validator
      def validate(line_item)

        # we need to check unit_count in inventory_units
        # for the each we can use line_item.parts_or_variant ?
        # from spree 2.4:
        
          # unit_count = line_item.inventory_units.size
          # return if unit_count >= line_item.quantity
          # quantity = line_item.quantity - unit_count

          # quantifier = Stock::Quantifier.new(line_item.variant)

          # unless quantifier.can_supply? quantity
          #   variant = line_item.variant
          #   display_name = %Q{#{variant.name}}
          #   display_name += %Q{ (#{variant.options_text})} unless variant.options_text.blank?

          #   line_item.errors[:quantity] << Spree.t(:selected_quantity_not_available, :scope => :order_populator, :item => display_name.inspect)
          # end

        product = line_item.product

        valid = if product.assembly?
          line_item.parts.all? do |part|
            Stock::Quantifier.new(part).can_supply?(line_item.count_of(part) * line_item.quantity)
          end
        else
          Stock::Quantifier.new(line_item.variant).can_supply? line_item.quantity
        end

        unless valid
          variant = line_item.variant
          display_name = %Q{#{variant.name}}
          display_name += %Q{ (#{variant.options_text})} unless variant.options_text.blank?

          line_item.errors[:quantity] << Spree.t(:out_of_stock, :scope => :order_populator, :item => display_name.inspect)
        end
      end
    end
  end
end



