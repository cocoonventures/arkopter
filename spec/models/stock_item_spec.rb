# == Schema Information
#
# Table name: stock_items
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  quantity   :integer
#  price      :decimal(6, 2)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe StockItem do
  pending "add some examples to (or delete) #{__FILE__}"
end
