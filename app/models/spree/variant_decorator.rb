module SpreeProductAssembly::VariantDecorator

  def self.prepended(base)
    base.has_and_belongs_to_many  :assemblies, class_name: "Spree::Product",
      join_table: "spree_assemblies_parts", foreign_key: "part_id",
      association_foreign_key: "assembly_id"
  end

  def assemblies_for(products)
    assemblies.where(id: products)
  end

  def part?
    assemblies.exists?
  end

  def can_supply?(quantity=1)
    if product.assembly?
      product.parts.all? { |part| part.can_supply?(product.count_of(part) * quantity) }
    else
      super
    end
  end

end

Spree::Variant.prepend(SpreeProductAssembly::VariantDecorator)
