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

require 'spec_helper'

describe QuadArkopter do
  pending "add some examples to (or delete) #{__FILE__}"
end
