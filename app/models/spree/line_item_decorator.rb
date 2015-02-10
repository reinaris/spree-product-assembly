module Spree
  LineItem.class_eval do
    scope :assemblies, -> { joins(:product => :parts).uniq }

    def any_units_shipped?
      OrderInventory.new(self.order, self).inventory_units.any? do |unit|
        unit.shipped?
      end
    end

    # # Destroy and verify inventory so that units are restocked back to the
    # # stock location
    # def destroy_along_with_units
    #   self.quantity = 0
    #   OrderInventory.new(self.order, self).verify
    #   self.destroy
    # end

    # The parts that apply to this particular LineItem. Usually `product#parts`, but
    # provided as a hook if you want to override and customize the parts for a specific
    # LineItem.
    def parts
      product.parts
    end

    def parts_or_variant
      product.assembly? ? product.parts : [variant]
    end

    # The number of the specified variant that make up this LineItem. By default, calls
    # `product#count_of`, but provided as a hook if you want to override and customize
    # the parts available for a specific LineItem. Note that if you only customize whether
    # a variant is included in the LineItem, and don't customize the quantity of that part
    # per LineItem, you shouldn't need to override this method.
    def count_of(variant)
      product.count_of(variant)
    end

    def sufficient_stock?
      # binding.pry
      # Stock::Quantifier.new(variant).can_supply? quantity
      true
    end

    private

      # def update_inventory
      #   if self.product.assembly? && order.completed?
      #     OrderInventory.new(self.order, self).verify(target_shipment)
      #   else
      #     OrderInventory.new(self.order, self).verify(target_shipment)
      #   end
      # end

  end
end
