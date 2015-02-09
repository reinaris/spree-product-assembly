module Spree
  module Stock
    InventoryUnitBuilder.class_eval do

      def units
        @order.line_items.flat_map do |line_item|
          if line_item.product.assembly?
            line_item.parts.flat_map do |part|
              (line_item.quantity * line_item.count_of(part)).times.map do |i|
                @order.inventory_units.build(
                  pending: true,
                  variant: part,
                  line_item: line_item
                )
              end
            end
          else
            line_item.quantity.times.map do |i|
              @order.inventory_units.build(
                pending: true,
                variant: line_item.variant,
                line_item: line_item
              )
            end
          end
        end
      end

    end
  end
end
