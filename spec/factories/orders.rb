# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  status           :string(255)
#  user_id          :integer
#  quad_arkopter_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  job_id           :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    status "MyString"
    user nil
    arkopter nil
  end
end
