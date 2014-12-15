# == Schema Information
#
# Table name: quad_arkopters
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  status        :string(255)
#  deliveries    :integer          default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  delivery_time :integer          default(60)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :quad_arkopter do
    name "MyString"
    status "MyString"
    deliveries 1
  end
end
