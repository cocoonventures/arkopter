# == Schema Information
#
# Table name: orders
#
#  id          :integer          not null, primary key
#  status      :string(255)
#  user_id     :integer
#  arkopter_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    status "MyString"
    user nil
    arkopter nil
  end
end
