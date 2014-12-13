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
#

class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :quad_arkopter

end
