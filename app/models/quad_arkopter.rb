# == Schema Information
#
# Table name: quad_arkopters
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  status     :string(255)
#  deliveries :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

class QuadArkopter < ActiveRecord::Base
end
