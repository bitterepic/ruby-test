class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Helper for sorbet to access types
  def self.private_relation
    self.const_get(:ActiveRecord_Relation)
  end

  # Helper for sorbet to access types
  def self.private_accociation_relation
    self.const_get(:ActiveRecord_AssociationRelation)
  end

  # Helper for sorbet to access types
  def self.private_collection_proxy
    self.const_get(:ActiveRecord_Associations_CollectionProxy)
  end

  # Helper for sorbet to access types
  def self.relation_type
     T.type_alias do
      T.any(
        self.private_relation,
        self.private_accociation_relation,
        self.private_collection_proxy
      )
    end
  end
end
