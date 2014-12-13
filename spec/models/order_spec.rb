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

require 'spec_helper'

describe Order do
  pending "add some examples to (or delete) #{__FILE__}"
end
