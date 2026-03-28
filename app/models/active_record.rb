# https://github.com/Shopify/tapioca/issues/1140

ActiveSupport.on_load(:active_record) do
  module ActiveRecordInheritDefineRelationTypes
    def inherited(child)
      super(child)

      child.const_set("PrivateRelation", child.const_get(:ActiveRecord_Relation))
      child.const_set("PrivateAssociationRelation", child.const_get(:ActiveRecord_AssociationRelation))
      child.const_set("PrivateCollectionProxy", child.const_get(:ActiveRecord_Associations_CollectionProxy))

      relation_type = T.type_alias do
        T.any(
          child.const_get(:PrivateRelation),
          child.const_get(:PrivateAssociationRelation),
          child.const_get(:PrivateCollectionProxy),
        )
      end
      child.const_set(:RelationType, relation_type)
    end
  end

  class ::ActiveRecord::Base
    class << self
      prepend ActiveRecordInheritDefineRelationTypes
    end
  end
end
