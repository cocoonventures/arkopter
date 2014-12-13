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

require 'spec_helper'

describe Product do
  pending "add some examples to (or delete) #{__FILE__}"
end
