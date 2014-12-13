# == Schema Information
#
# Table name: products
#
#  id             :integer          not null, primary key
#  stock_item_id  :integer
#  inventory_name :string(255)
#  status         :string(255)
#  order_id       :integer
#  arkopter_id    :integer
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    references ""
    inventory_name "MyString"
    status "MyString"
    references ""
    references ""
  end
end
