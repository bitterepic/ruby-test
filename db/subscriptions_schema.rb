# frozen_string_literal: true

ActiveRecord::Schema[7.1].define(version: 1) do
  create_table 'subscriptions', force: :cascade do
    t.string :user_id, null: false
    t.string :transation_id, null: false
    t.string :product_id, null: false
  end
end
